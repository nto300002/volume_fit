import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_providers.dart';

final currentWorkoutPlanAuthUserIdProvider = Provider<String?>(
  (ref) => FirebaseAuth.instance.currentUser?.uid,
);

final workoutPlanWriterProvider = Provider<WorkoutPlanWriter>(
  (ref) => FirestoreWorkoutPlanWriter(FirebaseFirestore.instance),
);

final workoutPlanRepositoryProvider = Provider<WorkoutPlanRepository>(
  (ref) => FirestoreWorkoutPlanRepository(
    currentAuthUserId: ref.watch(currentWorkoutPlanAuthUserIdProvider),
    writer: ref.watch(workoutPlanWriterProvider),
    clock: ref.watch(clockProvider),
  ),
);

abstract interface class WorkoutPlanRepository {
  Future<void> savePlan(WorkoutPlanDraft draft);
}

abstract interface class WorkoutPlanWriter {
  Future<void> addPlan({
    required String ownerUserId,
    required Map<String, Object?> data,
  });
}

class WorkoutPlanDraft {
  const WorkoutPlanDraft({
    required this.plannedDate,
    required this.exerciseId,
    required this.exerciseName,
    required this.resistanceType,
    required this.plannedLoadKg,
    required this.plannedReps,
    required this.plannedSetCount,
    required this.targetRir,
    this.memo,
    this.sourceAiExportHistoryId,
  });

  final DateTime plannedDate;
  final String exerciseId;
  final String exerciseName;
  final String resistanceType;
  final double plannedLoadKg;
  final int plannedReps;
  final int plannedSetCount;
  final int targetRir;
  final String? memo;
  final String? sourceAiExportHistoryId;
}

class WorkoutPlanFailure implements Exception {
  const WorkoutPlanFailure(this.message);

  final String message;
}

class FirestoreWorkoutPlanRepository implements WorkoutPlanRepository {
  const FirestoreWorkoutPlanRepository({
    required this.currentAuthUserId,
    required this.writer,
    required this.clock,
  });

  final String? currentAuthUserId;
  final WorkoutPlanWriter writer;
  final Clock clock;

  @override
  Future<void> savePlan(WorkoutPlanDraft draft) async {
    final ownerUserId = currentAuthUserId;
    if (ownerUserId == null) {
      throw const WorkoutPlanFailure('ログイン状態を確認してください');
    }

    final now = clock();
    try {
      await writer.addPlan(
        ownerUserId: ownerUserId,
        data: _planData(ownerUserId: ownerUserId, draft: draft, now: now),
      );
    } on WorkoutPlanFailure {
      rethrow;
    } on Exception {
      throw const WorkoutPlanFailure('次回予定の保存に失敗しました');
    }
  }

  Map<String, Object?> _planData({
    required String ownerUserId,
    required WorkoutPlanDraft draft,
    required DateTime now,
  }) {
    return {
      'schemaVersion': 1,
      'ownerUserId': ownerUserId,
      'status': 'planned',
      'plannedDate': draft.plannedDate,
      'sourceAiExportHistoryId': draft.sourceAiExportHistoryId,
      'plannedValues': {
        'exerciseId': draft.exerciseId,
        'exerciseName': draft.exerciseName,
        'resistanceType': draft.resistanceType,
        'loadKg': draft.plannedLoadKg,
        'reps': draft.plannedReps,
        'setCount': draft.plannedSetCount,
        'targetRir': draft.targetRir,
        'memo': draft.memo,
      },
      'actualValues': null,
      'actualSessionId': null,
      'createdAt': now,
      'updatedAt': now,
      'revision': 1,
      'isDeleted': false,
    };
  }
}

class FirestoreWorkoutPlanWriter implements WorkoutPlanWriter {
  const FirestoreWorkoutPlanWriter(this._firestore);

  final FirebaseFirestore _firestore;

  @override
  Future<void> addPlan({
    required String ownerUserId,
    required Map<String, Object?> data,
  }) async {
    await _firestore
        .collection('users')
        .doc(ownerUserId)
        .collection('workoutPlans')
        .add(data);
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_providers.dart';

final currentAuthUserIdProvider = Provider<String?>(
  (ref) => FirebaseAuth.instance.currentUser?.uid,
);

final workoutSessionWriterProvider = Provider<WorkoutSessionWriter>(
  (ref) => FirestoreWorkoutSessionWriter(FirebaseFirestore.instance),
);

final workoutSetInputRepositoryProvider = Provider<WorkoutSetInputRepository>(
  (ref) => FirestoreWorkoutSetInputRepository(
    currentAuthUserId: ref.watch(currentAuthUserIdProvider),
    writer: ref.watch(workoutSessionWriterProvider),
    clock: ref.watch(clockProvider),
  ),
);

abstract interface class WorkoutSetInputRepository {
  Future<void> saveDraftSet(WorkoutSetDraft draft);
}

abstract interface class WorkoutSessionWriter {
  Future<void> addSession({
    required String ownerUserId,
    required Map<String, Object?> data,
  });
}

class WorkoutSetDraft {
  const WorkoutSetDraft({
    required this.exerciseId,
    required this.bodyWeightKg,
    required this.bodyWeightLoadRatio,
    required this.addedWeightKg,
    required this.assistanceWeightKg,
    required this.reps,
    required this.rir,
  });

  final String exerciseId;
  final double bodyWeightKg;
  final double bodyWeightLoadRatio;
  final double addedWeightKg;
  final double assistanceWeightKg;
  final int reps;
  final int rir;
}

class WorkoutSetInputFailure implements Exception {
  const WorkoutSetInputFailure(this.message);

  final String message;
}

class FirestoreWorkoutSetInputRepository implements WorkoutSetInputRepository {
  const FirestoreWorkoutSetInputRepository({
    required this.currentAuthUserId,
    required this.writer,
    required this.clock,
  });

  final String? currentAuthUserId;
  final WorkoutSessionWriter writer;
  final Clock clock;

  @override
  Future<void> saveDraftSet(WorkoutSetDraft draft) async {
    final ownerUserId = currentAuthUserId;
    if (ownerUserId == null) {
      throw const WorkoutSetInputFailure('ログイン状態を確認してください');
    }

    final now = clock();
    try {
      await writer.addSession(
        ownerUserId: ownerUserId,
        data: _sessionData(ownerUserId: ownerUserId, draft: draft, now: now),
      );
    } on WorkoutSetInputFailure {
      rethrow;
    } on Exception {
      throw const WorkoutSetInputFailure('保存に失敗しました');
    }
  }

  Map<String, Object?> _sessionData({
    required String ownerUserId,
    required WorkoutSetDraft draft,
    required DateTime now,
  }) {
    return {
      'schemaVersion': 1,
      'ownerUserId': ownerUserId,
      'status': 'completed',
      'goal': null,
      'startedAt': now,
      'completedAt': now,
      'condition': {
        'bodyWeightKg': draft.bodyWeightKg,
        'sleepMinutes': null,
        'fatigueLevel': null,
        'sorenessLevel': null,
        'painStatus': null,
        'painLocation': null,
        'memo': null,
      },
      'exercises': [
        {
          'exerciseLogId': 'push_up-1',
          'exerciseId': draft.exerciseId,
          'displayName': _displayNameFor(draft.exerciseId),
          'resistanceType': 'body_weight',
          'variation': 'standard',
          'targetMuscles': [
            {'muscleId': 'chest', 'allocation': 1.0},
            {'muscleId': 'triceps', 'allocation': 0.5},
            {'muscleId': 'front_deltoid', 'allocation': 0.5},
          ],
          'sets': [
            {
              'setId': 'set-1',
              'order': 1,
              'externalWeightKg': null,
              'bodyWeightKg': draft.bodyWeightKg,
              'bodyWeightLoadRatio': draft.bodyWeightLoadRatio,
              'addedWeightKg': draft.addedWeightKg,
              'assistanceWeightKg': draft.assistanceWeightKg,
              'reps': draft.reps,
              'rir': draft.rir,
              'result': 'completed',
              'rangeOfMotion': 'full',
              'tempo': null,
              'restSeconds': null,
              'memo': null,
            },
          ],
          'memo': null,
        },
      ],
      'exerciseIds': [draft.exerciseId],
      'calculationSettingId': 'standard-v1',
      'sessionMemo': null,
      'createdAt': now,
      'updatedAt': now,
      'revision': 1,
      'isDeleted': false,
      'deletedAt': null,
    };
  }

  String _displayNameFor(String exerciseId) {
    return switch (exerciseId) {
      'push_up' => '腕立て伏せ',
      _ => exerciseId,
    };
  }
}

class FirestoreWorkoutSessionWriter implements WorkoutSessionWriter {
  const FirestoreWorkoutSessionWriter(this._firestore);

  final FirebaseFirestore _firestore;

  @override
  Future<void> addSession({
    required String ownerUserId,
    required Map<String, Object?> data,
  }) async {
    await _firestore
        .collection('users')
        .doc(ownerUserId)
        .collection('workoutSessions')
        .add(data);
  }
}

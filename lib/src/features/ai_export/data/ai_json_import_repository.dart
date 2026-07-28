import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_providers.dart';
import '../domain/ai_json_importer.dart';

final currentAiJsonImportAuthUserIdProvider = Provider<String?>(
  (ref) => FirebaseAuth.instance.currentUser?.uid,
);

final aiJsonImportWriterProvider = Provider<AiJsonImportWriter>(
  (ref) => FirestoreAiJsonImportWriter(FirebaseFirestore.instance),
);

final aiJsonImportRepositoryProvider = Provider<AiJsonImportRepository>(
  (ref) => FirestoreAiJsonImportRepository(
    currentAuthUserId: ref.watch(currentAiJsonImportAuthUserIdProvider),
    writer: ref.watch(aiJsonImportWriterProvider),
    clock: ref.watch(clockProvider),
  ),
);

abstract interface class AiJsonImportRepository {
  Future<void> importPayload(AiJsonImportPayload payload);
}

abstract interface class AiJsonImportWriter {
  Future<void> addSessions({
    required String ownerUserId,
    required List<Map<String, Object?>> sessions,
  });
}

class FirestoreAiJsonImportRepository implements AiJsonImportRepository {
  const FirestoreAiJsonImportRepository({
    required this.currentAuthUserId,
    required this.writer,
    required this.clock,
  });

  final String? currentAuthUserId;
  final AiJsonImportWriter writer;
  final Clock clock;

  @override
  Future<void> importPayload(AiJsonImportPayload payload) async {
    final ownerUserId = currentAuthUserId;
    if (ownerUserId == null) {
      throw const AiJsonImportRepositoryFailure('ログイン状態を確認してください');
    }

    final now = clock();
    try {
      await writer.addSessions(
        ownerUserId: ownerUserId,
        sessions: [
          for (final session in payload.sessions)
            _sessionData(ownerUserId: ownerUserId, session: session, now: now),
        ],
      );
    } on AiJsonImportRepositoryFailure {
      rethrow;
    } on FirebaseException {
      throw const AiJsonImportRepositoryFailure('JSONの取り込みに失敗しました');
    } on Exception {
      throw const AiJsonImportRepositoryFailure('JSONの取り込みに失敗しました');
    }
  }

  Map<String, Object?> _sessionData({
    required String ownerUserId,
    required AiJsonImportSession session,
    required DateTime now,
  }) {
    return {
      'schemaVersion': 1,
      'ownerUserId': ownerUserId,
      'status': 'completed',
      'goal': null,
      'startedAt': now,
      'completedAt': now,
      'importedAt': now,
      'importLabel': session.label,
      'condition': {
        'bodyWeightKg': session.bodyWeightKg,
        'sleepMinutes': null,
        'fatigueLevel': null,
        'sorenessLevel': null,
        'painStatus': null,
        'painLocation': null,
        'memo': null,
      },
      'exercises': [
        for (var index = 0; index < session.exercises.length; index += 1)
          _exerciseData(session.exercises[index], index + 1),
      ],
      'exerciseIds': [
        for (final exercise in session.exercises) _exerciseIdFor(exercise.name),
      ],
      'calculationSettingId': 'imported-v1',
      'sessionMemo': 'JSONインポート: ${session.label}',
      'createdAt': now,
      'updatedAt': now,
      'revision': 1,
      'isDeleted': false,
      'deletedAt': null,
    };
  }

  Map<String, Object?> _exerciseData(AiJsonImportExercise exercise, int index) {
    final exerciseId = _exerciseIdFor(exercise.name);
    return {
      'exerciseLogId': '$exerciseId-$index',
      'exerciseId': exerciseId,
      'displayName': exercise.name,
      'resistanceType': 'body_weight',
      'variation': 'imported',
      'targetMuscles': _targetMusclesFor(exerciseId),
      'sets': [
        for (final set in exercise.sets)
          {
            'setId': 'set-${set.order}',
            'order': set.order,
            'externalWeightKg': null,
            'bodyWeightKg': set.bodyWeightKg,
            'bodyWeightLoadRatio': set.bodyWeightLoadRatio,
            'addedWeightKg': set.addedWeightKg,
            'assistanceWeightKg': set.assistanceWeightKg,
            'reps': set.reps,
            'rir': set.rir,
            'result': 'completed',
            'rangeOfMotion': 'full',
            'tempo': null,
            'restSeconds': null,
            'memo': null,
          },
      ],
      'memo': null,
    };
  }

  String _exerciseIdFor(String name) {
    return switch (name) {
      '腕立て伏せ' => 'push_up',
      'ベンチプレス' => 'bench_press',
      'ダンベルカール' => 'dumbbell_curl',
      _ => 'imported-${name.codeUnits.join('-')}',
    };
  }

  List<Map<String, Object?>> _targetMusclesFor(String exerciseId) {
    return switch (exerciseId) {
      'dumbbell_curl' => [
        {'muscleId': 'biceps', 'allocation': 1.0},
      ],
      'push_up' => [
        {'muscleId': 'chest', 'allocation': 1.0},
        {'muscleId': 'triceps', 'allocation': 0.5},
        {'muscleId': 'front_deltoid', 'allocation': 0.5},
      ],
      _ => const [],
    };
  }
}

class FirestoreAiJsonImportWriter implements AiJsonImportWriter {
  const FirestoreAiJsonImportWriter(this._firestore);

  final FirebaseFirestore _firestore;

  @override
  Future<void> addSessions({
    required String ownerUserId,
    required List<Map<String, Object?>> sessions,
  }) async {
    final batch = _firestore.batch();
    final collection = _firestore
        .collection('users')
        .doc(ownerUserId)
        .collection('workoutSessions');
    for (final session in sessions) {
      batch.set(collection.doc(), session);
    }
    await batch.commit();
  }
}

class AiJsonImportRepositoryFailure implements Exception {
  const AiJsonImportRepositoryFailure(this.message);

  final String message;
}

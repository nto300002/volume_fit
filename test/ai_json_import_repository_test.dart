import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:volume_fit/src/features/ai_export/data/ai_json_import_repository.dart';
import 'package:volume_fit/src/features/ai_export/domain/ai_json_importer.dart';

void main() {
  test(
    'imports parsed sessions into the signed-in users workout history',
    () async {
      final writer = _RecordingWriter();
      final repository = FirestoreAiJsonImportRepository(
        currentAuthUserId: 'user-1',
        writer: writer,
        clock: () => DateTime.utc(2026, 7, 27, 9),
      );
      final payload = const AiJsonImporter().parse(_validJson());

      await repository.importPayload(payload);

      expect(writer.ownerUserId, 'user-1');
      expect(writer.sessions, hasLength(1));
      final session = writer.sessions.single;
      expect(session['importLabel'], '2026-07-27 上半身');
      expect(session['completedAt'], DateTime.utc(2026, 7, 27, 9));
      final exercises = session['exercises'] as List<Object?>;
      final exercise = exercises.single as Map<String, Object?>;
      expect(exercise['exerciseId'], 'push_up');
      expect(exercise['displayName'], '腕立て伏せ');
      final sets = exercise['sets'] as List<Object?>;
      final set = sets.single as Map<String, Object?>;
      expect(set['reps'], 12);
      expect(set['rir'], 2);
    },
  );

  test('rejects import when no user is signed in', () async {
    final repository = FirestoreAiJsonImportRepository(
      currentAuthUserId: null,
      writer: _RecordingWriter(),
      clock: DateTime.now,
    );
    final payload = const AiJsonImporter().parse(_validJson());

    expect(
      () => repository.importPayload(payload),
      throwsA(
        isA<AiJsonImportRepositoryFailure>().having(
          (failure) => failure.message,
          'message',
          'ログイン状態を確認してください',
        ),
      ),
    );
  });
}

class _RecordingWriter implements AiJsonImportWriter {
  String? ownerUserId;
  List<Map<String, Object?>> sessions = const [];

  @override
  Future<void> addSessions({
    required String ownerUserId,
    required List<Map<String, Object?>> sessions,
  }) async {
    this.ownerUserId = ownerUserId;
    this.sessions = sessions;
  }
}

String _validJson() => jsonEncode({
  'schemaVersion': 1,
  'format': 'volume_fit_ai_export',
  'sessions': [
    {
      'label': '2026-07-27 上半身',
      'bodyWeightKg': 80,
      'exercises': [
        {
          'name': '腕立て伏せ',
          'sets': [
            {
              'order': 1,
              'reps': 12,
              'rir': 2,
              'bodyWeightKg': 80,
              'bodyWeightLoadRatio': 0.72,
              'addedWeightKg': 0,
              'assistanceWeightKg': 0,
            },
          ],
        },
      ],
    },
  ],
});

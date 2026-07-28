import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:volume_fit/src/features/ai_export/domain/ai_json_importer.dart';

void main() {
  const importer = AiJsonImporter();

  test('parses a supported JSON export into importable sessions', () {
    final result = importer.parse(_validJson());

    expect(result.sessions, hasLength(1));
    expect(result.sessions.single.label, '2026-07-27 上半身');
    expect(result.sessions.single.exercises.single.name, '腕立て伏せ');
    expect(result.sessions.single.exercises.single.sets.single.reps, 12);
    expect(result.sessions.single.exercises.single.sets.single.rir, 2);
  });

  test('rejects an unsupported schema version', () {
    final json = jsonDecode(_validJson()) as Map<String, Object?>;
    json['schemaVersion'] = 2;

    expect(
      () => importer.parse(jsonEncode(json)),
      throwsA(
        isA<AiJsonImportFailure>().having(
          (failure) => failure.message,
          'message',
          'このJSONのバージョンには対応していません',
        ),
      ),
    );
  });

  test('rejects malformed set data', () {
    final json = jsonDecode(_validJson()) as Map<String, Object?>;
    final sessions = json['sessions'] as List<Object?>;
    final session = sessions.single as Map<String, Object?>;
    final exercises = session['exercises'] as List<Object?>;
    final exercise = exercises.single as Map<String, Object?>;
    final sets = exercise['sets'] as List<Object?>;
    final set = sets.single as Map<String, Object?>;
    set['reps'] = 0;

    expect(
      () => importer.parse(jsonEncode(json)),
      throwsA(
        isA<AiJsonImportFailure>().having(
          (failure) => failure.message,
          'message',
          'セットの回数を確認してください',
        ),
      ),
    );
  });

  test('rejects imports that exceed the local import limit', () {
    final sessions = List<Object?>.filled(AiJsonImporter.maxSessionCount + 1, {
      'label': 'session',
      'bodyWeightKg': 80,
      'exercises': [
        {
          'name': '腕立て伏せ',
          'sets': [
            {
              'order': 1,
              'reps': 10,
              'rir': null,
              'bodyWeightKg': 80,
              'bodyWeightLoadRatio': 0.72,
              'addedWeightKg': 0,
              'assistanceWeightKg': 0,
              'estimatedLoadKg': 57.6,
              'setVolumeKg': 576,
              'effortAdjustedVolumeKg': 403.2,
              'isHardSet': null,
            },
          ],
        },
      ],
    }, growable: false);

    expect(
      () => importer.parse(
        jsonEncode({
          'schemaVersion': 1,
          'format': 'volume_fit_ai_export',
          'sessions': sessions,
        }),
      ),
      throwsA(
        isA<AiJsonImportFailure>().having(
          (failure) => failure.message,
          'message',
          'このJSONは大きすぎます。大量データの取り込みは未対応です',
        ),
      ),
    );
  });
}

String _validJson() => jsonEncode({
  'schemaVersion': 1,
  'format': 'volume_fit_ai_export',
  'purpose': '今日の評価と次回メニュー作成',
  'calculationVersion': 'standard-v1',
  'promptVersion': 'prompt-v1',
  'instructions': const [],
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
              'estimatedLoadKg': 57.6,
              'setVolumeKg': 691.2,
              'effortAdjustedVolumeKg': 656.64,
              'isHardSet': true,
            },
          ],
        },
      ],
    },
  ],
});

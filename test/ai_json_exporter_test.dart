import 'package:flutter_test/flutter_test.dart';
import 'package:volume_fit/src/features/ai_export/domain/ai_json_exporter.dart';
import 'package:volume_fit/src/features/ai_export/domain/ai_markdown_generator.dart';

void main() {
  test('generates structured JSON for AI sharing and backup', () {
    final json = const AiJsonExporter().generate(
      const AiMarkdownRequest(
        purpose: '今日の評価と次回メニュー作成',
        sessions: [
          AiMarkdownSession(
            sessionLabel: '2026-07-27 上半身',
            bodyWeightKg: 80,
            exercises: [
              AiMarkdownExercise(
                name: '腕立て伏せ',
                sets: [
                  AiMarkdownSet(
                    order: 1,
                    reps: 12,
                    rir: 2,
                    bodyWeightKg: 80,
                    bodyWeightLoadRatio: 0.72,
                    addedWeightKg: 0,
                    assistanceWeightKg: 0,
                    estimatedLoadKg: 57.6,
                    setVolumeKg: 691.2,
                    effortAdjustedVolumeKg: 656.64,
                    isHardSet: true,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      calculationVersion: 'standard-v1',
      promptVersion: 'prompt-v1',
    );

    expect(json['schemaVersion'], 1);
    expect(json['format'], 'volume_fit_ai_export');
    expect(json['purpose'], '今日の評価と次回メニュー作成');
    expect(json['calculationVersion'], 'standard-v1');
    expect(json['promptVersion'], 'prompt-v1');
    expect(json['instructions'], isA<List<Object?>>());

    final sessions = json['sessions'] as List<Object?>;
    final session = sessions.single as Map<String, Object?>;
    expect(session['label'], '2026-07-27 上半身');
    expect(session['bodyWeightKg'], 80);

    final exercises = session['exercises'] as List<Object?>;
    final exercise = exercises.single as Map<String, Object?>;
    expect(exercise['name'], '腕立て伏せ');

    final sets = exercise['sets'] as List<Object?>;
    final set = sets.single as Map<String, Object?>;
    expect(set['order'], 1);
    expect(set['reps'], 12);
    expect(set['rir'], 2);
    expect(set['bodyWeightLoadRatio'], 0.72);
    expect(set['estimatedLoadKg'], 57.6);
    expect(set['setVolumeKg'], 691.2);
    expect(set['effortAdjustedVolumeKg'], 656.64);
    expect(set['isHardSet'], isTrue);
  });

  test('keeps unknown RIR as null without inventing values', () {
    final json = const AiJsonExporter().generate(
      const AiMarkdownRequest(
        purpose: '今日の評価',
        sessions: [
          AiMarkdownSession(
            sessionLabel: '未入力RIRの確認',
            bodyWeightKg: 80,
            exercises: [
              AiMarkdownExercise(
                name: '腕立て伏せ',
                sets: [
                  AiMarkdownSet(
                    order: 1,
                    reps: 10,
                    rir: null,
                    bodyWeightKg: 80,
                    bodyWeightLoadRatio: 0.72,
                    addedWeightKg: 0,
                    assistanceWeightKg: 0,
                    estimatedLoadKg: 57.6,
                    setVolumeKg: 576,
                    effortAdjustedVolumeKg: 403.2,
                    isHardSet: null,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      calculationVersion: 'standard-v1',
      promptVersion: 'prompt-v1',
    );

    final sessions = json['sessions'] as List<Object?>;
    final session = sessions.single as Map<String, Object?>;
    final exercises = session['exercises'] as List<Object?>;
    final exercise = exercises.single as Map<String, Object?>;
    final sets = exercise['sets'] as List<Object?>;
    final set = sets.single as Map<String, Object?>;
    expect(set['rir'], isNull);
    expect(set['isHardSet'], isNull);
  });
}

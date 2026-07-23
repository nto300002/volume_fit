import 'package:flutter_test/flutter_test.dart';
import 'package:volume_fit/src/features/ai_export/domain/ai_markdown_generator.dart';

void main() {
  test('generates markdown with facts, estimates, and AI instructions', () {
    final markdown = const AiMarkdownGenerator().generate(
      const AiMarkdownRequest(
        purpose: '今日の評価と次回メニュー作成',
        sessions: [
          AiMarkdownSession(
            sessionLabel: '2026-07-23 上半身',
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
    );

    expect(markdown, startsWith('# AIトレーニングレビュー依頼'));
    expect(markdown, contains('## AIへの共通指示'));
    expect(markdown, contains('記録上確認できる事実と推定を分けてください。'));
    expect(markdown, contains('不明な情報を創作しないでください。'));
    expect(markdown, contains('アプリの計算値は比較用の概算です。'));
    expect(markdown, contains('推定ボリュームを筋肥大効果と同一視しないでください。'));
    expect(markdown, contains('次回メニューでは、種目、重量または負荷方式、回数、セット数、目標RIRを示してください。'));
    expect(markdown, contains('最後にNotionへ保存しやすいMarkdownを出力してください。'));
    expect(markdown, contains('## 記録上確認できる事実'));
    expect(markdown, contains('- 体重: 80.0 kg'));
    expect(
      markdown,
      contains('| 1 | 12 | 2 | 80.0 kg | 0.72 | 0.0 kg | 0.0 kg |'),
    );
    expect(markdown, contains('## アプリ計算値（比較用の概算）'));
    expect(
      markdown,
      contains('| 1 | 57.6 kg | 691.2 kg | 656.6 kg | ハードセット |'),
    );
    expect(markdown, contains('## 依頼したいこと'));
    expect(markdown, contains('今日の評価と次回メニュー作成'));
  });

  test('omits unknown RIR and hard-set judgement without inventing values', () {
    final markdown = const AiMarkdownGenerator().generate(
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
    );

    expect(markdown, contains('| 1 | 10 | 不明 | 80.0 kg |'));
    expect(markdown, contains('| 1 | 57.6 kg | 576.0 kg | 403.2 kg | 不明 |'));
  });
}

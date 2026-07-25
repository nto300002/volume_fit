import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:volume_fit/src/app/app_providers.dart';
import 'package:volume_fit/src/features/ai_export/data/ai_export_history_repository.dart';

void main() {
  test('saves AI export history as an AiExportHistory payload', () async {
    final writer = FakeAiExportHistoryWriter();
    final now = DateTime.utc(2026, 7, 23, 6, 1, 2);
    final container = ProviderContainer(
      overrides: [
        currentAiExportAuthUserIdProvider.overrideWithValue('uid-1'),
        aiExportHistoryWriterProvider.overrideWithValue(writer),
        clockProvider.overrideWithValue(() => now),
      ],
    );
    addTearDown(container.dispose);

    await container
        .read(aiExportHistoryRepositoryProvider)
        .saveHistory(
          const AiExportHistoryDraft(
            targetSessionIds: ['session-1'],
            referenceSessionId: null,
            purpose: 'daily_review',
            targetAiService: 'chatgpt',
            markdownContent: '# AIトレーニングレビュー依頼',
            jsonContent: {'format': 'markdown'},
            calculationVersion: 'standard-v1',
            promptVersion: 'prompt-v1',
            calculationSnapshot: {
              'sets': [
                {
                  'estimatedLoadKg': 57.6,
                  'setVolumeKg': 691.2,
                  'effortAdjustedVolumeKg': 656.64,
                },
              ],
            },
            customInstruction: null,
          ),
        );

    expect(writer.ownerUserId, 'uid-1');
    final data = writer.data;
    expect(data?['schemaVersion'], 1);
    expect(data?['ownerUserId'], 'uid-1');
    expect(data?['targetSessionIds'], ['session-1']);
    expect(data?['referenceSessionId'], isNull);
    expect(data?['purpose'], 'daily_review');
    expect(data?['targetAiService'], 'chatgpt');
    expect(data?['markdownContent'], '# AIトレーニングレビュー依頼');
    expect(data?['jsonContent'], {'format': 'markdown'});
    expect(data?['calculationVersion'], 'standard-v1');
    expect(data?['promptVersion'], 'prompt-v1');
    expect(data?['customInstruction'], isNull);
    expect(data?['aiResponseMemo'], isNull);
    expect(data?['createdAt'], now);
    expect(data?['updatedAt'], now);
    expect(data?['revision'], 1);
    expect(data?['isDeleted'], isFalse);

    final snapshot = data?['calculationSnapshot'] as Map<String, Object?>;
    final sets = snapshot['sets'] as List<Object?>;
    final set = sets.single as Map<String, Object?>;
    expect(set['estimatedLoadKg'], 57.6);
    expect(set['setVolumeKg'], 691.2);
    expect(set['effortAdjustedVolumeKg'], 656.64);
  });

  test('rejects save when auth user is missing', () async {
    final container = ProviderContainer(
      overrides: [
        currentAiExportAuthUserIdProvider.overrideWithValue(null),
        aiExportHistoryWriterProvider.overrideWithValue(
          FakeAiExportHistoryWriter(),
        ),
      ],
    );
    addTearDown(container.dispose);

    expect(
      () => container
          .read(aiExportHistoryRepositoryProvider)
          .saveHistory(
            const AiExportHistoryDraft(
              targetSessionIds: [],
              referenceSessionId: null,
              purpose: 'daily_review',
              targetAiService: 'chatgpt',
              markdownContent: '# Markdown',
              jsonContent: {},
              calculationVersion: 'standard-v1',
              promptVersion: 'prompt-v1',
              calculationSnapshot: {},
              customInstruction: null,
            ),
          ),
      throwsA(isA<AiExportHistoryFailure>()),
    );
  });
}

class FakeAiExportHistoryWriter implements AiExportHistoryWriter {
  String? ownerUserId;
  Map<String, Object?>? data;

  @override
  Future<void> addHistory({
    required String ownerUserId,
    required Map<String, Object?> data,
  }) async {
    this.ownerUserId = ownerUserId;
    this.data = data;
  }
}

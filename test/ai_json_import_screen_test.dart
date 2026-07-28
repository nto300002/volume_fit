import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:volume_fit/src/app/app_router.dart';
import 'package:volume_fit/src/app/volume_fit_app.dart';
import 'package:volume_fit/src/features/ai_export/data/ai_json_import_repository.dart';
import 'package:volume_fit/src/features/ai_export/domain/ai_json_importer.dart';

void main() {
  testWidgets('imports a valid JSON export from the AI screen', (
    WidgetTester tester,
  ) async {
    final repository = _RecordingRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          isAuthenticatedProvider.overrideWithValue(true),
          initialLocationProvider.overrideWithValue(AppRoutePaths.ai),
          aiJsonImportRepositoryProvider.overrideWithValue(repository),
        ],
        child: const VolumeFitApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('aiJsonImportField')),
      _validJson(),
    );
    await tester.ensureVisible(find.byKey(const Key('aiJsonImportButton')));
    await tester.tap(find.byKey(const Key('aiJsonImportButton')));
    await tester.pumpAndSettle();

    expect(find.text('1件のセッションを取り込みました'), findsOneWidget);
    expect(repository.payload?.sessions, hasLength(1));
  });

  testWidgets('shows validation feedback instead of importing malformed JSON', (
    WidgetTester tester,
  ) async {
    final repository = _RecordingRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          isAuthenticatedProvider.overrideWithValue(true),
          initialLocationProvider.overrideWithValue(AppRoutePaths.ai),
          aiJsonImportRepositoryProvider.overrideWithValue(repository),
        ],
        child: const VolumeFitApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('aiJsonImportField')),
      '{invalid json',
    );
    await tester.ensureVisible(find.byKey(const Key('aiJsonImportButton')));
    await tester.tap(find.byKey(const Key('aiJsonImportButton')));
    await tester.pumpAndSettle();

    expect(find.text('JSONの形式を確認してください'), findsOneWidget);
    expect(repository.payload, isNull);
  });
}

class _RecordingRepository implements AiJsonImportRepository {
  AiJsonImportPayload? payload;

  @override
  Future<void> importPayload(AiJsonImportPayload payload) async {
    this.payload = payload;
  }
}

String _validJson() => jsonEncode({
  'schemaVersion': 1,
  'format': 'volume_fit_ai_export',
  'sessions': [
    {
      'label': '今回のトレーニング',
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
            },
          ],
        },
      ],
    },
  ],
});

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:volume_fit/src/app/app_router.dart';
import 'package:volume_fit/src/app/volume_fit_app.dart';
import 'package:volume_fit/src/features/account/data/account_deletion_repository.dart';
import 'package:volume_fit/src/features/auth/application/email_registration_controller.dart';

void main() {
  testWidgets('confirms account deletion before calling the repository', (
    tester,
  ) async {
    final repository = _RecordingAccountDeletionRepository();
    final container = ProviderContainer(
      overrides: [
        initialLocationProvider.overrideWithValue(AppRoutePaths.accountDelete),
        accountDeletionRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);
    container.read(authSessionProvider.notifier).markAuthenticated();
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const VolumeFitApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('deleteAccountButton')));
    await tester.pumpAndSettle();

    expect(find.text('アカウントを削除しますか？'), findsOneWidget);
    expect(repository.deleteCallCount, 0);

    await tester.tap(find.byKey(const Key('confirmDeleteAccountButton')));
    await tester.pumpAndSettle();

    expect(repository.deleteCallCount, 1);
    expect(find.text('メールでログイン'), findsOneWidget);
  });
}

class _RecordingAccountDeletionRepository implements AccountDeletionRepository {
  int deleteCallCount = 0;

  @override
  Future<void> deleteAccount() async {
    deleteCallCount += 1;
  }
}

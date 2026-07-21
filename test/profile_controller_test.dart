import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:volume_fit/src/features/profile/application/profile_controller.dart';
import 'package:volume_fit/src/features/profile/data/profile_repository.dart';

void main() {
  test('rejects missing body weight before saving', () async {
    final repository = FakeProfileRepository();
    final container = ProviderContainer(
      overrides: [profileRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    final succeeded = await container
        .read(profileControllerProvider.notifier)
        .saveInitialProfile(
          bodyWeightText: '',
          primaryGoal: 'hypertrophy',
        );

    expect(succeeded, isFalse);
    expect(repository.saveCallCount, 0);
    expect(
      container.read(profileControllerProvider).value?.errorMessage,
      '体重を入力してください',
    );
  });

  test('rejects missing primary goal before saving', () async {
    final repository = FakeProfileRepository();
    final container = ProviderContainer(
      overrides: [profileRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    final succeeded = await container
        .read(profileControllerProvider.notifier)
        .saveInitialProfile(bodyWeightText: '66.8');

    expect(succeeded, isFalse);
    expect(repository.saveCallCount, 0);
    expect(
      container.read(profileControllerProvider).value?.errorMessage,
      '主要目的を選択してください',
    );
  });

  test('saves required profile fields with metric unit system', () async {
    final repository = FakeProfileRepository();
    final container = ProviderContainer(
      overrides: [profileRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    final succeeded = await container
        .read(profileControllerProvider.notifier)
        .saveInitialProfile(
          displayName: 'User',
          heightText: '170.5',
          bodyWeightText: '66.8',
          trainingExperienceMonthsText: '24',
          primaryGoal: 'hypertrophy',
        );

    expect(succeeded, isTrue);
    expect(repository.saveCallCount, 1);
    expect(repository.lastDraft?.displayName, 'User');
    expect(repository.lastDraft?.heightCm, 170.5);
    expect(repository.lastDraft?.currentBodyWeightKg, 66.8);
    expect(repository.lastDraft?.trainingExperienceMonths, 24);
    expect(repository.lastDraft?.primaryGoal, 'hypertrophy');
    expect(repository.lastDraft?.unitSystem, 'metric');
    expect(container.read(profileControllerProvider).value?.isSaved, isTrue);
  });
}

class FakeProfileRepository implements ProfileRepository {
  int saveCallCount = 0;
  InitialProfileDraft? lastDraft;

  @override
  Future<void> saveInitialProfile(InitialProfileDraft draft) async {
    saveCallCount += 1;
    lastDraft = draft;
  }
}

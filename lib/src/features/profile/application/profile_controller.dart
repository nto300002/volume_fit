import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/data/auth_repository.dart';
import '../data/profile_repository.dart';

final profileControllerProvider =
    AsyncNotifierProvider<ProfileController, ProfileControllerState>(
      ProfileController.new,
    );

class ProfileControllerState {
  const ProfileControllerState({
    this.isSaved = false,
    this.errorMessage,
  });

  final bool isSaved;
  final String? errorMessage;
}

class ProfileController extends AsyncNotifier<ProfileControllerState> {
  @override
  ProfileControllerState build() => const ProfileControllerState();

  Future<bool> saveInitialProfile({
    String? displayName,
    String? heightText,
    required String bodyWeightText,
    String? trainingExperienceMonthsText,
    String? primaryGoal,
  }) async {
    final bodyWeight = double.tryParse(bodyWeightText.trim());
    if (bodyWeight == null) {
      state = const AsyncData(
        ProfileControllerState(errorMessage: '体重を入力してください'),
      );
      return false;
    }

    if (bodyWeight <= 0 || bodyWeight > 500) {
      state = const AsyncData(
        ProfileControllerState(errorMessage: '体重は0より大きい値で入力してください'),
      );
      return false;
    }

    final selectedGoal = primaryGoal;
    if (selectedGoal == null || selectedGoal.isEmpty) {
      state = const AsyncData(
        ProfileControllerState(errorMessage: '主要目的を選択してください'),
      );
      return false;
    }

    state = const AsyncLoading();

    try {
      await ref
          .read(profileRepositoryProvider)
          .saveInitialProfile(
            InitialProfileDraft(
              displayName: _blankToNull(displayName),
              heightCm: _optionalDouble(heightText),
              currentBodyWeightKg: bodyWeight,
              trainingExperienceMonths: _optionalInt(
                trainingExperienceMonthsText,
              ),
              primaryGoal: selectedGoal,
            ),
          );
      state = const AsyncData(ProfileControllerState(isSaved: true));
      return true;
    } on AuthFailure catch (error) {
      state = AsyncData(ProfileControllerState(errorMessage: error.message));
      return false;
    }
  }

  String? _blankToNull(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }

  double? _optionalDouble(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }
    return double.tryParse(trimmed);
  }

  int? _optionalInt(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }
    return int.tryParse(trimmed);
  }
}

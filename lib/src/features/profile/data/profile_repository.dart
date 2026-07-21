import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_providers.dart';
import '../../auth/data/auth_repository.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final clock = ref.watch(clockProvider);

  return FirebaseProfileRepository(
    FirebaseAuth.instance,
    FirebaseFirestore.instance,
    clock,
  );
});

abstract interface class ProfileRepository {
  Future<void> saveInitialProfile(InitialProfileDraft draft);
}

class InitialProfileDraft {
  const InitialProfileDraft({
    this.displayName,
    this.heightCm,
    required this.currentBodyWeightKg,
    this.trainingExperienceMonths,
    required this.primaryGoal,
    this.unitSystem = 'metric',
  });

  final String? displayName;
  final double? heightCm;
  final double currentBodyWeightKg;
  final int? trainingExperienceMonths;
  final String primaryGoal;
  final String unitSystem;
}

class FirebaseProfileRepository implements ProfileRepository {
  const FirebaseProfileRepository(this._auth, this._firestore, this._clock);

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final Clock _clock;

  @override
  Future<void> saveInitialProfile(InitialProfileDraft draft) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw const AuthFailure('ログイン状態を確認してください');
    }

    final now = Timestamp.fromDate(_clock());
    final data = <String, Object?>{
      'schemaVersion': 1,
      'ownerUserId': user.uid,
      'displayName': draft.displayName,
      'heightCm': draft.heightCm,
      'currentBodyWeightKg': draft.currentBodyWeightKg,
      'trainingExperienceMonths': draft.trainingExperienceMonths,
      'primaryGoal': draft.primaryGoal,
      'unitSystem': draft.unitSystem,
      'createdAt': now,
      'updatedAt': now,
      'revision': 1,
    };

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('profile')
        .doc('main')
        .set(data);
  }
}

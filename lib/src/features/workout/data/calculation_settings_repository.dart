import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_providers.dart';
import 'calculation_settings.dart';

final currentCalculationSettingsAuthUserIdProvider = Provider<String?>(
  (ref) => FirebaseAuth.instance.currentUser?.uid,
);

final calculationSettingsReaderProvider = Provider<CalculationSettingsReader>(
  (ref) => FirestoreCalculationSettingsReader(FirebaseFirestore.instance),
);

final calculationSettingsWriterProvider = Provider<CalculationSettingsWriter>(
  (ref) => FirestoreCalculationSettingsWriter(FirebaseFirestore.instance),
);

final calculationSettingsRepositoryProvider =
    Provider<CalculationSettingsRepository>(
      (ref) => FirestoreCalculationSettingsRepository(
        currentAuthUserId: ref.watch(
          currentCalculationSettingsAuthUserIdProvider,
        ),
        reader: ref.watch(calculationSettingsReaderProvider),
        writer: ref.watch(calculationSettingsWriterProvider),
        clock: ref.watch(clockProvider),
      ),
    );

abstract interface class CalculationSettingsRepository {
  Future<CalculationSettings?> fetchDefault();

  Future<void> saveDefault(CalculationSettings settings);
}

abstract interface class CalculationSettingsReader {
  Future<Map<String, Object?>?> fetchSetting({
    required String ownerUserId,
    required String settingId,
  });
}

abstract interface class CalculationSettingsWriter {
  Future<void> setSetting({
    required String ownerUserId,
    required String settingId,
    required Map<String, Object?> data,
  });
}

class CalculationSettingsFailure implements Exception {
  const CalculationSettingsFailure(this.message);

  final String message;
}

class FirestoreCalculationSettingsRepository
    implements CalculationSettingsRepository {
  const FirestoreCalculationSettingsRepository({
    required this.currentAuthUserId,
    required this.reader,
    required this.writer,
    required this.clock,
  });

  final String? currentAuthUserId;
  final CalculationSettingsReader reader;
  final CalculationSettingsWriter writer;
  final Clock clock;

  @override
  Future<CalculationSettings?> fetchDefault() async {
    final ownerUserId = _userId();
    try {
      final data = await reader.fetchSetting(
        ownerUserId: ownerUserId,
        settingId: CalculationSettings.defaultCustomSettingId,
      );
      if (data == null) {
        return null;
      }

      return _settingsFromData(
        settingId: CalculationSettings.defaultCustomSettingId,
        data: data,
      );
    } on CalculationSettingsFailure {
      rethrow;
    } on Exception {
      throw const CalculationSettingsFailure('計算設定の取得に失敗しました');
    }
  }

  @override
  Future<void> saveDefault(CalculationSettings settings) async {
    final ownerUserId = _userId();
    final now = clock();
    try {
      await writer.setSetting(
        ownerUserId: ownerUserId,
        settingId: CalculationSettings.defaultCustomSettingId,
        data: _settingsData(
          ownerUserId: ownerUserId,
          settings: settings,
          now: now,
        ),
      );
    } on CalculationSettingsFailure {
      rethrow;
    } on Exception {
      throw const CalculationSettingsFailure('計算設定の保存に失敗しました');
    }
  }

  String _userId() {
    final userId = currentAuthUserId;
    if (userId == null) {
      throw const CalculationSettingsFailure('ログイン状態を確認してください');
    }

    return userId;
  }

  Map<String, Object?> _settingsData({
    required String ownerUserId,
    required CalculationSettings settings,
    required DateTime now,
  }) {
    return {
      'schemaVersion': 1,
      'ownerUserId': ownerUserId,
      'name': settings.name,
      'baseVersion': settings.baseVersion,
      'bodyweightCoefficients': {
        for (final entry in settings.bodyWeightLoadRatios.entries)
          '${entry.key}.standard': entry.value,
      },
      'rirMultipliers': {
        for (final entry in settings.rirMultipliers.entries)
          entry.key.toString(): entry.value,
        'unknown': settings.unknownRirMultiplier,
      },
      'highRirMultiplier': settings.highRirMultiplier,
      'muscleAllocations': settings.muscleAllocations,
      'isDefault': true,
      'createdAt': now,
      'updatedAt': now,
      'revision': 1,
    };
  }

  CalculationSettings _settingsFromData({
    required String settingId,
    required Map<String, Object?> data,
  }) {
    return CalculationSettings(
      id: settingId,
      name: data['name'] as String? ?? '自分用設定',
      baseVersion:
          data['baseVersion'] as String? ?? CalculationSettings.standardVersion,
      bodyWeightLoadRatios: _bodyweightRatios(data['bodyweightCoefficients']),
      rirMultipliers: _rirMultipliers(data['rirMultipliers']),
      highRirMultiplier:
          (data['highRirMultiplier'] as num?)?.toDouble() ?? 0.30,
      unknownRirMultiplier:
          _unknownRirMultiplier(data['rirMultipliers']) ?? 0.70,
      muscleAllocations: _muscleAllocations(data['muscleAllocations']),
    );
  }

  Map<String, double> _bodyweightRatios(Object? value) {
    final map = value as Map<String, Object?>? ?? const {};
    final ratios = <String, double>{};
    for (final entry in map.entries) {
      final ratio = entry.value;
      if (ratio is! num) {
        continue;
      }

      ratios[entry.key.replaceAll('.standard', '')] = ratio.toDouble();
    }

    return ratios.isEmpty
        ? const CalculationSettings.standard().bodyWeightLoadRatios
        : ratios;
  }

  Map<int, double> _rirMultipliers(Object? value) {
    final map = value as Map<String, Object?>? ?? const {};
    final multipliers = <int, double>{};
    for (final entry in map.entries) {
      final rir = int.tryParse(entry.key);
      final multiplier = entry.value;
      if (rir == null || multiplier is! num) {
        continue;
      }

      multipliers[rir] = multiplier.toDouble();
    }

    return multipliers.isEmpty
        ? const CalculationSettings.standard().rirMultipliers
        : multipliers;
  }

  double? _unknownRirMultiplier(Object? value) {
    final map = value as Map<String, Object?>?;
    final multiplier = map?['unknown'];
    return multiplier is num ? multiplier.toDouble() : null;
  }

  Map<String, Map<String, double>> _muscleAllocations(Object? value) {
    final map = value as Map<String, Object?>? ?? const {};
    final allocations = <String, Map<String, double>>{};
    for (final exercise in map.entries) {
      final muscles = exercise.value as Map<String, Object?>?;
      if (muscles == null) {
        continue;
      }

      allocations[exercise.key] = {
        for (final muscle in muscles.entries)
          if (muscle.value is num) muscle.key: (muscle.value as num).toDouble(),
      };
    }

    return allocations.isEmpty
        ? const CalculationSettings.standard().muscleAllocations
        : allocations;
  }
}

class FirestoreCalculationSettingsReader implements CalculationSettingsReader {
  const FirestoreCalculationSettingsReader(this._firestore);

  final FirebaseFirestore _firestore;

  @override
  Future<Map<String, Object?>?> fetchSetting({
    required String ownerUserId,
    required String settingId,
  }) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(ownerUserId)
        .collection('calculationSettings')
        .doc(settingId)
        .get();
    return snapshot.data();
  }
}

class FirestoreCalculationSettingsWriter implements CalculationSettingsWriter {
  const FirestoreCalculationSettingsWriter(this._firestore);

  final FirebaseFirestore _firestore;

  @override
  Future<void> setSetting({
    required String ownerUserId,
    required String settingId,
    required Map<String, Object?> data,
  }) async {
    await _firestore
        .collection('users')
        .doc(ownerUserId)
        .collection('calculationSettings')
        .doc(settingId)
        .set(data);
  }
}

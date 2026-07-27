import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'calculation_settings.dart';
import 'workout_set_input_repository.dart';

final workoutHistoryReaderProvider = Provider<WorkoutHistoryReader>(
  (ref) => FirestoreWorkoutHistoryReader(FirebaseFirestore.instance),
);

final workoutHistoryRepositoryProvider = Provider<WorkoutHistoryRepository>(
  (ref) => FirestoreWorkoutHistoryRepository(
    currentAuthUserId: ref.watch(currentAuthUserIdProvider),
    reader: ref.watch(workoutHistoryReaderProvider),
    calculationSettings: ref.watch(calculationSettingsProvider),
  ),
);

abstract interface class WorkoutHistoryRepository {
  Future<List<WorkoutHistorySession>> fetchRecent({int limit = 20});

  Future<List<WorkoutHistorySession>> fetchByCompletedAt({
    required DateTime from,
    required DateTime to,
    int limit = 50,
  });

  Future<WorkoutSessionDetail> fetchSessionDetail(String sessionId);
}

abstract interface class WorkoutHistoryReader {
  Future<List<WorkoutHistoryDocument>> fetch(WorkoutHistoryQuery query);

  Future<WorkoutHistoryDocument?> fetchById({
    required String ownerUserId,
    required String sessionId,
  });
}

class WorkoutHistoryQuery {
  const WorkoutHistoryQuery({
    required this.ownerUserId,
    this.from,
    this.to,
    required this.limit,
    this.includeDeleted = false,
  });

  final String ownerUserId;
  final DateTime? from;
  final DateTime? to;
  final int limit;
  final bool includeDeleted;
}

class WorkoutHistoryDocument {
  const WorkoutHistoryDocument({required this.id, required this.data});

  final String id;
  final Map<String, Object?> data;
}

class WorkoutHistorySession {
  const WorkoutHistorySession({
    required this.id,
    required this.completedAt,
    required this.exerciseSummary,
    required this.setCount,
    required this.totalVolumeKg,
  });

  final String id;
  final DateTime completedAt;
  final String exerciseSummary;
  final int setCount;
  final double totalVolumeKg;
}

class WorkoutSessionDetail {
  const WorkoutSessionDetail({
    required this.id,
    required this.completedAt,
    required this.exercises,
    required this.totalVolumeKg,
    this.effortAdjustedVolumeKg = 0,
    this.hardSetCount = 0,
    this.targetMuscleIds = const {},
    this.previousComparison,
  });

  final String id;
  final DateTime completedAt;
  final List<WorkoutSessionDetailExercise> exercises;
  final double totalVolumeKg;
  final double effortAdjustedVolumeKg;
  final int hardSetCount;
  final Set<String> targetMuscleIds;
  final WorkoutSessionComparison? previousComparison;
}

class WorkoutSessionComparison {
  const WorkoutSessionComparison({
    required this.label,
    required this.estimatedVolumeDeltaKg,
    required this.effortAdjustedVolumeDeltaKg,
    required this.hardSetDelta,
    required this.targetMuscleMatchRatio,
  });

  final String label;
  final double estimatedVolumeDeltaKg;
  final double effortAdjustedVolumeDeltaKg;
  final int hardSetDelta;
  final double targetMuscleMatchRatio;
}

class WorkoutSessionDetailExercise {
  const WorkoutSessionDetailExercise({required this.name, required this.sets});

  final String name;
  final List<WorkoutSessionDetailSet> sets;
}

class WorkoutSessionDetailSet {
  const WorkoutSessionDetailSet({
    required this.order,
    required this.reps,
    required this.rir,
    required this.estimatedLoadKg,
    required this.setVolumeKg,
    required this.effortAdjustedVolumeKg,
  });

  final int order;
  final int reps;
  final int? rir;
  final double estimatedLoadKg;
  final double setVolumeKg;
  final double effortAdjustedVolumeKg;
}

class WorkoutHistoryFailure implements Exception {
  const WorkoutHistoryFailure(this.message);

  final String message;
}

class FirestoreWorkoutHistoryRepository implements WorkoutHistoryRepository {
  const FirestoreWorkoutHistoryRepository({
    required this.currentAuthUserId,
    required this.reader,
    required this.calculationSettings,
  });

  final String? currentAuthUserId;
  final WorkoutHistoryReader reader;
  final CalculationSettings calculationSettings;

  @override
  Future<List<WorkoutHistorySession>> fetchRecent({int limit = 20}) async {
    return _fetch(WorkoutHistoryQuery(ownerUserId: _userId(), limit: limit));
  }

  @override
  Future<List<WorkoutHistorySession>> fetchByCompletedAt({
    required DateTime from,
    required DateTime to,
    int limit = 50,
  }) async {
    return _fetch(
      WorkoutHistoryQuery(
        ownerUserId: _userId(),
        from: from,
        to: to,
        limit: limit,
      ),
    );
  }

  @override
  Future<WorkoutSessionDetail> fetchSessionDetail(String sessionId) async {
    final ownerUserId = _userId();
    try {
      final document = await reader.fetchById(
        ownerUserId: ownerUserId,
        sessionId: sessionId,
      );
      if (document == null || document.data['isDeleted'] == true) {
        throw const WorkoutHistoryFailure('セッションが見つかりません');
      }

      final currentDetail = _detailFromDocument(document);
      final previousDetail = await _previousDetailFor(
        ownerUserId: ownerUserId,
        currentDocument: document,
        currentDetail: currentDetail,
      );

      return _detailFromDocument(
        document,
        previousComparison: previousDetail == null
            ? null
            : _comparison(current: currentDetail, previous: previousDetail),
      );
    } on WorkoutHistoryFailure {
      rethrow;
    } on FirebaseException {
      throw const WorkoutHistoryFailure('セッション詳細の取得に失敗しました');
    } on Exception {
      throw const WorkoutHistoryFailure('セッション詳細の取得に失敗しました');
    }
  }

  Future<List<WorkoutHistorySession>> _fetch(WorkoutHistoryQuery query) async {
    try {
      final documents = await reader.fetch(query);
      return documents
          .where((document) => document.data['isDeleted'] != true)
          .map(_sessionFromDocument)
          .toList();
    } on WorkoutHistoryFailure {
      rethrow;
    } on FirebaseException {
      throw const WorkoutHistoryFailure('履歴の取得に失敗しました');
    } on Exception {
      throw const WorkoutHistoryFailure('履歴の取得に失敗しました');
    }
  }

  String _userId() {
    final userId = currentAuthUserId;
    if (userId == null) {
      throw const WorkoutHistoryFailure('ログイン状態を確認してください');
    }

    return userId;
  }

  WorkoutHistorySession _sessionFromDocument(WorkoutHistoryDocument document) {
    final data = document.data;
    final exercises = (data['exercises'] as List<Object?>? ?? const [])
        .whereType<Map<String, Object?>>()
        .toList();
    final exerciseNames = exercises
        .map((exercise) => exercise['displayName'] as String? ?? '未設定')
        .toList();
    final sets = exercises
        .expand((exercise) => exercise['sets'] as List<Object?>? ?? const [])
        .whereType<Map<String, Object?>>()
        .toList();

    return WorkoutHistorySession(
      id: document.id,
      completedAt:
          _dateTime(data['completedAt']) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      exerciseSummary: exerciseNames.isEmpty
          ? '未設定'
          : exerciseNames.join(' / '),
      setCount: sets.length,
      totalVolumeKg: _totalVolumeKg(data, sets),
    );
  }

  DateTime? _dateTime(Object? value) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    return null;
  }

  double _totalVolumeKg(
    Map<String, Object?> sessionData,
    List<Map<String, Object?>> sets,
  ) {
    final storedTotal = sessionData['totalVolumeKg'];
    if (storedTotal is num) {
      return storedTotal.toDouble();
    }

    return sets.fold(0, (total, set) {
      final reps = (set['reps'] as num?)?.toInt() ?? 0;
      return total + _estimatedLoadKg(set) * reps;
    });
  }

  double _estimatedLoadKg(Map<String, Object?> set) {
    final externalWeight = set['externalWeightKg'];
    if (externalWeight is num) {
      return externalWeight.toDouble();
    }

    final bodyWeight = (set['bodyWeightKg'] as num?)?.toDouble() ?? 0;
    final ratio = (set['bodyWeightLoadRatio'] as num?)?.toDouble() ?? 0;
    final added = (set['addedWeightKg'] as num?)?.toDouble() ?? 0;
    final assistance = (set['assistanceWeightKg'] as num?)?.toDouble() ?? 0;
    return bodyWeight * ratio + added - assistance;
  }

  Future<WorkoutSessionDetail?> _previousDetailFor({
    required String ownerUserId,
    required WorkoutHistoryDocument currentDocument,
    required WorkoutSessionDetail currentDetail,
  }) async {
    final documents = await reader.fetch(
      WorkoutHistoryQuery(
        ownerUserId: ownerUserId,
        to: currentDetail.completedAt,
        limit: 20,
      ),
    );
    final previousDocuments =
        documents
            .where((document) => document.id != currentDocument.id)
            .where((document) => document.data['isDeleted'] != true)
            .map(_detailFromDocument)
            .where(
              (detail) =>
                  detail.completedAt.isBefore(currentDetail.completedAt),
            )
            .toList()
          ..sort((a, b) => b.completedAt.compareTo(a.completedAt));

    return previousDocuments.firstOrNull;
  }

  WorkoutSessionComparison _comparison({
    required WorkoutSessionDetail current,
    required WorkoutSessionDetail previous,
  }) {
    return WorkoutSessionComparison(
      label: '前回比',
      estimatedVolumeDeltaKg: current.totalVolumeKg - previous.totalVolumeKg,
      effortAdjustedVolumeDeltaKg:
          current.effortAdjustedVolumeKg - previous.effortAdjustedVolumeKg,
      hardSetDelta: current.hardSetCount - previous.hardSetCount,
      targetMuscleMatchRatio: _targetMuscleMatchRatio(
        current.targetMuscleIds,
        previous.targetMuscleIds,
      ),
    );
  }

  double _targetMuscleMatchRatio(Set<String> current, Set<String> previous) {
    if (current.isEmpty && previous.isEmpty) {
      return 1;
    }

    final union = {...current, ...previous};
    if (union.isEmpty) {
      return 0;
    }

    final intersection = current.intersection(previous);
    return intersection.length / union.length;
  }

  WorkoutSessionDetail _detailFromDocument(
    WorkoutHistoryDocument document, {
    WorkoutSessionComparison? previousComparison,
  }) {
    final data = document.data;
    final exercises = (data['exercises'] as List<Object?>? ?? const [])
        .whereType<Map<String, Object?>>()
        .map(_detailExercise)
        .toList();
    final totalVolume = exercises.fold(0.0, (total, exercise) {
      return total +
          exercise.sets.fold(0.0, (exerciseTotal, set) {
            return exerciseTotal + set.setVolumeKg;
          });
    });
    final effortAdjustedVolume = exercises.fold(0.0, (total, exercise) {
      return total +
          exercise.sets.fold(0.0, (exerciseTotal, set) {
            return exerciseTotal + set.effortAdjustedVolumeKg;
          });
    });

    return WorkoutSessionDetail(
      id: document.id,
      completedAt:
          _dateTime(data['completedAt']) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      exercises: exercises,
      totalVolumeKg: totalVolume,
      effortAdjustedVolumeKg: effortAdjustedVolume,
      hardSetCount: exercises.fold(0, (total, exercise) {
        return total +
            exercise.sets
                .where((set) => set.rir != null && set.rir! <= 4)
                .length;
      }),
      targetMuscleIds: _targetMuscleIds(exercises: data['exercises']),
      previousComparison: previousComparison,
    );
  }

  WorkoutSessionDetailExercise _detailExercise(Map<String, Object?> exercise) {
    final sets = (exercise['sets'] as List<Object?>? ?? const [])
        .whereType<Map<String, Object?>>()
        .map(_detailSet)
        .toList();

    return WorkoutSessionDetailExercise(
      name: exercise['displayName'] as String? ?? '未設定',
      sets: sets,
    );
  }

  WorkoutSessionDetailSet _detailSet(Map<String, Object?> set) {
    final reps = (set['reps'] as num?)?.toInt() ?? 0;
    final rir = (set['rir'] as num?)?.toInt();
    final estimatedLoad = _estimatedLoadKg(set);
    final setVolume = estimatedLoad * reps;
    return WorkoutSessionDetailSet(
      order: (set['order'] as num?)?.toInt() ?? 1,
      reps: reps,
      rir: rir,
      estimatedLoadKg: estimatedLoad,
      setVolumeKg: setVolume,
      effortAdjustedVolumeKg:
          setVolume * calculationSettings.rirMultiplierFor(rir),
    );
  }

  Set<String> _targetMuscleIds({required Object? exercises}) {
    return (exercises as List<Object?>? ?? const [])
        .whereType<Map<String, Object?>>()
        .expand(
          (exercise) => exercise['targetMuscles'] as List<Object?>? ?? const [],
        )
        .whereType<Map<String, Object?>>()
        .map((muscle) => muscle['muscleId'])
        .whereType<String>()
        .toSet();
  }
}

class FirestoreWorkoutHistoryReader implements WorkoutHistoryReader {
  const FirestoreWorkoutHistoryReader(this._firestore);

  final FirebaseFirestore _firestore;

  @override
  Future<List<WorkoutHistoryDocument>> fetch(WorkoutHistoryQuery query) async {
    Query<Map<String, dynamic>> firestoreQuery = _firestore
        .collection('users')
        .doc(query.ownerUserId)
        .collection('workoutSessions')
        .orderBy('completedAt', descending: true)
        .limit(query.limit);

    if (!query.includeDeleted) {
      firestoreQuery = firestoreQuery.where('isDeleted', isEqualTo: false);
    }

    final from = query.from;
    if (from != null) {
      firestoreQuery = firestoreQuery.where(
        'completedAt',
        isGreaterThanOrEqualTo: Timestamp.fromDate(from),
      );
    }

    final to = query.to;
    if (to != null) {
      firestoreQuery = firestoreQuery.where(
        'completedAt',
        isLessThanOrEqualTo: Timestamp.fromDate(to),
      );
    }

    final snapshot = await firestoreQuery.get();
    return [
      for (final document in snapshot.docs)
        WorkoutHistoryDocument(id: document.id, data: document.data()),
    ];
  }

  @override
  Future<WorkoutHistoryDocument?> fetchById({
    required String ownerUserId,
    required String sessionId,
  }) async {
    final document = await _firestore
        .collection('users')
        .doc(ownerUserId)
        .collection('workoutSessions')
        .doc(sessionId)
        .get();

    final data = document.data();
    if (!document.exists || data == null) {
      return null;
    }

    return WorkoutHistoryDocument(id: document.id, data: data);
  }
}

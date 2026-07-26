import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'workout_set_input_repository.dart';

final workoutHistoryReaderProvider = Provider<WorkoutHistoryReader>(
  (ref) => FirestoreWorkoutHistoryReader(FirebaseFirestore.instance),
);

final workoutHistoryRepositoryProvider = Provider<WorkoutHistoryRepository>(
  (ref) => FirestoreWorkoutHistoryRepository(
    currentAuthUserId: ref.watch(currentAuthUserIdProvider),
    reader: ref.watch(workoutHistoryReaderProvider),
  ),
);

abstract interface class WorkoutHistoryRepository {
  Future<List<WorkoutHistorySession>> fetchRecent({int limit = 20});

  Future<List<WorkoutHistorySession>> fetchByCompletedAt({
    required DateTime from,
    required DateTime to,
    int limit = 50,
  });
}

abstract interface class WorkoutHistoryReader {
  Future<List<WorkoutHistoryDocument>> fetch(WorkoutHistoryQuery query);
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

class WorkoutHistoryFailure implements Exception {
  const WorkoutHistoryFailure(this.message);

  final String message;
}

class FirestoreWorkoutHistoryRepository implements WorkoutHistoryRepository {
  const FirestoreWorkoutHistoryRepository({
    required this.currentAuthUserId,
    required this.reader,
  });

  final String? currentAuthUserId;
  final WorkoutHistoryReader reader;

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
}

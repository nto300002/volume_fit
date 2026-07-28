import 'dart:convert';

class AiJsonImporter {
  const AiJsonImporter();

  static const supportedSchemaVersion = 1;
  static const maxSessionCount = 100;
  static const maxSetCount = 1000;
  static const maxSourceLength = 200000;

  AiJsonImportPayload parse(String source) {
    if (source.trim().isEmpty) {
      throw const AiJsonImportFailure('JSONを入力してください');
    }
    if (source.length > maxSourceLength) {
      throw const AiJsonImportFailure('このJSONは大きすぎます。大量データの取り込みは未対応です');
    }

    final Object? decoded;
    try {
      decoded = jsonDecode(source);
    } on FormatException {
      throw const AiJsonImportFailure('JSONの形式を確認してください');
    }
    final root = _map(decoded, 'JSONの形式を確認してください');

    if (root['schemaVersion'] != supportedSchemaVersion) {
      throw const AiJsonImportFailure('このJSONのバージョンには対応していません');
    }
    if (root['format'] != 'volume_fit_ai_export') {
      throw const AiJsonImportFailure('Volume Fit のエクスポートJSONを入力してください');
    }

    final sessionValues = _list(root['sessions'], 'セッションを確認してください');
    if (sessionValues.isEmpty) {
      throw const AiJsonImportFailure('取り込めるセッションがありません');
    }
    if (sessionValues.length > maxSessionCount) {
      throw const AiJsonImportFailure('このJSONは大きすぎます。大量データの取り込みは未対応です');
    }

    var setCount = 0;
    final sessions = <AiJsonImportSession>[];
    for (final value in sessionValues) {
      final session = _map(value, 'セッションを確認してください');
      final label = _text(session['label'], 'セッション名を確認してください');
      final bodyWeightKg = _positiveNumber(
        session['bodyWeightKg'],
        '体重を確認してください',
      );
      final exerciseValues = _list(session['exercises'], '種目を確認してください');
      if (exerciseValues.isEmpty) {
        throw const AiJsonImportFailure('種目を確認してください');
      }

      final exercises = <AiJsonImportExercise>[];
      for (final exerciseValue in exerciseValues) {
        final exercise = _map(exerciseValue, '種目を確認してください');
        final name = _text(exercise['name'], '種目名を確認してください');
        final setValues = _list(exercise['sets'], 'セットを確認してください');
        if (setValues.isEmpty) {
          throw const AiJsonImportFailure('セットを確認してください');
        }

        final sets = <AiJsonImportSet>[];
        for (final setValue in setValues) {
          setCount += 1;
          if (setCount > maxSetCount) {
            throw const AiJsonImportFailure('このJSONは大きすぎます。大量データの取り込みは未対応です');
          }
          sets.add(_setFrom(_map(setValue, 'セットを確認してください')));
        }
        exercises.add(AiJsonImportExercise(name: name, sets: sets));
      }
      sessions.add(
        AiJsonImportSession(
          label: label,
          bodyWeightKg: bodyWeightKg,
          exercises: exercises,
        ),
      );
    }

    return AiJsonImportPayload(sessions: sessions);
  }

  AiJsonImportSet _setFrom(Map<String, Object?> source) {
    final rirValue = source['rir'];
    final rir = rirValue == null ? null : _integer(rirValue, 'RIRを確認してください');
    if (rir != null && (rir < 0 || rir > 10)) {
      throw const AiJsonImportFailure('RIRを確認してください');
    }
    return AiJsonImportSet(
      order: _positiveInteger(source['order'], 'セット順を確認してください'),
      reps: _positiveInteger(source['reps'], 'セットの回数を確認してください'),
      rir: rir,
      bodyWeightKg: _positiveNumber(source['bodyWeightKg'], '体重を確認してください'),
      bodyWeightLoadRatio: _nonNegativeNumber(
        source['bodyWeightLoadRatio'],
        '自重係数を確認してください',
      ),
      addedWeightKg: _nonNegativeNumber(
        source['addedWeightKg'],
        '追加重量を確認してください',
      ),
      assistanceWeightKg: _nonNegativeNumber(
        source['assistanceWeightKg'],
        '補助重量を確認してください',
      ),
    );
  }

  Map<String, Object?> _map(Object? value, String message) {
    if (value is Map<String, Object?>) {
      return value;
    }
    if (value is Map) {
      return value.map((key, value) => MapEntry(key.toString(), value));
    }
    throw AiJsonImportFailure(message);
  }

  List<Object?> _list(Object? value, String message) {
    if (value is List<Object?>) {
      return value;
    }
    if (value is List) {
      return List<Object?>.from(value);
    }
    throw AiJsonImportFailure(message);
  }

  String _text(Object? value, String message) {
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }
    throw AiJsonImportFailure(message);
  }

  int _positiveInteger(Object? value, String message) {
    final result = _integer(value, message);
    if (result < 1) {
      throw AiJsonImportFailure(message);
    }
    return result;
  }

  int _integer(Object? value, String message) {
    if (value is num && value.isFinite && value == value.roundToDouble()) {
      return value.toInt();
    }
    throw AiJsonImportFailure(message);
  }

  double _positiveNumber(Object? value, String message) {
    final result = _number(value, message);
    if (result <= 0) {
      throw AiJsonImportFailure(message);
    }
    return result;
  }

  double _nonNegativeNumber(Object? value, String message) {
    final result = _number(value, message);
    if (result < 0) {
      throw AiJsonImportFailure(message);
    }
    return result;
  }

  double _number(Object? value, String message) {
    if (value is num && value.isFinite) {
      return value.toDouble();
    }
    throw AiJsonImportFailure(message);
  }
}

class AiJsonImportPayload {
  const AiJsonImportPayload({required this.sessions});

  final List<AiJsonImportSession> sessions;
}

class AiJsonImportSession {
  const AiJsonImportSession({
    required this.label,
    required this.bodyWeightKg,
    required this.exercises,
  });

  final String label;
  final double bodyWeightKg;
  final List<AiJsonImportExercise> exercises;
}

class AiJsonImportExercise {
  const AiJsonImportExercise({required this.name, required this.sets});

  final String name;
  final List<AiJsonImportSet> sets;
}

class AiJsonImportSet {
  const AiJsonImportSet({
    required this.order,
    required this.reps,
    required this.rir,
    required this.bodyWeightKg,
    required this.bodyWeightLoadRatio,
    required this.addedWeightKg,
    required this.assistanceWeightKg,
  });

  final int order;
  final int reps;
  final int? rir;
  final double bodyWeightKg;
  final double bodyWeightLoadRatio;
  final double addedWeightKg;
  final double assistanceWeightKg;
}

class AiJsonImportFailure implements Exception {
  const AiJsonImportFailure(this.message);

  final String message;
}

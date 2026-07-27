import 'ai_markdown_generator.dart';

class AiJsonExporter {
  const AiJsonExporter();

  Map<String, Object?> generate(
    AiMarkdownRequest request, {
    required String calculationVersion,
    required String promptVersion,
  }) {
    return {
      'schemaVersion': 1,
      'format': 'volume_fit_ai_export',
      'purpose': request.purpose,
      'calculationVersion': calculationVersion,
      'promptVersion': promptVersion,
      'instructions': const [
        '記録上確認できる事実と推定を分けてください。',
        '不明な情報を創作しないでください。',
        'アプリの計算値は比較用の概算です。',
        '推定ボリュームを筋肥大効果と同一視しないでください。',
        '次回メニューでは、種目、重量または負荷方式、回数、セット数、目標RIRを示してください。',
      ],
      'sessions': [
        for (final session in request.sessions) _sessionJson(session),
      ],
    };
  }

  Map<String, Object?> _sessionJson(AiMarkdownSession session) {
    return {
      'label': session.sessionLabel,
      'bodyWeightKg': _rounded(session.bodyWeightKg),
      'exercises': [
        for (final exercise in session.exercises) _exerciseJson(exercise),
      ],
    };
  }

  Map<String, Object?> _exerciseJson(AiMarkdownExercise exercise) {
    return {
      'name': exercise.name,
      'sets': [for (final set in exercise.sets) _setJson(set)],
    };
  }

  Map<String, Object?> _setJson(AiMarkdownSet set) {
    return {
      'order': set.order,
      'reps': set.reps,
      'rir': set.rir,
      'bodyWeightKg': _rounded(set.bodyWeightKg),
      'bodyWeightLoadRatio': _rounded(set.bodyWeightLoadRatio),
      'addedWeightKg': _rounded(set.addedWeightKg),
      'assistanceWeightKg': _rounded(set.assistanceWeightKg),
      'estimatedLoadKg': _rounded(set.estimatedLoadKg),
      'setVolumeKg': _rounded(set.setVolumeKg),
      'effortAdjustedVolumeKg': _rounded(set.effortAdjustedVolumeKg),
      'isHardSet': set.isHardSet,
    };
  }

  double _rounded(double value) {
    return double.parse(value.toStringAsFixed(3));
  }
}

class AiMarkdownGenerator {
  const AiMarkdownGenerator();

  String generate(AiMarkdownRequest request) {
    final buffer = StringBuffer()
      ..writeln('# AIトレーニングレビュー依頼')
      ..writeln()
      ..writeln('## AIへの共通指示')
      ..writeln()
      ..writeln('- 記録上確認できる事実と推定を分けてください。')
      ..writeln('- 不明な情報を創作しないでください。')
      ..writeln('- アプリの計算値は比較用の概算です。')
      ..writeln('- 推定ボリュームを筋肥大効果と同一視しないでください。')
      ..writeln('- 次回メニューでは、種目、重量または負荷方式、回数、セット数、目標RIRを示してください。')
      ..writeln('- 最後にNotionへ保存しやすいMarkdownを出力してください。')
      ..writeln()
      ..writeln('## 依頼したいこと')
      ..writeln()
      ..writeln(request.purpose)
      ..writeln()
      ..writeln('## 記録上確認できる事実')
      ..writeln();

    for (final session in request.sessions) {
      buffer
        ..writeln('### ${session.sessionLabel}')
        ..writeln()
        ..writeln('- 体重: ${_kg(session.bodyWeightKg)}')
        ..writeln();

      for (final exercise in session.exercises) {
        buffer
          ..writeln('#### ${exercise.name}')
          ..writeln()
          ..writeln('| セット | 回数 | RIR | 体重 | 自重負荷係数 | 追加重量 | 補助重量 |')
          ..writeln('|---:|---:|---:|---:|---:|---:|---:|');

        for (final set in exercise.sets) {
          buffer.writeln(
            '| ${set.order} | ${set.reps} | ${_rir(set.rir)} | ${_kg(set.bodyWeightKg)} | ${set.bodyWeightLoadRatio.toStringAsFixed(2)} | ${_kg(set.addedWeightKg)} | ${_kg(set.assistanceWeightKg)} |',
          );
        }

        buffer.writeln();
      }
    }

    buffer
      ..writeln('## アプリ計算値（比較用の概算）')
      ..writeln()
      ..writeln('| セット | 推定負荷 | セットボリューム | RIR補正ボリューム | ハードセット判定 |')
      ..writeln('|---:|---:|---:|---:|---|');

    for (final session in request.sessions) {
      for (final exercise in session.exercises) {
        for (final set in exercise.sets) {
          buffer.writeln(
            '| ${set.order} | ${_kg(set.estimatedLoadKg)} | ${_kg(set.setVolumeKg)} | ${_kg(set.effortAdjustedVolumeKg)} | ${_hardSet(set.isHardSet)} |',
          );
        }
      }
    }

    return buffer.toString().trimRight();
  }

  String _kg(double value) => '${value.toStringAsFixed(1)} kg';

  String _rir(int? value) => value?.toString() ?? '不明';

  String _hardSet(bool? value) {
    return switch (value) {
      true => 'ハードセット',
      false => '通常セット',
      null => '不明',
    };
  }
}

class AiMarkdownRequest {
  const AiMarkdownRequest({required this.purpose, required this.sessions});

  final String purpose;
  final List<AiMarkdownSession> sessions;
}

class AiMarkdownSession {
  const AiMarkdownSession({
    required this.sessionLabel,
    required this.bodyWeightKg,
    required this.exercises,
  });

  final String sessionLabel;
  final double bodyWeightKg;
  final List<AiMarkdownExercise> exercises;
}

class AiMarkdownExercise {
  const AiMarkdownExercise({required this.name, required this.sets});

  final String name;
  final List<AiMarkdownSet> sets;
}

class AiMarkdownSet {
  const AiMarkdownSet({
    required this.order,
    required this.reps,
    required this.rir,
    required this.bodyWeightKg,
    required this.bodyWeightLoadRatio,
    required this.addedWeightKg,
    required this.assistanceWeightKg,
    required this.estimatedLoadKg,
    required this.setVolumeKg,
    required this.effortAdjustedVolumeKg,
    required this.isHardSet,
  });

  final int order;
  final int reps;
  final int? rir;
  final double bodyWeightKg;
  final double bodyWeightLoadRatio;
  final double addedWeightKg;
  final double assistanceWeightKg;
  final double estimatedLoadKg;
  final double setVolumeKg;
  final double effortAdjustedVolumeKg;
  final bool? isHardSet;
}

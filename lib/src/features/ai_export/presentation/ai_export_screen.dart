import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_router.dart';
import '../../auth/application/logout_controller.dart';
import '../../workout/data/calculation_settings.dart';
import '../../workout/domain/bodyweight_load_calculator.dart';
import '../../workout/domain/hard_set_judge.dart';
import '../../workout/domain/rir_adjusted_volume_calculator.dart';
import '../../workout/domain/set_volume_calculator.dart';
import '../data/ai_export_history_repository.dart';
import '../domain/ai_markdown_generator.dart';

class AiExportScreen extends ConsumerStatefulWidget {
  const AiExportScreen({super.key});

  @override
  ConsumerState<AiExportScreen> createState() => _AiExportScreenState();
}

class _AiExportScreenState extends ConsumerState<AiExportScreen> {
  final _bodyWeightController = TextEditingController();
  final _repsController = TextEditingController();
  final _addedWeightController = TextEditingController();
  final _assistanceWeightController = TextEditingController();
  int? _rir;
  String? _markdown;
  Map<String, Object?>? _calculationSnapshot;
  bool _isSavingHistory = false;
  String? _successMessage;
  String? _errorMessage;

  @override
  void dispose() {
    _bodyWeightController.dispose();
    _repsController.dispose();
    _addedWeightController.dispose();
    _assistanceWeightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final logout = ref.watch(logoutControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI出力'),
        actions: [
          TextButton(
            onPressed: logout.isLoading
                ? null
                : () async {
                    final succeeded = await ref
                        .read(logoutControllerProvider.notifier)
                        .logout();

                    if (succeeded && context.mounted) {
                      context.go(AppRoutePaths.login);
                    }
                  },
            child: const Text('ログアウト'),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Markdown生成',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                TextField(
                  key: const Key('aiBodyWeightField'),
                  controller: _bodyWeightController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: '体重 kg',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  key: const Key('aiRepsField'),
                  controller: _repsController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: '回数',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  key: const Key('aiAddedWeightField'),
                  controller: _addedWeightController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: '追加重量 kg',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  key: const Key('aiAssistanceWeightField'),
                  controller: _assistanceWeightController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: '補助重量 kg',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  key: const Key('aiRirDropdown'),
                  initialValue: _rir,
                  decoration: const InputDecoration(
                    labelText: 'RIR',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    for (var rir = 0; rir <= 10; rir += 1)
                      DropdownMenuItem(value: rir, child: Text('RIR $rir')),
                  ],
                  onChanged: (value) => setState(() => _rir = value),
                ),
                const SizedBox(height: 16),
                if (_errorMessage != null) ...[
                  Text(
                    _errorMessage!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                if (_successMessage != null) ...[
                  Text(
                    _successMessage!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                FilledButton(
                  key: const Key('aiGenerateMarkdownButton'),
                  onPressed: _generate,
                  child: const Text('Markdown生成'),
                ),
                if (_markdown != null) ...[
                  const SizedBox(height: 24),
                  Text(
                    'Markdownプレビュー',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: SelectableText(_markdown!),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    key: const Key('aiSaveHistoryButton'),
                    onPressed: _isSavingHistory ? null : _saveHistory,
                    child: _isSavingHistory
                        ? const SizedBox.square(
                            dimension: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('履歴保存'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _generate() {
    final bodyWeight = double.tryParse(_bodyWeightController.text.trim());
    final reps = int.tryParse(_repsController.text.trim());
    final addedWeight = _optionalWeight(_addedWeightController.text);
    final assistanceWeight = _optionalWeight(_assistanceWeightController.text);
    final ratio = ref
        .read(calculationSettingsProvider)
        .bodyWeightLoadRatioFor('push_up');

    if (bodyWeight == null || bodyWeight <= 0) {
      setState(() {
        _errorMessage = '体重を入力してください';
        _markdown = null;
      });
      return;
    }

    if (reps == null || reps < 1) {
      setState(() {
        _errorMessage = '回数は1回以上で入力してください';
        _markdown = null;
      });
      return;
    }

    if (addedWeight == null || assistanceWeight == null || ratio == null) {
      setState(() {
        _errorMessage = '入力値を確認してください';
        _markdown = null;
      });
      return;
    }

    final estimatedLoad = const BodyweightLoadCalculator().estimatedLoadKg(
      bodyWeightKg: bodyWeight,
      bodyWeightLoadRatio: ratio,
      addedWeightKg: addedWeight,
      assistanceWeightKg: assistanceWeight,
    );
    final setVolume = const SetVolumeCalculator().setVolumeKg(
      estimatedLoadKg: estimatedLoad,
      reps: reps,
    );
    final effortAdjustedVolume = const RirAdjustedVolumeCalculator()
        .effortAdjustedVolume(
          setVolumeKg: setVolume,
          rir: _rir,
          settings: ref.read(calculationSettingsProvider),
        );
    final isHardSet = const HardSetJudge().isHardSet(_rir);

    setState(() {
      _errorMessage = null;
      _successMessage = null;
      _calculationSnapshot = {
        'sets': [
          {
            'exerciseId': 'push_up',
            'exerciseName': '腕立て伏せ',
            'order': 1,
            'estimatedLoadKg': estimatedLoad,
            'setVolumeKg': setVolume,
            'effortAdjustedVolumeKg': effortAdjustedVolume,
            'isHardSet': isHardSet,
          },
        ],
      };
      _markdown = const AiMarkdownGenerator().generate(
        AiMarkdownRequest(
          purpose: '今日の評価と次回メニュー作成',
          sessions: [
            AiMarkdownSession(
              sessionLabel: '今回のトレーニング',
              bodyWeightKg: bodyWeight,
              exercises: [
                AiMarkdownExercise(
                  name: '腕立て伏せ',
                  sets: [
                    AiMarkdownSet(
                      order: 1,
                      reps: reps,
                      rir: _rir,
                      bodyWeightKg: bodyWeight,
                      bodyWeightLoadRatio: ratio,
                      addedWeightKg: addedWeight,
                      assistanceWeightKg: assistanceWeight,
                      estimatedLoadKg: estimatedLoad,
                      setVolumeKg: setVolume,
                      effortAdjustedVolumeKg: effortAdjustedVolume,
                      isHardSet: isHardSet,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Future<void> _saveHistory() async {
    final markdown = _markdown;
    final calculationSnapshot = _calculationSnapshot;
    if (markdown == null || calculationSnapshot == null) {
      setState(() {
        _successMessage = null;
        _errorMessage = 'Markdownを生成してください';
      });
      return;
    }

    setState(() {
      _isSavingHistory = true;
      _successMessage = null;
      _errorMessage = null;
    });

    try {
      await ref
          .read(aiExportHistoryRepositoryProvider)
          .saveHistory(
            AiExportHistoryDraft(
              targetSessionIds: const [],
              referenceSessionId: null,
              purpose: 'daily_review',
              targetAiService: 'chatgpt',
              markdownContent: markdown,
              jsonContent: const {},
              calculationVersion: 'standard-v1',
              promptVersion: 'prompt-v1',
              calculationSnapshot: calculationSnapshot,
              customInstruction: null,
            ),
          );
      setState(() {
        _isSavingHistory = false;
        _successMessage = 'AI出力履歴を保存しました';
      });
    } on AiExportHistoryFailure catch (error) {
      setState(() {
        _isSavingHistory = false;
        _errorMessage = error.message;
      });
    }
  }

  double? _optionalWeight(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return 0;
    }

    final parsed = double.tryParse(trimmed);
    if (parsed == null || parsed < 0) {
      return null;
    }

    return parsed;
  }
}

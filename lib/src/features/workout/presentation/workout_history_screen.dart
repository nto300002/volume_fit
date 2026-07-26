import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_router.dart';
import '../../auth/application/logout_controller.dart';
import '../application/workout_history_controller.dart';
import '../data/workout_history_repository.dart';

class WorkoutHistoryScreen extends ConsumerWidget {
  const WorkoutHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(workoutHistoryControllerProvider);
    final logout = ref.watch(logoutControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('履歴'),
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
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: history.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => _HistoryMessage(
                message: error is WorkoutHistoryFailure
                    ? error.message
                    : '履歴の取得に失敗しました',
              ),
              data: (state) => _HistoryList(state: state),
            ),
          ),
        ),
      ),
    );
  }
}

class _HistoryList extends ConsumerWidget {
  const _HistoryList({required this.state});

  final WorkoutHistoryState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                key: const Key('historyRecentButton'),
                onPressed: () => ref
                    .read(workoutHistoryControllerProvider.notifier)
                    .loadRecent(),
                child: const Text('最近'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton(
                key: const Key('historyThisMonthButton'),
                onPressed: () {
                  final now = DateTime.now();
                  final from = DateTime(now.year, now.month);
                  final to = DateTime(now.year, now.month + 1);
                  ref
                      .read(workoutHistoryControllerProvider.notifier)
                      .loadPeriod(from: from, to: to);
                },
                child: const Text('今月'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: state.sessions.isEmpty
              ? const _HistoryMessage(message: 'まだ記録がありません')
              : ListView.separated(
                  itemCount: state.sessions.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final session = state.sessions[index];
                    return InkWell(
                      onTap: () =>
                          context.go(AppRoutePaths.historyDetail(session.id)),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                session.exerciseSummary,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 6),
                              Text(_dateLabel(session.completedAt)),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('${session.setCount}セット'),
                                  Text(
                                    '${session.totalVolumeKg.toStringAsFixed(1)} kg',
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class WorkoutSessionDetailScreen extends ConsumerWidget {
  const WorkoutSessionDetailScreen({super.key, required this.sessionId});

  final String sessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(workoutSessionDetailControllerProvider(sessionId));
    final logout = ref.watch(logoutControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('セッション詳細'),
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
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: detail.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => _HistoryMessage(
                message: error is WorkoutHistoryFailure
                    ? error.message
                    : 'セッション詳細の取得に失敗しました',
              ),
              data: (session) => ListView(
                children: [
                  Text(
                    _dateLabel(session.completedAt),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '総ボリューム ${session.totalVolumeKg.toStringAsFixed(1)} kg',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text('表示値は現在の計算設定による概算値です'),
                  const SizedBox(height: 16),
                  for (final exercise in session.exercises) ...[
                    Text(
                      exercise.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    for (final set in exercise.sets) ...[
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'セット ${set.order}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text('${set.reps}回 / RIR ${set.rir ?? '-'}'),
                              Text(
                                '推定負荷 ${set.estimatedLoadKg.toStringAsFixed(1)} kg',
                              ),
                              Text(
                                'セットボリューム ${set.setVolumeKg.toStringAsFixed(1)} kg',
                              ),
                              Text(
                                'RIR補正 ${set.effortAdjustedVolumeKg.toStringAsFixed(1)} kg',
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                    const SizedBox(height: 8),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HistoryMessage extends StatelessWidget {
  const _HistoryMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }
}

String _dateLabel(DateTime date) {
  return '${date.year}/${_twoDigits(date.month)}/${_twoDigits(date.day)}';
}

String _twoDigits(int value) => value.toString().padLeft(2, '0');

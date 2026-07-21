import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_router.dart';
import '../../auth/application/logout_controller.dart';
import '../application/profile_controller.dart';

class InitialProfileScreen extends ConsumerStatefulWidget {
  const InitialProfileScreen({super.key});

  @override
  ConsumerState<InitialProfileScreen> createState() =>
      _InitialProfileScreenState();
}

class _InitialProfileScreenState extends ConsumerState<InitialProfileScreen> {
  final _displayNameController = TextEditingController();
  final _heightController = TextEditingController();
  final _bodyWeightController = TextEditingController();
  final _experienceController = TextEditingController();
  String? _primaryGoal;

  @override
  void dispose() {
    _displayNameController.dispose();
    _heightController.dispose();
    _bodyWeightController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileControllerProvider);
    final profileState = profile.value;
    final logout = ref.watch(logoutControllerProvider);
    final isSaving = profile.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('プロフィール'),
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
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '初回プロフィール設定',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _displayNameController,
                  decoration: const InputDecoration(
                    labelText: '表示名',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _heightController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: '身長 cm',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  key: const Key('profileBodyWeightField'),
                  controller: _bodyWeightController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: '体重 kg',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _experienceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'トレーニング経験 月',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  key: const Key('profileGoalDropdown'),
                  initialValue: _primaryGoal,
                  decoration: const InputDecoration(
                    labelText: '主要目的',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'hypertrophy',
                      child: Text('筋肥大'),
                    ),
                    DropdownMenuItem(
                      value: 'strength',
                      child: Text('筋力向上'),
                    ),
                    DropdownMenuItem(value: 'other', child: Text('その他')),
                  ],
                  onChanged: isSaving
                      ? null
                      : (value) => setState(() => _primaryGoal = value),
                ),
                const SizedBox(height: 16),
                if (profileState?.errorMessage != null) ...[
                  Text(
                    profileState!.errorMessage!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                FilledButton(
                  onPressed: isSaving ? null : _save,
                  child: isSaving
                      ? const SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('保存する'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    final succeeded = await ref
        .read(profileControllerProvider.notifier)
        .saveInitialProfile(
          displayName: _displayNameController.text,
          heightText: _heightController.text,
          bodyWeightText: _bodyWeightController.text,
          trainingExperienceMonthsText: _experienceController.text,
          primaryGoal: _primaryGoal,
        );

    if (succeeded && mounted) {
      context.go(AppRoutePaths.home);
    }
  }
}

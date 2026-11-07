import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/neo_colors.dart';
import '../../../data/models/application_settings.dart';
import '../../../data/repositories/repetition_repository.dart';
import '../../../data/repositories/settings_repository.dart';
import '../../../data/repositories/test_session_repository.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/neo_box.dart';
import '../../widgets/neo_button.dart';

/// Minimal and clean Settings screen matching Chunk requirements.
/// Includes only App Information, Daily Practice Goal, and safe Reset App Data.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    this.onResetCompleted,
  });

  final VoidCallback? onResetCompleted;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _settingsRepo = SettingsRepository();
  final _sessionRepo = TestSessionRepository();
  final _repetitionRepo = RepetitionRepository();

  ApplicationSettings _settings = const ApplicationSettings();
  bool _loading = true;
  int _todayPracticedSeconds = 0;
  int _todaySessionCount = 0;

  final List<int> _quickGoals = [5, 10, 15, 20, 30, 45, 60];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final s = await _settingsRepo.loadSettings();
      final allSessions = await _sessionRepo.getAllSessions();
      final now = DateTime.now();

      int todaySec = 0;
      int todayCount = 0;
      for (final session in allSessions) {
        if (session.startedAt.year == now.year &&
            session.startedAt.month == now.month &&
            session.startedAt.day == now.day) {
          todaySec += session.actualElapsedDuration;
          todayCount++;
        }
      }

      if (mounted) {
        setState(() {
          _settings = s;
          _todayPracticedSeconds = todaySec;
          _todaySessionCount = todayCount;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _updateGoal(int minutes) async {
    try {
      await _settingsRepo.updateSetting('daily_practice_goal_minutes', minutes);
      setState(() {
        _settings = _settings.copyWith(dailyPracticeGoalMinutes: minutes);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Daily goal updated to $minutes minutes per day.'),
            duration: const Duration(seconds: 2),
            backgroundColor: NeoColors.purple,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update goal: $e')),
        );
      }
    }
  }

  Future<void> _showResetConfirmationDialog() async {
    final confirmationController = TextEditingController();
    bool canProceed = false;

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: NeoColors.background,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: NeoColors.border, width: 3),
            ),
            title: Row(
              children: const [
                Icon(Icons.warning_amber_rounded, color: NeoColors.coral, size: 28),
                SizedBox(width: 10),
                Text(
                  'Reset All App Data?',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'This action will permanently delete all your saved test sessions, repetition records, and performance history.',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, height: 1.4),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '• Practice history & statistics will be reset.\n'
                    '• Daily practice goal will return to 15 minutes.\n'
                    '• Default settings will be restored.\n'
                    '• The 100 bundled practice passages will be preserved.',
                    style: TextStyle(fontSize: 13, color: NeoColors.textSecondary, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'To confirm, type RESET in capital letters below:',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  NeoBox(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                    borderRadius: 8,
                    child: TextField(
                      controller: confirmationController,
                      autofocus: true,
                      style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5),
                      decoration: const InputDecoration(
                        hintText: 'Type RESET here',
                        border: InputBorder.none,
                      ),
                      onChanged: (val) {
                        setDialogState(() {
                          canProceed = val == 'RESET';
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text(
                  'Cancel',
                  style: TextStyle(fontWeight: FontWeight.w800, color: NeoColors.textPrimary),
                ),
              ),
              NeoButton(
                label: 'Confirm Reset',
                icon: const Icon(Icons.delete_forever_rounded, color: Colors.white, size: 18),
                backgroundColor: canProceed ? NeoColors.coral : NeoColors.surfaceSubtle,
                textColor: canProceed ? Colors.white : NeoColors.textSecondary,
                height: 40,
                onPressed: canProceed ? () => Navigator.pop(dialogContext, true) : null,
              ),
            ],
          );
        },
      ),
    );

    confirmationController.dispose();

    if (confirmed == true && mounted) {
      await _performFullAppReset();
    }
  }

  Future<void> _performFullAppReset() async {
    setState(() => _loading = true);

    try {
      // 1. Delete all test sessions
      await _sessionRepo.deleteAllSessions();

      // 2. Delete all repetition records
      await _repetitionRepo.deleteAllRepetitions();

      // 3. Reset settings to default (restores 15 min daily goal)
      await _settingsRepo.resetSettingsToDefaults();

      // 4. Reload local state
      await _load();

      // 5. Notify parent dashboard to refresh
      widget.onResetCompleted?.call();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('App data reset successfully. History cleared and settings restored to default.'),
            backgroundColor: NeoColors.mint,
            duration: Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to reset app data: $e'),
            backgroundColor: NeoColors.coral,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final goalMinutes = _settings.dailyPracticeGoalMinutes > 0
        ? _settings.dailyPracticeGoalMinutes
        : 15;
    final todayMinutes = _todayPracticedSeconds / 60.0;
    final progressFraction = (todayMinutes / goalMinutes).clamp(0.0, 1.0);
    final progressPercent = (progressFraction * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title header
        const Text(
          'Settings',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 4),
        const Text(
          'Manage your daily practice goal, app information, and local data storage.',
          style: TextStyle(color: NeoColors.textSecondary, fontWeight: FontWeight.w600, fontSize: 13.5),
        ),
        const SizedBox(height: 20),

        // SECTION 1: App Information
        _sectionHeading('1. APP INFORMATION', Icons.info_outline_rounded),
        const SizedBox(height: 10),
        NeoBox(
          backgroundColor: Colors.white,
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  const AppLogo(size: 46, compact: true, showTagline: false),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          AppConstants.appName,
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                        ),
                        SizedBox(height: 2),
                        Text(
                          AppConstants.appTagline,
                          style: TextStyle(fontSize: 13, color: NeoColors.textSecondary, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(color: NeoColors.border, height: 26),
              _infoRow('Application Name', AppConstants.appName),
              const SizedBox(height: 10),
              _infoRow('Version', AppConstants.appVersion),
              const SizedBox(height: 10),
              _infoRow('Developer', 'Yash Shukla'),
              const SizedBox(height: 10),
              _infoRow('Architecture', 'Offline-First (Windows SQLite / Browser Persistent)'),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // SECTION 2: Daily Practice Goal
        _sectionHeading('2. DAILY PRACTICE GOAL', Icons.flag_rounded),
        const SizedBox(height: 10),
        NeoBox(
          backgroundColor: Colors.white,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Target Practice Duration',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Set your target typing time for each day (Default: 15 min).',
                        style: const TextStyle(fontSize: 12.5, color: NeoColors.textSecondary, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  NeoBox(
                    backgroundColor: NeoColors.yellow,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    borderRadius: 8,
                    child: Text(
                      '$goalMinutes MIN / DAY',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Today's actual progress card
              NeoBox(
                backgroundColor: NeoColors.surfaceSubtle,
                padding: const EdgeInsets.all(14),
                borderRadius: 10,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Today\'s Progress: ${todayMinutes.toStringAsFixed(1)} of $goalMinutes minutes ($progressPercent%)',
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                        ),
                        Text(
                          '$_todaySessionCount tests today',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: NeoColors.textSecondary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: progressFraction,
                        minHeight: 10,
                        backgroundColor: NeoColors.lavender,
                        color: progressPercent >= 100 ? NeoColors.mint : NeoColors.purple,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              const Text(
                'Select Daily Practice Goal:',
                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _quickGoals.map((m) {
                  final isSelected = goalMinutes == m;
                  return GestureDetector(
                    onTap: () => _updateGoal(m),
                    child: NeoBox(
                      backgroundColor: isSelected ? NeoColors.mint : NeoColors.surfaceSubtle,
                      shadowOffset: isSelected ? const Offset(3, 3) : const Offset(1.5, 1.5),
                      borderRadius: 8,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      child: Text(
                        '$m min',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: isSelected ? NeoColors.textPrimary : NeoColors.textSecondary,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),

        // SECTION 3: Reset App Data (Danger Zone at Bottom)
        _sectionHeading('3. RESET APP DATA', Icons.delete_outline_rounded),
        const SizedBox(height: 10),
        NeoBox(
          backgroundColor: NeoColors.pink,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.warning_rounded, color: NeoColors.coral, size: 26),
                  SizedBox(width: 10),
                  Text(
                    'Danger Zone — Clear History & Reset Settings',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Deleting your data will remove all previous typing test sessions, repetition logs, and custom settings. '
                'The 100 bundled practice passages will remain safe and untouched.',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, height: 1.45),
              ),
              const SizedBox(height: 16),
              NeoButton(
                label: 'Reset App Data…',
                icon: const Icon(Icons.delete_forever_rounded, color: Colors.white, size: 18),
                backgroundColor: NeoColors.coral,
                textColor: Colors.white,
                onPressed: _showResetConfirmationDialog,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _sectionHeading(String title, IconData icon) => Row(
    children: [
      Icon(icon, size: 18, color: NeoColors.textPrimary),
      const SizedBox(width: 8),
      Text(
        title,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 0.5),
      ),
    ],
  );

  Widget _infoRow(String label, String value) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        label,
        style: const TextStyle(fontSize: 13.5, color: NeoColors.textSecondary, fontWeight: FontWeight.w700),
      ),
      Text(
        value,
        style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w900),
      ),
    ],
  );
}

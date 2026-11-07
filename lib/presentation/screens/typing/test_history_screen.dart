import 'package:flutter/material.dart';

import '../../../core/theme/neo_colors.dart';
import '../../../data/models/test_session.dart';
import '../../../data/repositories/test_session_repository.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/neo_box.dart';
import '../../widgets/neo_button.dart';

/// Displays saved test sessions and performance history from local storage.
/// Works identically on Windows Desktop (SQLite) and Flutter Web (localStorage).
class TestHistoryScreen extends StatefulWidget {
  const TestHistoryScreen({super.key});

  @override
  State<TestHistoryScreen> createState() => _TestHistoryScreenState();
}

class _TestHistoryScreenState extends State<TestHistoryScreen> {
  final _sessionRepo = TestSessionRepository();
  List<TestSession> _sessions = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final sessions = await _sessionRepo.getAllSessions();
      if (mounted) {
        setState(() {
          _sessions = sessions;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeoColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _header(),
              const SizedBox(height: 16),
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _sessions.isEmpty
                        ? _emptyState()
                        : _sessionsList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header() => NeoBox(
    backgroundColor: NeoColors.surface,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    child: Row(
      children: [
        NeoButton(
          label: '',
          icon: const Icon(Icons.arrow_back_rounded, color: NeoColors.textPrimary, size: 20),
          backgroundColor: NeoColors.surfaceSubtle,
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          onPressed: () => Navigator.pop(context),
        ),
        const SizedBox(width: 12),
        const AppLogo(size: 38, compact: true, showTagline: false),
        const SizedBox(width: 12),
        const Expanded(
          child: Text(
            'Saved Test History',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: NeoColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
        ),
        NeoBox(
          backgroundColor: NeoColors.mint,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          shadowOffset: const Offset(2, 2),
          borderRadius: 8,
          child: Text(
            '${_sessions.length} SESSIONS',
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900),
          ),
        ),
      ],
    ),
  );

  Widget _emptyState() => Center(
    child: NeoBox(
      backgroundColor: NeoColors.surface,
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.history_toggle_off_rounded, size: 54, color: NeoColors.textSecondary),
          SizedBox(height: 12),
          Text(
            'No Test History Yet',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
          ),
          SizedBox(height: 6),
          Text(
            'Complete a typing test to see your speed, accuracy, and mistake history here.',
            style: TextStyle(fontSize: 14, color: NeoColors.textSecondary, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );

  Widget _sessionsList() => ListView.separated(
    itemCount: _sessions.length,
    separatorBuilder: (_, __) => const SizedBox(height: 12),
    itemBuilder: (context, index) {
      final s = _sessions[index];
      final dateStr = '${s.startedAt.day}/${s.startedAt.month}/${s.startedAt.year} ${s.startedAt.hour.toString().padLeft(2, '0')}:${s.startedAt.minute.toString().padLeft(2, '0')}';

      return NeoBox(
        backgroundColor: NeoColors.surface,
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            NeoBox(
              backgroundColor: s.isCompleted ? NeoColors.mint : NeoColors.yellow,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              borderRadius: 8,
              child: Column(
                children: [
                  Text(
                    '${s.grossWpm.toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                  ),
                  const Text('WPM', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800)),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.passageTitleSnapshot,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$dateStr · ${s.mode.toUpperCase()} · Duration: ${s.actualElapsedDuration}s',
                    style: const TextStyle(fontSize: 12, color: NeoColors.textSecondary, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Accuracy: ${s.accuracy.toStringAsFixed(1)}%',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 2),
                Text(
                  'Errors: ${s.totalErrors}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: s.totalErrors > 0 ? NeoColors.coral : NeoColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}

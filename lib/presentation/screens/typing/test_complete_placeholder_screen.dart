import 'package:flutter/material.dart';

import '../../../core/theme/neo_colors.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/neo_box.dart';
import '../../widgets/neo_button.dart';
import '../passage_library/passage_library_screen.dart';

/// Shown when a typing test session ends successfully.
///
/// Displays a summary of the completed test and offers navigation back to the
/// passage library or dashboard. Full results analysis arrives in Chunk 7.
class TestCompletePlaceholderScreen extends StatelessWidget {
  const TestCompletePlaceholderScreen({
    super.key,
    required this.passageTitle,
    required this.durationMinutes,
    required this.repetitionsCompleted,
    required this.sessionId,
    this.autoLoop = false,
  });

  final String passageTitle;
  final int durationMinutes;
  final int repetitionsCompleted;
  final String sessionId;
  final bool autoLoop;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeoColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── App Logo ──────────────────────────────────────────────
                  const Center(
                    child: AppLogo(size: 52, compact: true, showTagline: true),
                  ),
                  const SizedBox(height: 28),

                  // ── Trophy banner ─────────────────────────────────────────
                  NeoBox(
                    backgroundColor: NeoColors.yellow,
                    padding: const EdgeInsets.symmetric(
                      vertical: 28,
                      horizontal: 24,
                    ),
                    child: Column(
                      children: [
                        const Text(
                          '🏆',
                          style: TextStyle(fontSize: 56),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Test Completed!',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Great work! Your session has been saved.',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: NeoColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Stats grid ────────────────────────────────────────────
                  _statsGrid(),

                  const SizedBox(height: 20),

                  // ── Session saved notice ──────────────────────────────────
                  NeoBox(
                    backgroundColor: NeoColors.mint,
                    shadowOffset: const Offset(3, 3),
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_outline_rounded, size: 22),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Session saved  ·  ID: $sessionId',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ── Coming soon notice ────────────────────────────────────
                  NeoBox(
                    backgroundColor: NeoColors.lavender,
                    shadowOffset: const Offset(3, 3),
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.bar_chart_rounded, size: 22),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Detailed results — WPM, accuracy, mistake analysis — are coming in Chunk 7.',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ── Action buttons ────────────────────────────────────────
                  NeoButton(
                    label: 'Try Another Passage',
                    icon: const Icon(
                      Icons.library_books_rounded,
                      color: NeoColors.textPrimary,
                    ),
                    isFullWidth: true,
                    onPressed: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PassageLibraryScreen(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  NeoButton(
                    label: 'Back to Passage Library',
                    icon: const Icon(
                      Icons.arrow_back_rounded,
                      color: NeoColors.textPrimary,
                    ),
                    backgroundColor: NeoColors.surfaceSubtle,
                    isFullWidth: true,
                    onPressed: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PassageLibraryScreen(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _statsGrid() {
    return Row(
      children: [
        Expanded(
          child: _statCard(
            icon: Icons.repeat_rounded,
            label: 'Repetitions',
            value: '$repetitionsCompleted',
            color: NeoColors.mint,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _statCard(
            icon: Icons.timer_outlined,
            label: 'Duration',
            value: '$durationMinutes min',
            color: NeoColors.yellow,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _statCard(
            icon: Icons.article_outlined,
            label: 'Passage',
            value: passageTitle,
            color: NeoColors.pink,
          ),
        ),
      ],
    );
  }

  Widget _statCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return NeoBox(
      backgroundColor: color,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      child: Column(
        children: [
          Icon(icon, size: 28),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: NeoColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}

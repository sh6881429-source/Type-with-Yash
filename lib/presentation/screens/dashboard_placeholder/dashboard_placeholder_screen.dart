import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/neo_colors.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/keycap_decoration.dart';
import '../../widgets/neo_box.dart';
import '../../widgets/neo_button.dart';
import '../about/about_screen.dart';
import '../passage_library/passage_library_screen.dart';
import '../settings/settings_screen.dart';
import '../typing/test_history_screen.dart';

/// Dashboard Landing Screen
///
/// Implements the desktop navigation frame following Reference Image 1 & 2.
/// Includes Start Test, Print & Save (with full passage printing), Reports, and Settings.
class DashboardPlaceholderScreen extends StatefulWidget {
  const DashboardPlaceholderScreen({super.key});

  @override
  State<DashboardPlaceholderScreen> createState() =>
      _DashboardPlaceholderScreenState();
}

class _DashboardPlaceholderScreenState
    extends State<DashboardPlaceholderScreen> {
  int _selectedIndex = 0;

  final List<({String title, IconData icon})> _navItems = const [
    (title: 'Dashboard', icon: Icons.home_rounded),
    (title: 'Start Test', icon: Icons.play_arrow_rounded),
    (title: 'Print & Save', icon: Icons.print_rounded),
    (title: 'Reports', icon: Icons.bar_chart_rounded),
    (title: 'Settings', icon: Icons.settings_rounded),
    (title: 'About', icon: Icons.info_outline_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeoColors.background,
      body: Row(
        children: [
          // Desktop Left Sidebar
          _buildSidebar(),

          // Main Workspace Area
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Desktop Header Strip
                _buildTopHeader(),

                // Workspace Body
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(32.0),
                    child: _selectedIndex == 1
                        ? const SizedBox(
                            height: 720,
                            child: PassageLibraryScreen(isPrintMode: false),
                          )
                        : _selectedIndex == 2
                            ? const SizedBox(
                                height: 720,
                                child: PassageLibraryScreen(isPrintMode: true),
                              )
                            : _selectedIndex == 3
                                ? const SizedBox(
                                    height: 720,
                                    child: TestHistoryScreen(),
                                  )
                                : _selectedIndex == 4
                                    ? SettingsScreen(
                                        onResetCompleted: () => setState(() {}),
                                      )
                                    : _selectedIndex == 5
                                        ? const AboutScreen()
                                        : _buildMainContent(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 260,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: NeoColors.border, width: 2.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Sidebar Logo Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: NeoColors.border, width: 2.0),
              ),
            ),
            child: const AppLogo(
              size: 44,
              showWordmark: true,
              showTagline: true,
              compact: true,
            ),
          ),

          // Nav Items
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
              itemCount: _navItems.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final item = _navItems[index];
                final bool isSelected = _selectedIndex == index;

                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedIndex = index);
                  },
                  child: NeoBox(
                    backgroundColor: isSelected
                        ? NeoColors.yellow
                        : Colors.transparent,
                    borderColor: isSelected
                        ? NeoColors.border
                        : Colors.transparent,
                    shadowOffset: isSelected ? const Offset(3, 3) : Offset.zero,
                    borderWidth: isSelected ? 2.2 : 0,
                    borderRadius: 10,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        Icon(item.icon, size: 20, color: NeoColors.textPrimary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            item.title,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: isSelected
                                  ? FontWeight.w900
                                  : FontWeight.w700,
                              color: NeoColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Footer keycap decoration
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: KeycapDecoration(scale: 0.7)),
          ),
        ],
      ),
    );
  }

  Widget _buildTopHeader() {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: NeoColors.border, width: 2.5)),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Windows Desktop Practice Edition',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: NeoColors.textSecondary,
            ),
          ),
          Text(
            AppConstants.appTagline,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
              color: NeoColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Welcome Banner Card
        NeoBox(
          backgroundColor: Colors.white,
          borderRadius: 16,
          borderWidth: 2.5,
          shadowOffset: const Offset(6, 6),
          padding: const EdgeInsets.all(28),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Hello, Aspirant!',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: NeoColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Ready to master BSF typing exam speed and accuracy? All app data and practice passages operate 100% locally on your computer.',
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                        color: NeoColors.textSecondary,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        _buildStatusBadge(
                          '100% Offline Ready',
                          NeoColors.mint,
                        ),
                        const SizedBox(width: 10),
                        _buildStatusBadge(
                          'Print & Type Mode Enforced',
                          NeoColors.lavender,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              const AppLogo(size: 80, showWordmark: false),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Two Quick Action Cards (Start Test & Print & Save)
        Row(
          children: [
            Expanded(
              child: NeoBox(
                backgroundColor: NeoColors.yellow,
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.play_circle_fill_rounded, size: 38, color: NeoColors.textPrimary),
                    const SizedBox(height: 12),
                    const Text('Start Typing Test', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 6),
                    const Text(
                      'Select an offline passage and begin your timed test with accurate speed and error tracking.',
                      style: TextStyle(color: NeoColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w600, height: 1.4),
                    ),
                    const SizedBox(height: 16),
                    NeoButton(
                      label: 'Start Test →',
                      backgroundColor: Colors.white,
                      onPressed: () => setState(() => _selectedIndex = 1),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: NeoBox(
                backgroundColor: NeoColors.lavender,
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.print_rounded, size: 38, color: NeoColors.textPrimary),
                    const SizedBox(height: 12),
                    const Text('Print a Passage', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 6),
                    const Text(
                      'Browse all passages, preview text, and print to paper to practice with a blank screen.',
                      style: TextStyle(color: NeoColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w600, height: 1.4),
                    ),
                    const SizedBox(height: 16),
                    NeoButton(
                      label: 'Print & Save →',
                      backgroundColor: Colors.white,
                      onPressed: () => setState(() => _selectedIndex = 2),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Overview / Help Card
        NeoBox(
          backgroundColor: NeoColors.surfaceSubtle,
          borderRadius: 16,
          borderWidth: 2.5,
          shadowOffset: const Offset(5, 5),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'BSF Typing Exam Guidelines & Workflow',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: NeoColors.textPrimary,
                ),
              ),
              const SizedBox(height: 14),
              _buildCheckItem(
                'Step 1: Go to "Print & Save" to print out the passage onto paper',
                true,
              ),
              _buildCheckItem(
                'Step 2: Place the printed paper beside your keyboard',
                true,
              ),
              _buildCheckItem(
                'Step 3: Go to "Start Test", select the passage, and type into the blank screen',
                true,
              ),
              _buildCheckItem(
                'Step 4: Review your exact Gross WPM, Net WPM, and error analysis',
                true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: NeoColors.border, width: 1.8),
        boxShadow: const [
          BoxShadow(
            color: NeoColors.shadow,
            offset: Offset(2, 2),
            blurRadius: 0,
          ),
        ],
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w800,
          color: NeoColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildCheckItem(String text, bool checked) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            checked ? Icons.check_box_rounded : Icons.check_box_outline_blank,
            size: 20,
            color: checked ? NeoColors.purple : NeoColors.textSecondary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: NeoColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

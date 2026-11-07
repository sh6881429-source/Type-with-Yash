import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/neo_colors.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/neo_box.dart';

/// Comprehensive About Screen for Type with Yash.
///
/// Features:
/// 1. Developer Profile (Yash Shukla)
/// 2. About the Application (Philosophy, Offline-first, Exam Simulation)
/// 3. Complete Features Breakdown
/// 4. How the Typing Test Works (10-Step Workflow)
/// 5. Complete Scoring Algorithm & Mathematical Formulas
/// 6. Practice Mode vs Exam Simulation Mode Comparison
/// 7. Privacy & Local Storage Policy
/// 8. Quick Start Guide
/// 9. Expandable FAQ with 10 questions
class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  // Track expanded state for FAQ items
  final Map<int, bool> _faqExpanded = {};

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Page Title & Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'About Type with Yash',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
                ),
                SizedBox(height: 4),
                Text(
                  'Complete guide, scoring methodology, architecture, and developer profile.',
                  style: TextStyle(
                    color: NeoColors.textSecondary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13.5,
                  ),
                ),
              ],
            ),
            NeoBox(
              backgroundColor: NeoColors.yellow,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              borderRadius: 8,
              child: const Text(
                'v${AppConstants.appVersion}',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // SECTION 1: Developer Profile
        _sectionHeader('1. DEVELOPER PROFILE', Icons.person_rounded),
        const SizedBox(height: 10),
        NeoBox(
          backgroundColor: Colors.white,
          padding: const EdgeInsets.all(22),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: NeoColors.yellow,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: NeoColors.border, width: 2.5),
                  boxShadow: const [
                    BoxShadow(
                      color: NeoColors.shadow,
                      offset: Offset(3, 3),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'YS',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: NeoColors.textPrimary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Yash Shukla',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: NeoColors.mint,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: NeoColors.border,
                              width: 1.5,
                            ),
                          ),
                          child: const Text(
                            'Creator & Developer',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                              color: NeoColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Creator and developer of Type with Yash. Built to provide a dedicated, distraction-free, '
                      'privacy-preserving typing practice environment designed specifically for competitive exam aspirants '
                      '(BSF, SSC, Railway, State Police, and typing certification tests).',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: NeoColors.textPrimary,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: NeoColors.surfaceSubtle,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: NeoColors.border, width: 1.5),
                      ),
                      child: Row(
                        children: const [
                          Icon(
                            Icons.verified_user_rounded,
                            size: 18,
                            color: NeoColors.purple,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Core Focus: Offline-first architecture, realistic exam paper-to-screen simulation, '
                              'mathematical scoring accuracy, and respectful data privacy.',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: NeoColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // SECTION 2: About the Application
        _sectionHeader('2. ABOUT THE APPLICATION', Icons.apps_rounded),
        const SizedBox(height: 10),
        NeoBox(
          backgroundColor: Colors.white,
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const AppLogo(size: 48, compact: true, showTagline: false),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Type with Yash',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Practice Today. Type Tomorrow.',
                          style: TextStyle(
                            fontSize: 13,
                            color: NeoColors.purple,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _tagBadge('Offline-First', NeoColors.mint),
                  const SizedBox(width: 8),
                  _tagBadge('Windows + Web', NeoColors.lavender),
                ],
              ),
              const Divider(color: NeoColors.border, height: 26),
              const Text(
                'Purpose & Philosophy',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 6),
              const Text(
                'Type with Yash is a dedicated typing master application built for aspirants preparing for government and '
                'competitive speed typing tests, including BSF Head Constable Ministerial (HCM), SSC CHSL / CGL, Railway NTPC, '
                'Allahabad High Court RO/ARO, and state government examinations.\n\n'
                'Core Philosophy: Authentic exam simulation. In real government typing exams, candidates are given a physical '
                'printed sheet of paper placed beside their keyboard, while the computer screen displays only a blank typing input box '
                'with a countdown timer. Type with Yash enforces this exact discipline by strictly keeping the reference passage off '
                'the typing workspace.',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _infoCard(
                      'Windows Desktop',
                      'Native 64-bit application with embedded SQLite database (type_with_yash.db). Runs 100% offline with zero dependencies.',
                      NeoColors.yellow,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _infoCard(
                      'Flutter Web Preview',
                      'Browser preview with persistent local storage. Identical semi-global sequence alignment engine and scoring algorithms.',
                      NeoColors.mint,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // SECTION 3: Complete Features Breakdown
        _sectionHeader('3. COMPLETE FEATURES', Icons.featured_play_list_rounded),
        const SizedBox(height: 10),
        NeoBox(
          backgroundColor: Colors.white,
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _featureRow(
                '1. Interactive Dashboard',
                'Quick-launch cards for starting tests or printing passages, live offline indicators, exam workflow guidance, and instant navigation.',
                Icons.dashboard_rounded,
                NeoColors.yellow,
              ),
              const SizedBox(height: 14),
              _featureRow(
                '2. Complete Typing Master Engine',
                'Timed typing workspace with visible cursor, countdown timer, repetition counter, automatic passage looping for longer tests, '
                    'partial repetition handling upon time expiration, and clear/cancel actions.',
                Icons.keyboard_rounded,
                NeoColors.mint,
              ),
              const SizedBox(height: 14),
              _featureRow(
                '3. Offline Passage Library',
                '100 preloaded high-quality passages across General Knowledge, History, Science, Literature, Law, and Technology. '
                    'Categorized by difficulty (Easy, Medium, Hard) with word/character counts, live search, random picker, and repeat-last shortcut.',
                Icons.library_books_rounded,
                NeoColors.lavender,
              ),
              const SizedBox(height: 14),
              _featureRow(
                '4. Test History & Performance Reports',
                'Complete local log of all completed test sessions. View historical Gross WPM, Net WPM, accuracy progression, and detailed per-repetition records.',
                Icons.bar_chart_rounded,
                NeoColors.pink,
              ),
              const SizedBox(height: 14),
              _featureRow(
                '5. In-Depth Error & Analytics Breakdown',
                'Semi-global sequence alignment evaluates typed text character-by-character. Transparently categorizes Substitutions, Omissions, and Insertions. '
                    'Untyped tail text is never counted as an error.',
                Icons.analytics_rounded,
                NeoColors.yellow,
              ),
              const SizedBox(height: 14),
              _featureRow(
                '6. Print & Save Mode',
                'One-click print preparation for all 100 passages. Generates a standard A4 layout complete with candidate header fields '
                    '(Candidate Name, Roll No., Date, Batch) ready for physical printing or PDF export.',
                Icons.print_rounded,
                NeoColors.mint,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // SECTION 4: How the Typing Test Works (10-Step Sequence)
        _sectionHeader(
          '4. HOW THE TYPING TEST WORKS (10-STEP WORKFLOW)',
          Icons.alt_route_rounded,
        ),
        const SizedBox(height: 10),
        NeoBox(
          backgroundColor: Colors.white,
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _workflowStep(
                1,
                'Select a Passage',
                'Browse the 100 bundled passages under "Start Test" or "Print & Save" by difficulty or category.',
              ),
              _workflowStep(
                2,
                'Print to Paper (Recommended for Real Exam Practice)',
                'Open "Print & Save", select the passage, and click "Print Passage". Place the printed A4 paper beside your keyboard.',
              ),
              _workflowStep(
                3,
                'Configure Test Duration',
                'Choose 5, 10, 15, or 30 minutes, or enter a custom duration in minutes to match your exam requirement.',
              ),
              _workflowStep(
                4,
                'Select Practice or Exam Simulation Mode',
                'Choose Practice Mode (for learning and live editing) or Exam Simulation Mode (strict exam constraints).',
              ),
              _workflowStep(
                5,
                'Begin Typing',
                'Click "Start Test". The countdown timer begins automatically on your first keystroke or immediately upon entering.',
              ),
              _workflowStep(
                6,
                'The Blank Typing Box',
                'The reference passage is NEVER displayed inside the typing workspace. You type directly looking at your physical paper into the blank box.',
              ),
              _workflowStep(
                7,
                'Automatic Passage Looping',
                'If you finish typing the full passage before the timer expires, the engine records Repetition 1 and loops back to the start seamlessly.',
              ),
              _workflowStep(
                8,
                'Time Expiration',
                'When the timer reaches 00:00, the test finishes instantly and locks the input box to prevent post-test edits.',
              ),
              _workflowStep(
                9,
                'Sequence Alignment Scoring',
                'The scoring engine executes semi-global sequence alignment across all repetitions to compute exact Gross WPM, Net WPM, Accuracy, and errors.',
              ),
              _workflowStep(
                10,
                'Review & Improve',
                'Inspect your speed and detailed error breakdown (Substitutions, Omissions, Insertions) on the Results screen to target improvements.',
                isLast: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // SECTION 5: Complete Scoring Algorithm & Mathematical Formulas
        _sectionHeader(
          '5. COMPLETE SCORING ALGORITHM',
          Icons.calculate_rounded,
        ),
        const SizedBox(height: 10),
        NeoBox(
          backgroundColor: Colors.white,
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Transparent Mathematical Formulas & Standards',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 4),
              const Text(
                'Type with Yash strictly implements official government examination and international typing standards.',
                style: TextStyle(
                  color: NeoColors.textSecondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 16),

              // Formula Cards
              _formulaBox(
                title: 'Standard Word Length',
                formula: '1 Standard Word = 5 Keystrokes (Characters)',
                description:
                    'All letters, numbers, punctuation marks, and spaces count as characters. Word count is strictly (Total Typed Characters / 5).',
                color: NeoColors.yellow,
              ),
              const SizedBox(height: 12),
              _formulaBox(
                title: 'Gross Words Per Minute (Gross WPM)',
                formula:
                    'Gross WPM = (Total Typed Characters / 5) / Elapsed Minutes',
                description:
                    'Measures pure raw typing speed without error penalties. Elapsed minutes is calculated with fractional second precision.',
                color: NeoColors.mint,
              ),
              const SizedBox(height: 12),
              _formulaBox(
                title: 'Accuracy Percentage',
                formula:
                    'Accuracy (%) = (Correct Characters / Total Attempted Characters) * 100',
                description:
                    'Measures character accuracy across all attempted typing keystrokes. Evaluated character-by-character via sequence alignment.',
                color: NeoColors.lavender,
              ),
              const SizedBox(height: 12),
              _formulaBox(
                title: 'BSF HCM Net WPM & 5% Error Tolerance',
                formula:
                    'Allowed Errors = floor(0.05 × Gross Words)\nPenalty Words = 10 × max(0, Actual Errors - Allowed Errors)\nNet WPM = max(0, Gross Words - Penalty Words) / Elapsed Minutes',
                description:
                    'Under BSF Head Constable (Ministerial) rules, errors up to 5% of gross words are ignored. For each error exceeding 5%, 10 words are deducted from the gross count (subtracting 1 WPM per excess error in a 10-minute test). Minimum qualifying speed is 35 WPM (English) with 95% accuracy.',
                color: NeoColors.pink,
              ),
              const SizedBox(height: 12),
              _formulaBox(
                title: 'General Practice Net WPM',
                formula:
                    'Net WPM = max(0, Gross WPM - (Total Errors / Elapsed Minutes))',
                description:
                    'Standard practice scoring deduction. When error penalty is turned off in practice mode, Net WPM equals Gross WPM.',
                color: NeoColors.lavender,
              ),
              const SizedBox(height: 16),

              const Divider(color: NeoColors.border, height: 24),
              const Text(
                'Error Classification & Policy',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              _bulletPoint(
                'Substitutions',
                'Typing the wrong character in place of the expected reference character (e.g. typing "teh" instead of "the").',
              ),
              _bulletPoint(
                'Omissions',
                'Skipping characters or words that were present in the reference passage within the attempted typing span.',
              ),
              _bulletPoint(
                'Insertions',
                'Typing extraneous characters or words that do not exist in the reference passage.',
              ),
              _bulletPoint(
                'Semi-Global Sequence Alignment',
                'Type with Yash uses dynamic programming sequence alignment. A single mistake or missing space will not desynchronize subsequent words.',
              ),
              _bulletPoint(
                'Untyped Remainder Policy',
                'When the test timer expires, untyped remainder characters at the end of the passage are classified as untypedRemainderCharacters and are NEVER counted as errors.',
              ),
              _bulletPoint(
                'Total Errors Sum',
                'Total Errors = Substitutions + Omissions + Insertions. All calculations are consistent and transparent.',
              ),
              _bulletPoint(
                'Backspace Policy',
                'In Practice Mode, backspace editing is fully permitted. Corrected typos do not count as errors. In Exam Mode, backspace conforms to exam constraints.',
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // SECTION 6: Practice Mode vs Exam Simulation Mode
        _sectionHeader(
          '6. PRACTICE MODE VS EXAM SIMULATION MODE',
          Icons.compare_arrows_rounded,
        ),
        const SizedBox(height: 10),
        NeoBox(
          backgroundColor: Colors.white,
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Table(
                border: TableBorder.all(
                  color: NeoColors.border,
                  width: 1.8,
                  borderRadius: BorderRadius.circular(8),
                ),
                columnWidths: const {
                  0: FlexColumnWidth(1.2),
                  1: FlexColumnWidth(1.4),
                  2: FlexColumnWidth(1.4),
                },
                children: [
                  TableRow(
                    decoration: const BoxDecoration(color: NeoColors.yellow),
                    children: [
                      _tableHeaderCell('Feature / Criterion'),
                      _tableHeaderCell('Practice Mode'),
                      _tableHeaderCell('Exam Simulation Mode'),
                    ],
                  ),
                  _tableDataRow(
                    'Reference Text',
                    'Preview available in library before starting',
                    'Strictly hidden (physical paper sheet required)',
                  ),
                  _tableDataRow(
                    'Backspace / Editing',
                    'Fully allowed with unlimited corrections',
                    'Constrained to match target exam hall rules',
                  ),
                  _tableDataRow(
                    'Timer Display',
                    'Visible countdown with progress indicator',
                    'Standard exam countdown display',
                  ),
                  _tableDataRow(
                    'Scoring & Accuracy',
                    'Educational feedback & speed analysis',
                    'Strict qualifying threshold (e.g. 35 WPM / 90% accuracy)',
                  ),
                  _tableDataRow(
                    'Primary Goal',
                    'Building muscle memory, rhythm & confidence',
                    'Authentic exam day mental conditioning',
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // SECTION 7: Privacy & Local Storage Policy
        _sectionHeader(
          '7. PRIVACY & LOCAL STORAGE POLICY',
          Icons.security_rounded,
        ),
        const SizedBox(height: 10),
        NeoBox(
          backgroundColor: Colors.white,
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: NeoColors.mint,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: NeoColors.border, width: 2),
                    ),
                    child: const Icon(
                      Icons.lock_outline_rounded,
                      size: 26,
                      color: NeoColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Text(
                      '100% Offline by Design — Zero Cloud Telemetry',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Type with Yash is engineered with absolute respect for candidate privacy:\n\n'
                '• No External Network Calls: The app never sends your keystrokes, personal info, or test scores to any cloud server.\n'
                '• Zero Third-Party Trackers: No Firebase, Supabase, Google Analytics, or third-party telemetry libraries.\n'
                '• Local Storage Architecture: Windows Desktop persists data in a local SQLite file (type_with_yash.db). Flutter Web preview stores data locally in your browser.\n'
                '• Full Data Ownership: Your test history belongs entirely to you. You can wipe your history at any time from Settings -> Reset App Data.',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // SECTION 8: Quick Start Guide
        _sectionHeader('8. QUICK START GUIDE', Icons.rocket_launch_rounded),
        const SizedBox(height: 10),
        NeoBox(
          backgroundColor: Colors.white,
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _guideStep(
                'Step 1: Browse Passages',
                'Explore the 100 bundled passages under "Start Test" or "Print & Save". Filter by difficulty: Easy, Medium, or Hard.',
              ),
              _guideStep(
                'Step 2: Print Reference Sheet',
                'Click "Print Passage" on any passage card to get a clean A4 printout with candidate header lines.',
              ),
              _guideStep(
                'Step 3: Position Your Sheet',
                'Place the printed sheet to the left or right of your keyboard at a comfortable reading angle.',
              ),
              _guideStep(
                'Step 4: Configure Duration',
                'Select 5, 10, or 15 minutes to match your target exam specification (e.g. 10 minutes for BSF HCM).',
              ),
              _guideStep(
                'Step 5: Focus & Type',
                'Hit Start Test and type continuously without looking at the monitor until the timer sounds.',
              ),
              _guideStep(
                'Step 6: Check Your Score',
                'Inspect your Gross WPM, Net WPM, and detailed error breakdown to target your next practice session.',
                isLast: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // SECTION 9: Frequently Asked Questions (FAQ)
        _sectionHeader(
          '9. FREQUENTLY ASKED QUESTIONS (FAQ)',
          Icons.help_outline_rounded,
        ),
        const SizedBox(height: 10),
        Column(
          children: [
            for (int i = 0; i < _faqItems.length; i++)
              _buildFaqItem(i, _faqItems[i]),
          ],
        ),
        const SizedBox(height: 36),
      ],
    );
  }

  Widget _buildFaqItem(int index, ({String question, String answer}) item) {
    final isExpanded = _faqExpanded[index] ?? false;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: NeoBox(
        backgroundColor: isExpanded ? NeoColors.surfaceSubtle : Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () {
                setState(() {
                  _faqExpanded[index] = !isExpanded;
                });
              },
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isExpanded
                          ? NeoColors.yellow
                          : NeoColors.surfaceSubtle,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: NeoColors.border, width: 1.5),
                    ),
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item.question,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Icon(
                    isExpanded
                        ? Icons.expand_less_rounded
                        : Icons.expand_more_rounded,
                    color: NeoColors.textPrimary,
                    size: 22,
                  ),
                ],
              ),
            ),
            if (isExpanded) ...[
              const Divider(color: NeoColors.border, height: 18),
              Padding(
                padding: const EdgeInsets.only(left: 36, top: 2),
                child: Text(
                  item.answer,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: NeoColors.textPrimary,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, IconData icon) => Row(
    children: [
      Icon(icon, size: 18, color: NeoColors.textPrimary),
      const SizedBox(width: 8),
      Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),
    ],
  );

  Widget _tagBadge(String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: NeoColors.border, width: 1.8),
    ),
    child: Text(
      label,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w900,
        color: NeoColors.textPrimary,
      ),
    ),
  );

  Widget _infoCard(String title, String desc, Color color) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: NeoColors.surfaceSubtle,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: NeoColors.border, width: 1.5),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(color: NeoColors.border, width: 1.5),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          desc,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: NeoColors.textSecondary,
            height: 1.4,
          ),
        ),
      ],
    ),
  );

  Widget _featureRow(
    String title,
    String desc,
    IconData icon,
    Color iconBgColor,
  ) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconBgColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: NeoColors.border, width: 1.8),
        ),
        child: Icon(icon, size: 20, color: NeoColors.textPrimary),
      ),
      const SizedBox(width: 14),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 3),
            Text(
              desc,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: NeoColors.textSecondary,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    ],
  );

  Widget _workflowStep(
    int step,
    String title,
    String desc, {
    bool isLast = false,
  }) => Padding(
    padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: NeoColors.yellow,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: NeoColors.border, width: 1.8),
          ),
          child: Text(
            '$step',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                desc,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: NeoColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _formulaBox({
    required String title,
    required String formula,
    required String description,
    required Color color,
  }) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: NeoColors.surfaceSubtle,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: NeoColors.border, width: 1.8),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: NeoColors.border, width: 1.5),
          ),
          child: Text(
            formula,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              fontFamily: 'Courier',
              letterSpacing: 0.2,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          description,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: NeoColors.textSecondary,
            height: 1.4,
          ),
        ),
      ],
    ),
  );

  Widget _bulletPoint(String term, String detail) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '• ',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
        ),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 13,
                color: NeoColors.textPrimary,
                height: 1.4,
              ),
              children: [
                TextSpan(
                  text: '$term: ',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                TextSpan(
                  text: detail,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );

  Widget _tableHeaderCell(String text) => Padding(
    padding: const EdgeInsets.all(10),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 12.5,
        fontWeight: FontWeight.w900,
        color: NeoColors.textPrimary,
      ),
    ),
  );

  TableRow _tableDataRow(String col1, String col2, String col3) => TableRow(
    children: [
      Padding(
        padding: const EdgeInsets.all(10),
        child: Text(
          col1,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(10),
        child: Text(
          col2,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: NeoColors.textSecondary,
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(10),
        child: Text(
          col3,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: NeoColors.textPrimary,
          ),
        ),
      ),
    ],
  );

  Widget _guideStep(String title, String desc, {bool isLast = false}) => Padding(
    padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.check_circle_rounded,
          color: NeoColors.mint,
          size: 18,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 13,
                color: NeoColors.textPrimary,
                height: 1.4,
              ),
              children: [
                TextSpan(
                  text: '$title: ',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                TextSpan(
                  text: desc,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );

  static final List<({String question, String answer})> _faqItems = [
    (
      question:
          'Why does the application not show the reference passage on screen while typing?',
      answer:
          'In real competitive typing examinations (BSF HCM, SSC CHSL, Railway NTPC, High Court exams), candidates are given a printed sheet of physical paper placed next to the keyboard. Displaying the text on screen creates an unrealistic habit. Type with Yash enforces true exam hall conditions by default.',
    ),
    (
      question: 'How is 1 standard word calculated?',
      answer:
          'In accordance with international typing standards and government typing examination boards, 1 standard word equals exactly 5 keystrokes (characters), including spaces and punctuation marks.',
    ),
    (
      question: 'What is the difference between Gross WPM and Net WPM?',
      answer:
          'Gross WPM measures your raw typing speed: (Total Characters / 5) / Minutes. Net WPM deducts penalties for mistakes made: Gross WPM - (Total Errors / Minutes). Net WPM represents your true exam qualifying speed.',
    ),
    (
      question:
          'If I make a typo, will all my subsequent words be marked as errors?',
      answer:
          'No. Type with Yash uses a semi-global sequence alignment algorithm that realigns your keystrokes after an error, ensuring that single mistakes or omitted characters do not cascade through the rest of your score.',
    ),
    (
      question:
          'Does the application penalize me for the untyped remainder of a passage when time runs out?',
      answer:
          'Absolutely not. The scoring engine calculates omissions only within the span of text you actually attempted to type. The remainder of the passage is recognized as untyped tail text and is not penalized.',
    ),
    (
      question:
          'What happens if I finish typing a passage before the timer expires?',
      answer:
          'The typing engine automatically records your completed repetition and loops back to the beginning of the passage so you can continue typing without stopping until the full timer duration concludes.',
    ),
    (
      question:
          'Can I use Type with Yash completely offline without an internet connection?',
      answer:
          'Yes. The Windows Desktop edition uses an embedded local SQLite database and requires zero internet access. All 100 passages, engine logic, and performance histories run 100% locally on your machine.',
    ),
    (
      question:
          'How do I practice for the BSF Head Constable Ministerial (HCM) typing test?',
      answer:
          'BSF HCM requires a minimum speed of 35 WPM in English with at least 90% accuracy over a 10-minute duration. We recommend printing a medium difficulty passage, setting a 10-minute timer, and aiming for 40+ Gross WPM with fewer than 10 total errors.',
    ),
    (
      question: 'How can I clear my practice history and start fresh?',
      answer:
          'Navigate to Settings, scroll to "Reset App Data", and confirm by typing RESET. This will safely delete your past test sessions and reset your stats while preserving the 100 preloaded passages.',
    ),
    (
      question: 'Can I export my test results or print passages to PDF?',
      answer:
          'Yes. Under "Print & Save", you can preview and print any passage directly to your physical printer or export it as a clean PDF document with candidate header fields.',
    ),
  ];
}

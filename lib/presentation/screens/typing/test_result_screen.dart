import 'package:flutter/material.dart';

import '../../../core/theme/neo_colors.dart';
import '../../../data/models/passage.dart';
import '../../../data/models/repetition.dart';
import '../../../data/models/test_session.dart';
import '../../../data/repositories/repetition_repository.dart';
import '../../../data/services/scoring_service.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/neo_box.dart';
import '../../widgets/neo_button.dart';
import '../passage_library/passage_library_screen.dart';
import 'test_history_screen.dart';
import 'typing_test_screen.dart';

/// Complete, accurate results screen for both Windows Desktop and Flutter Web.
/// Displays Gross WPM, Net WPM, Accuracy, character/word error breakdown,
/// repetition-by-repetition results, and full reference vs typed comparison.
class TestResultScreen extends StatefulWidget {
  const TestResultScreen({
    super.key,
    required this.session,
    required this.passage,
    this.sessionScore,
    this.typedText,
  });

  final TestSession session;
  final Passage passage;
  final SessionScore? sessionScore;
  final String? typedText;

  @override
  State<TestResultScreen> createState() => _TestResultScreenState();
}

class _TestResultScreenState extends State<TestResultScreen> {
  final _repetitionRepo = RepetitionRepository();
  List<Repetition> _repetitions = [];
  bool _loadingRepetitions = true;
  bool _showCalculationDetails = false;

  @override
  void initState() {
    super.initState();
    _loadRepetitions();
  }

  Future<void> _loadRepetitions() async {
    try {
      final reps = await _repetitionRepo.getRepetitionsBySession(widget.session.id);
      if (mounted) {
        setState(() {
          _repetitions = reps;
          _loadingRepetitions = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingRepetitions = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.session;
    final score = widget.sessionScore;
    final bsf = _getBsfResult(s, score);

    return Scaffold(
      backgroundColor: NeoColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _header(),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _heroSummaryCard(s),
                      const SizedBox(height: 14),
                      _bsfQualificationBanner(bsf),
                      const SizedBox(height: 18),
                      _scoreMetricsGrid(s, bsf),
                      const SizedBox(height: 18),
                      _howScoreCalculatedCard(s, score),
                      const SizedBox(height: 18),
                      _errorAnalysisCard(s, score, bsf),
                      const SizedBox(height: 18),
                      if (!_loadingRepetitions && _repetitions.isNotEmpty) ...[
                        _repetitionBreakdownCard(),
                        const SizedBox(height: 18),
                      ],
                      _textComparisonCard(),
                      const SizedBox(height: 24),
                      _actionButtons(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  BsfHcmResult _getBsfResult(TestSession s, SessionScore? score) {
    if (score?.bsfHcmResult != null) return score!.bsfHcmResult!;
    final elapsedMin = (s.actualElapsedDuration > 0 ? s.actualElapsedDuration : 600) / 60.0;
    return ScoringService.calculateBsfHcmMetrics(
      totalKeystrokes: s.totalCharactersTyped,
      totalErrors: s.totalErrors,
      elapsedMinutes: elapsedMin,
    );
  }

  Widget _bsfQualificationBanner(BsfHcmResult bsf) {
    final isQualified = bsf.isQualified;
    return NeoBox(
      backgroundColor: isQualified ? NeoColors.mint : NeoColors.pink,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(
        children: [
          Icon(
            isQualified ? Icons.verified_rounded : Icons.warning_amber_rounded,
            size: 32,
            color: NeoColors.textPrimary,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      isQualified
                          ? 'BSF HCM STATUS: QUALIFIED (PASS)'
                          : 'BSF HCM STATUS: NOT QUALIFIED (FAIL)',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: NeoColors.border, width: 1.5),
                      ),
                      child: const Text(
                        'English: ≥35 Net WPM',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  isQualified
                      ? 'Qualified! Your Net Speed is ${bsf.netWpm.toStringAsFixed(1)} WPM (Required: ≥35 WPM). Allowed errors: ${bsf.allowedErrors}, Actual: ${bsf.totalErrors}.'
                      : 'Not qualified. BSF HCM requirement: ≥35 WPM Net Speed. Current Net Speed: ${bsf.netWpm.toStringAsFixed(1)} WPM (Allowed errors: ${bsf.allowedErrors}, Excess errors: ${bsf.excessErrors}).',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: NeoColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
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
            'Test Results & Analysis',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: NeoColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
        ),
        NeoButton(
          label: 'Test History',
          icon: const Icon(Icons.history_rounded, size: 18, color: NeoColors.textPrimary),
          backgroundColor: NeoColors.lavender,
          height: 38,
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TestHistoryScreen()),
          ),
        ),
      ],
    ),
  );

  Widget _heroSummaryCard(TestSession s) => NeoBox(
    backgroundColor: NeoColors.yellow,
    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
    child: Row(
      children: [
        const Text('🏆', style: TextStyle(fontSize: 48)),
        const SizedBox(width: 18),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                s.isCompleted ? 'Test Completed!' : 'Attempt Saved (Incomplete)',
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 4),
              Text(
                'Passage: "${s.passageTitleSnapshot}" · Mode: ${s.mode.toUpperCase()}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: NeoColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Duration: ${s.actualElapsedDuration}s elapsed of ${s.configuredDuration}s configured · Ratio: ${s.characterToWordRatio} keystrokes/word',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _scoreMetricsGrid(TestSession s, BsfHcmResult bsf) => LayoutBuilder(
    builder: (context, constraints) {
      final width = constraints.maxWidth;
      final columns = width >= 800 ? 4 : 2;

      final items = [
        _metricBox('GROSS SPEED', '${s.grossWpm.toStringAsFixed(1)} WPM', NeoColors.mint, Icons.speed_rounded),
        _metricBox('NET SPEED', '${s.netWpm.toStringAsFixed(1)} WPM', NeoColors.yellow, Icons.check_circle_outline_rounded),
        _metricBox('ACCURACY', '${bsf.accuracy.toStringAsFixed(1)}%', NeoColors.lavender, Icons.track_changes_rounded),
        _metricBox('TOTAL ERRORS', '${s.totalErrors}', s.totalErrors == 0 ? NeoColors.mint : NeoColors.pink, Icons.error_outline_rounded),
      ];

      if (columns == 4) {
        return Row(
          children: items
              .map((it) => Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 5), child: it)))
              .toList(),
        );
      }

      return Column(
        children: [
          Row(children: [Expanded(child: items[0]), const SizedBox(width: 10), Expanded(child: items[1])]),
          const SizedBox(height: 10),
          Row(children: [Expanded(child: items[2]), const SizedBox(width: 10), Expanded(child: items[3])]),
        ],
      );
    },
  );

  Widget _metricBox(String label, String value, Color color, IconData icon) => NeoBox(
    backgroundColor: color,
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: NeoColors.textSecondary)),
            Icon(icon, size: 20, color: NeoColors.textPrimary),
          ],
        ),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900)),
      ],
    ),
  );

  Widget _howScoreCalculatedCard(TestSession s, SessionScore? score) {
    final bsf = _getBsfResult(s, score);
    final elapsedSec = s.actualElapsedDuration;
    final elapsedMin = (elapsedSec / 60.0).toStringAsFixed(2);
    final ratio = s.characterToWordRatio > 0 ? s.characterToWordRatio : 5;
    final untypedRemainder = score?.untypedRemainderCharacters ?? 0;

    return NeoBox(
      backgroundColor: NeoColors.surface,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => setState(() => _showCalculationDetails = !_showCalculationDetails),
            borderRadius: BorderRadius.circular(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    Icon(Icons.calculate_outlined, size: 22),
                    SizedBox(width: 8),
                    Text(
                      'BSF HCM Scoring Criteria & Calculation Breakdown',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
                Icon(
                  _showCalculationDetails ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                  size: 24,
                  color: NeoColors.textPrimary,
                ),
              ],
            ),
          ),
          if (_showCalculationDetails) ...[
            const Divider(color: NeoColors.border, height: 22),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: NeoColors.surfaceSubtle,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: NeoColors.border, width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('1. INPUT METRICS & STANDARD WORDS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 4),
                  Text('• Total Keystrokes: ${s.totalCharactersTyped}'),
                  Text('• Standard Word Definition: $ratio keystrokes = 1 word'),
                  Text('• Gross Words: ${s.totalCharactersTyped} / $ratio = ${bsf.grossWords.toStringAsFixed(1)} words'),
                  Text('• Actual Elapsed Time: ${elapsedSec}s ($elapsedMin min)'),
                  Text('• Actual Errors: ${s.omissions} omissions + ${s.substitutions} substitutions + ${s.insertions} insertions = ${s.totalErrors} total'),
                  if (untypedRemainder > 0)
                    Text('• Untyped Passage Tail: $untypedRemainder characters (NOT penalized as errors)'),
                  const SizedBox(height: 12),

                  const Text('2. GROSS SPEED FORMULA', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 4),
                  const Text(
                    'Gross WPM = (Total Keystrokes / 5) / Elapsed Minutes',
                    style: TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Calculation: (${s.totalCharactersTyped} / $ratio) / $elapsedMin = ${bsf.grossWpm.toStringAsFixed(1)} WPM',
                    style: const TextStyle(fontWeight: FontWeight.w700, color: NeoColors.textSecondary),
                  ),
                  const SizedBox(height: 12),

                  const Text('3. BSF HCM 5% ERROR TOLERANCE & EXCESS PENALTY', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 4),
                  Text('• Allowed Errors (5% of Gross Words): floor(0.05 × ${bsf.grossWords.toStringAsFixed(1)}) = ${bsf.allowedErrors} errors (ignored)'),
                  Text('• Excess Errors: max(0, ${s.totalErrors} errors - ${bsf.allowedErrors} allowed) = ${bsf.excessErrors} excess errors'),
                  Text('• Penalty Words: ${bsf.excessErrors} excess errors × 10 words = ${bsf.penaltyWords.toInt()} words deducted from gross'),
                  Text('• Net Words: max(0, ${bsf.grossWords.toStringAsFixed(1)} - ${bsf.penaltyWords.toInt()}) = ${bsf.netWords.toStringAsFixed(1)} words'),
                  const SizedBox(height: 12),

                  const Text('4. NET SPEED FORMULA', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 4),
                  const Text(
                    'Net WPM = Net Words / Elapsed Minutes',
                    style: TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Calculation: ${bsf.netWords.toStringAsFixed(1)} / $elapsedMin = ${bsf.netWpm.toStringAsFixed(1)} WPM (1 excess error = -1 WPM in 10-min test)',
                    style: const TextStyle(fontWeight: FontWeight.w700, color: NeoColors.textSecondary),
                  ),
                  const SizedBox(height: 12),

                  const Text('5. ACCURACY FORMULA', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 4),
                  const Text(
                    'Accuracy % = ((Gross Words - Total Errors) / Gross Words) × 100',
                    style: TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Calculation: ((${bsf.grossWords.toStringAsFixed(1)} - ${s.totalErrors}) / ${bsf.grossWords.toStringAsFixed(1)}) × 100 = ${bsf.accuracy.toStringAsFixed(1)}%',
                    style: const TextStyle(fontWeight: FontWeight.w700, color: NeoColors.textSecondary),
                  ),
                  const SizedBox(height: 12),

                  const Text('6. QUALIFYING EVALUATION', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 4),
                  Text(
                    bsf.isQualified
                        ? 'STATUS: QUALIFIED (PASS) — Net speed of ${bsf.netWpm.toStringAsFixed(1)} WPM meets the 35 WPM threshold with ${bsf.accuracy.toStringAsFixed(1)}% accuracy.'
                        : 'STATUS: NOT QUALIFIED (FAIL) — BSF Head Constable (Ministerial) requires minimum 35 WPM Net Speed and ≤ 5% error tolerance.',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: bsf.isQualified ? Colors.green.shade800 : Colors.red.shade800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _errorAnalysisCard(TestSession s, SessionScore? score, BsfHcmResult bsf) {
    final correctWords = score?.correctWords ??
        (s.totalWordsTyped - s.substitutions - s.insertions).clamp(0, s.totalWordsTyped);
    final incorrectWords = score?.incorrectWords ?? s.substitutions;
    final correctChars = score?.correctCharacters ??
        (s.totalCharactersTyped - s.substitutions - s.insertions).clamp(0, s.totalCharactersTyped);
    final untypedRemainder = score?.untypedRemainderCharacters ?? 0;
    final elapsedSec = s.actualElapsedDuration;
    final timeStr = '${elapsedSec}s (${(elapsedSec / 60.0).toStringAsFixed(1)} min)';

    return NeoBox(
      backgroundColor: NeoColors.surface,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Detailed Mistake & Evaluation Breakdown', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 10,
            children: [
              _chip('Gross WPM', s.grossWpm.toStringAsFixed(1), NeoColors.mint),
              _chip('Net WPM', s.netWpm.toStringAsFixed(1), NeoColors.yellow),
              _chip('Total Words Typed', '${s.totalWordsTyped}', NeoColors.surfaceSubtle),
              _chip('Correct Words', '$correctWords', NeoColors.mint),
              _chip('Incorrect Words', '$incorrectWords', incorrectWords == 0 ? NeoColors.mint : NeoColors.coral),
              _chip('Total Errors', '${s.totalErrors}', s.totalErrors == 0 ? NeoColors.mint : NeoColors.pink),
              _chip('Insertions (Extra)', '${s.insertions}', NeoColors.yellow),
              _chip('Omissions (Missing)', '${s.omissions}', NeoColors.pink),
              _chip('Substitutions (Incorrect)', '${s.substitutions}', NeoColors.coral),
              _chip('Accuracy', '${bsf.accuracy.toStringAsFixed(1)}%', NeoColors.lavender),
              _chip('Total Typing Time', timeStr, NeoColors.surfaceSubtle),
              _chip('Total Typed Chars', '${s.totalCharactersTyped}', NeoColors.surfaceSubtle),
              _chip('Correct Chars', '$correctChars', NeoColors.mint),
              if (untypedRemainder > 0)
                _chip('Untyped Passage Tail', '$untypedRemainder', NeoColors.surfaceSubtle),
              _chip('Completed Repetitions', '${s.completedRepetitions}', NeoColors.mint),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, String value, Color color) => NeoBox(
    backgroundColor: color,
    shadowOffset: const Offset(2, 2),
    borderRadius: 8,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('$label: ', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: NeoColors.textSecondary)),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900)),
      ],
    ),
  );

  Widget _repetitionBreakdownCard() => NeoBox(
    backgroundColor: NeoColors.surface,
    padding: const EdgeInsets.all(18),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Repetition-by-Repetition Breakdown', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(NeoColors.surfaceSubtle),
            columns: const [
              DataColumn(label: Text('Rep #', style: TextStyle(fontWeight: FontWeight.w900))),
              DataColumn(label: Text('Typed Chars', style: TextStyle(fontWeight: FontWeight.w900))),
              DataColumn(label: Text('Correct', style: TextStyle(fontWeight: FontWeight.w900))),
              DataColumn(label: Text('Errors', style: TextStyle(fontWeight: FontWeight.w900))),
              DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.w900))),
            ],
            rows: _repetitions
                .map(
                  (r) => DataRow(
                    cells: [
                      DataCell(Text('${r.repetitionNumber}')),
                      DataCell(Text('${r.typedCharacterCount}')),
                      DataCell(Text('${r.correctCharacters}')),
                      DataCell(Text('${r.incorrectCharacters + r.omittedCharacters + r.extraCharacters}')),
                      DataCell(
                        NeoBox(
                          backgroundColor: r.isComplete ? NeoColors.mint : NeoColors.yellow,
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          shadowOffset: Offset.zero,
                          borderRadius: 6,
                          child: Text(
                            r.isComplete ? 'COMPLETE' : 'PARTIAL',
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
                .toList(),
          ),
        ),
      ],
    ),
  );

  Widget _textComparisonCard() {
    final ref = widget.passage.content;
    final typed = (widget.typedText != null && widget.typedText!.isNotEmpty)
        ? widget.typedText!
        : (_repetitions.isNotEmpty ? _repetitions.first.typedText : '');

    final wordAlignment = typed.isNotEmpty
        ? ScoringService.alignWords(ref, typed)
        : null;

    return NeoBox(
      backgroundColor: NeoColors.surface,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text('Original vs Typed Comparison', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: NeoColors.surfaceSubtle,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: NeoColors.border, width: 1.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text('Legend: ', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    Text(
                      'Wrong/Omitted',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: NeoColors.coral,
                        decoration: TextDecoration.underline,
                        decorationColor: NeoColors.coral,
                      ),
                    ),
                    Text(' · Correct', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: NeoColors.textPrimary)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Review discrepancies between the reference passage and your typed input. Mistakes are highlighted in red and underlined.',
            style: TextStyle(fontSize: 12.5, color: NeoColors.textSecondary, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 14),
          const Text('REFERENCE PASSAGE:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: NeoColors.surfaceSubtle,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: NeoColors.border, width: 1.5),
            ),
            child: wordAlignment != null
                ? _buildReferenceRichText(ref, wordAlignment)
                : Text(ref, style: const TextStyle(fontSize: 14, height: 1.5)),
          ),
          const SizedBox(height: 14),
          const Text('YOUR TYPED INPUT:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: NeoColors.surfaceSubtle,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: NeoColors.border, width: 1.5),
            ),
            child: typed.isEmpty
                ? const Text(
                    '(No text typed)',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: NeoColors.textSecondary,
                    ),
                  )
                : (wordAlignment != null
                    ? _buildTypedRichText(typed, wordAlignment)
                    : Text(typed, style: const TextStyle(fontSize: 14, height: 1.5))),
          ),
        ],
      ),
    );
  }

  Widget _buildReferenceRichText(String refText, WordAlignmentResult alignment) {
    final spans = <TextSpan>[];
    for (final item in alignment.alignedWords) {
      if (item.expectedWord.isEmpty) continue; // inserted word not in ref
      final bool isError = !item.isMatch;
      spans.add(
        TextSpan(
          text: '${item.expectedWord} ',
          style: TextStyle(
            fontSize: 14,
            height: 1.6,
            color: isError ? NeoColors.coral : NeoColors.textPrimary,
            decoration: isError ? TextDecoration.underline : TextDecoration.none,
            decorationColor: isError ? NeoColors.coral : null,
            decorationThickness: isError ? 2.0 : null,
            fontWeight: isError ? FontWeight.w900 : FontWeight.w500,
          ),
        ),
      );
    }

    if (alignment.untypedRemainderWords > 0) {
      final refWords = refText.trim().split(RegExp(r'\s+'));
      final startIdx = refWords.length - alignment.untypedRemainderWords;
      if (startIdx >= 0 && startIdx < refWords.length) {
        for (int i = startIdx; i < refWords.length; i++) {
          spans.add(
            TextSpan(
              text: '${refWords[i]} ',
              style: TextStyle(
                fontSize: 14,
                height: 1.6,
                color: NeoColors.textSecondary.withValues(alpha: 0.5),
                fontStyle: FontStyle.italic,
              ),
            ),
          );
        }
      }
    }

    return SelectableText.rich(
      TextSpan(children: spans),
    );
  }

  Widget _buildTypedRichText(String typedText, WordAlignmentResult alignment) {
    final spans = <TextSpan>[];
    for (final item in alignment.alignedWords) {
      if (item.typedWord.isEmpty) continue; // omitted word not in typed
      final bool isError = !item.isMatch;
      spans.add(
        TextSpan(
          text: '${item.typedWord} ',
          style: TextStyle(
            fontSize: 14,
            height: 1.6,
            color: isError ? NeoColors.coral : NeoColors.textPrimary,
            decoration: isError ? TextDecoration.underline : TextDecoration.none,
            decorationColor: isError ? NeoColors.coral : null,
            decorationThickness: isError ? 2.0 : null,
            fontWeight: isError ? FontWeight.w900 : FontWeight.w500,
          ),
        ),
      );
    }

    return SelectableText.rich(
      TextSpan(children: spans),
    );
  }

  Widget _actionButtons() => Row(
    children: [
      Expanded(
        child: NeoButton(
          label: 'Retype Passage',
          icon: const Icon(Icons.refresh_rounded, color: NeoColors.textPrimary),
          backgroundColor: NeoColors.yellow,
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => TypingTestScreen(passage: widget.passage),
            ),
          ),
        ),
      ),
      const SizedBox(width: 14),
      Expanded(
        child: NeoButton(
          label: 'Passage Library',
          icon: const Icon(Icons.library_books_rounded, color: NeoColors.textPrimary),
          backgroundColor: NeoColors.surfaceSubtle,
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const PassageLibraryScreen(),
            ),
          ),
        ),
      ),
    ],
  );
}

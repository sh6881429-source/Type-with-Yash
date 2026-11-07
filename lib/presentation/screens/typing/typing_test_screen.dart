import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/neo_colors.dart';
import '../../../data/models/passage.dart';
import '../../../data/models/test_session.dart';
import '../../../data/repositories/test_session_repository.dart';
import '../../../data/services/typing_engine.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/neo_box.dart';
import '../../widgets/neo_button.dart';
import 'test_result_screen.dart';

/// Full Typing Master screen running identically on Windows Desktop and Flutter Web.
/// Features a two-column responsive layout, drift-free countdown timer,
/// configurable auto-loop, ghost reference passage toggle, 5-chars=1-word scoring,
/// and automated transition to detailed test results.
class TypingTestScreen extends StatefulWidget {
  const TypingTestScreen({
    super.key,
    required this.passage,
    this.initialMode = 'practice',
  });

  final Passage passage;
  final String initialMode;

  @override
  State<TypingTestScreen> createState() => _TypingTestScreenState();
}

class _TypingTestScreenState extends State<TypingTestScreen> {
  final _controller = TextEditingController();
  final _customDurationController = TextEditingController();
  final _typingFocusNode = FocusNode();

  TypingEngine? _engine;
  int _minutes = 10;
  String _mode = 'practice';
  bool _autoLoop = false;
  bool _showGhostPassage = false;
  int _characterToWordRatio = 5;

  @override
  void initState() {
    super.initState();
    _mode = widget.initialMode;
  }

  @override
  void dispose() {
    _controller.dispose();
    _customDurationController.dispose();
    _typingFocusNode.dispose();
    _engine?.dispose();
    super.dispose();
  }

  // ── Timer Colour Helpers ──────────────────────────────────────────────────

  Color _timerColor(Duration remaining) {
    if (remaining == Duration.zero) return NeoColors.coral;
    if (remaining.inSeconds <= 60) return NeoColors.pink;
    return NeoColors.yellow;
  }

  String _timerLabel(Duration remaining) {
    if (remaining == Duration.zero) return 'TIME UP';
    if (remaining.inSeconds <= 60) return '⚠ LOW TIME';
    return 'TIME REMAINING';
  }

  String _timerHeaderLabel(Duration remaining) {
    if (remaining == Duration.zero) return 'TIME UP';
    if (remaining.inSeconds <= 60) return '⚠ LOW TIME';
    return 'TIME LEFT';
  }

  // ── Engine Lifecycle & Actions ────────────────────────────────────────────

  Future<void> _start() async {
    final engine = TypingEngine(
      passage: widget.passage,
      duration: Duration(minutes: _minutes),
      autoLoop: _autoLoop,
      mode: _mode,
      characterToWordRatio: _characterToWordRatio,
      errorPenaltyEnabled: true,
      startTimerOnFirstKeystroke: true,
      banBackspace: _mode == 'exam_simulation',
    );

    setState(() => _engine = engine);

    engine.addListener(() {
      if (!mounted) return;
      if (_controller.text != engine.typedText) {
        _controller.value = TextEditingValue(
          text: engine.typedText,
          selection: TextSelection.collapsed(offset: engine.typedText.length),
        );
      }
      setState(() {});

      if (engine.isComplete && mounted) {
        _navigateToResult(engine);
      }
    });

    try {
      await engine.start();
      if (mounted) _typingFocusNode.requestFocus();
    } catch (error) {
      if (!mounted) return;
      setState(() => _engine = null);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to start test: $error')),
      );
    }
  }

  bool _navigatingToResult = false;
  Future<void> _navigateToResult(TypingEngine engine) async {
    if (_navigatingToResult) return;
    _navigatingToResult = true;

    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;

    TestSession? session;
    if (engine.sessionId != null) {
      session = await TestSessionRepository().getSessionById(engine.sessionId!);
    }

    session ??= TestSession(
      id: engine.sessionId ?? 'session-${DateTime.now().millisecondsSinceEpoch}',
      passageId: widget.passage.id,
      passageTitleSnapshot: widget.passage.title,
      mode: _mode,
      configuredDuration: Duration(minutes: _minutes).inSeconds,
      actualElapsedDuration: Duration(minutes: _minutes).inSeconds - engine.remaining.inSeconds,
      characterToWordRatio: _characterToWordRatio,
      startedAt: DateTime.now(),
      grossWpm: engine.lastSessionScore?.grossWpm ?? 0,
      netWpm: engine.lastSessionScore?.netWpm ?? 0,
      accuracy: engine.lastSessionScore?.accuracy ?? 100,
      isCompleted: true,
    );

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => TestResultScreen(
          session: session!,
          passage: widget.passage,
          sessionScore: engine.lastSessionScore,
          typedText: engine.currentOrLastTypedText,
        ),
      ),
    );
  }

  Future<void> _leaveTest() async {
    await _engine?.cancel();
    if (mounted) Navigator.pop(context);
  }

  Future<void> _confirmExit() async {
    final leave = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: NeoColors.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: NeoColors.border, width: 3),
        ),
        title: const Text('Exit this test?', style: TextStyle(fontWeight: FontWeight.w900)),
        content: const Text('Your current typing will be saved as an unfinished attempt.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Keep typing', style: TextStyle(color: NeoColors.textPrimary, fontWeight: FontWeight.w800)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Exit test', style: TextStyle(color: NeoColors.coral, fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
    if (leave == true && mounted) await _leaveTest();
  }

  Future<void> _confirmClearInput(TypingEngine engine) async {
    final clear = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: NeoColors.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: NeoColors.border, width: 3),
        ),
        title: const Text('Clear your input?', style: TextStyle(fontWeight: FontWeight.w900)),
        content: const Text('This will erase everything you have typed in this repetition.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Keep typing', style: TextStyle(color: NeoColors.textPrimary, fontWeight: FontWeight.w800)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Clear input', style: TextStyle(color: NeoColors.coral, fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );

    if (clear == true && mounted) {
      engine.updateText('');
      _controller.clear();
      _typingFocusNode.requestFocus();
    }
  }

  Future<void> _confirmSubmit(TypingEngine engine) async {
    final submit = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: NeoColors.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: NeoColors.border, width: 3),
        ),
        title: const Text('Submit your test?', style: TextStyle(fontWeight: FontWeight.w900)),
        content: const Text('Are you sure you want to finish and calculate your final typing results?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Keep typing', style: TextStyle(color: NeoColors.textPrimary, fontWeight: FontWeight.w800)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Submit now', style: TextStyle(color: NeoColors.mint, fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );

    if (submit == true && mounted) {
      await engine.finishTest();
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final engine = _engine;
    if (engine == null) return _setup();

    return Scaffold(
      backgroundColor: NeoColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _testHeader(engine),
              const SizedBox(height: 16),
              Expanded(child: _testWorkspace(engine)),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _testHeader(TypingEngine engine) => NeoBox(
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
          onPressed: _confirmExit,
        ),
        const SizedBox(width: 10),
        const Expanded(
          child: AppLogo(size: 38, compact: true, showTagline: false),
        ),
        _modeBadge(),
        const SizedBox(width: 10),
        _timerChip(engine.remaining),
        const SizedBox(width: 10),
        NeoButton(
          label: 'Cancel',
          icon: const Icon(Icons.close_rounded, color: NeoColors.textPrimary, size: 18),
          backgroundColor: NeoColors.pink,
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          onPressed: _confirmExit,
        ),
      ],
    ),
  );

  Widget _timerChip(Duration remaining) {
    final color = _timerColor(remaining);
    return NeoBox(
      backgroundColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.timer_outlined, size: 22),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _timerHeaderLabel(remaining),
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900),
              ),
              Text(
                _timeText(remaining),
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Workspace Layout (Two-Column Desktop) ──────────────────────────────────

  Widget _testWorkspace(TypingEngine engine) => LayoutBuilder(
    builder: (context, constraints) {
      final isDesktop = constraints.maxWidth >= 800;

      if (isDesktop) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(flex: 3, child: _typingArea(engine)),
            const SizedBox(width: 18),
            SizedBox(width: 300, child: _sideControlCard(engine)),
          ],
        );
      }

      return SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 480, child: _typingArea(engine)),
            const SizedBox(height: 16),
            _sideControlCard(engine, isHorizontal: true),
          ],
        ),
      );
    },
  );

  // ── Typing Area (With Ghost Text Overlay) ─────────────────────────────────

  Widget _typingArea(TypingEngine engine) {
    final isExam = _mode == 'exam_simulation';
    final showGhost = _showGhostPassage && !isExam;

    return NeoBox(
      backgroundColor: NeoColors.surface,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.keyboard_alt_rounded, size: 26),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Your typing area',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                ),
              ),
              // Ghost Passage Toggle Button
              if (!isExam)
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: NeoButton(
                    label: showGhost ? 'Hide Reference Passage' : 'Show Reference Passage',
                    icon: Icon(
                      showGhost ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      size: 16,
                      color: NeoColors.textPrimary,
                    ),
                    backgroundColor: showGhost ? NeoColors.yellow : NeoColors.surfaceSubtle,
                    height: 34,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
                    onPressed: () => setState(() => _showGhostPassage = !_showGhostPassage),
                  ),
                ),
              _inputStatus(engine),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            isExam
                ? 'Exam Simulation Mode: Passage reference is strictly hidden.'
                : (showGhost
                    ? 'Ghost reference text is visible faintly behind your typing.'
                    : 'Keep your printed passage beside you. The typing workspace remains blank.'),
            style: const TextStyle(color: NeoColors.textSecondary, fontWeight: FontWeight.w600, fontSize: 13),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: NeoColors.surfaceSubtle,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: NeoColors.border, width: 2),
              ),
              child: Stack(
                children: [
                  // Layer 1: Subtle faint ghost reference passage
                  if (showGhost)
                    Positioned.fill(
                      child: IgnorePointer(
                        ignoring: true,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            widget.passage.content,
                            style: TextStyle(
                              fontSize: 18,
                              height: 1.55,
                              color: NeoColors.textSecondary.withValues(alpha: 0.28),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),

                  // Layer 2: Real candidate typing TextField
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Shortcuts(
                        shortcuts: {
                          const SingleActivator(LogicalKeyboardKey.keyV, control: true): const DoNothingIntent(),
                          const SingleActivator(LogicalKeyboardKey.keyV, meta: true): const DoNothingIntent(),
                          const SingleActivator(LogicalKeyboardKey.insert, shift: true): const DoNothingIntent(),
                          if (_mode == 'exam_simulation') ...{
                            const SingleActivator(LogicalKeyboardKey.backspace): const DoNothingIntent(),
                            const SingleActivator(LogicalKeyboardKey.delete): const DoNothingIntent(),
                          },
                        },
                        child: TextField(
                          controller: _controller,
                          focusNode: _typingFocusNode,
                          enabled: engine.isRunning,
                          expands: true,
                          maxLines: null,
                          minLines: null,
                          showCursor: true,
                          cursorColor: NeoColors.textPrimary,
                          cursorWidth: 2.5,
                          keyboardType: TextInputType.multiline,
                          textAlignVertical: TextAlignVertical.top,
                          style: const TextStyle(fontSize: 18, height: 1.55),
                          onChanged: engine.updateText,
                          enableInteractiveSelection: false,
                          contextMenuBuilder: (_, _) => const SizedBox.shrink(),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: engine.isComplete
                                ? 'Test complete — computing accurate results…'
                                : (showGhost ? '' : 'Start typing from your printed passage…'),
                            hintStyle: const TextStyle(color: NeoColors.textSecondary, fontSize: 17),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          _typingFooter(engine),
        ],
      ),
    );
  }

  // ── Right: Side Control Card / Test Information Panel ─────────────────────

  Widget _sideControlCard(TypingEngine engine, {bool isHorizontal = false}) {
    final isExam = _mode == 'exam_simulation';

    if (isHorizontal) {
      return NeoBox(
        backgroundColor: NeoColors.lavender,
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: _largeTimerBox(engine.remaining)),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _detailRow('Passage', widget.passage.title),
                      _detailRow('Mode', '${_mode.toUpperCase()} MODE'),
                      _detailRow('Auto-Loop', _autoLoop ? 'ENABLED' : 'OFF'),
                      _detailRow('Ratio', '$_characterToWordRatio chars/word'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _largeTimerBox(engine.remaining),
        const SizedBox(height: 14),
        Expanded(
          child: NeoBox(
            backgroundColor: NeoColors.lavender,
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.tune_rounded),
                      SizedBox(width: 8),
                      Text('Test Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                    ],
                  ),
                  const Divider(color: NeoColors.border, height: 20),
                  _detailRow('Passage', widget.passage.title),
                  _detailRow('Category', widget.passage.category),
                  _detailRow('Mode', '${_mode.toUpperCase()} MODE'),
                  _detailRow('Duration', '$_minutes min'),
                  _detailRow('Repetition', '${engine.completeCount + 1}${_autoLoop ? ' (Loop ON)' : ''}'),
                  _detailRow('Ratio', '$_characterToWordRatio chars = 1 word'),
                  _detailRow('Elapsed', _elapsedText(engine)),
                  const SizedBox(height: 14),

                  // Auto-loop status indicator
                  NeoBox(
                    backgroundColor: _autoLoop ? NeoColors.mint : NeoColors.surfaceSubtle,
                    shadowOffset: const Offset(2, 2),
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        Icon(_autoLoop ? Icons.repeat_on_rounded : Icons.repeat_rounded, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _autoLoop ? 'Auto-Loop: Active' : 'Auto-Loop: Disabled',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Ghost mode status indicator
                  NeoBox(
                    backgroundColor: isExam
                        ? NeoColors.surfaceSubtle
                        : (_showGhostPassage ? NeoColors.yellow : NeoColors.surfaceSubtle),
                    shadowOffset: const Offset(2, 2),
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        Icon(isExam ? Icons.lock_outline_rounded : Icons.visibility_outlined, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            isExam
                                ? 'Ghost Passage: Locked OFF in Exam'
                                : (_showGhostPassage ? 'Ghost Passage: Active' : 'Ghost Passage: Hidden'),
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),
                  const Text(
                    'The reference passage is printed and stored locally for scoring verification.',
                    style: TextStyle(color: NeoColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _largeTimerBox(Duration remaining) {
    final color = _timerColor(remaining);
    return NeoBox(
      backgroundColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.timer_outlined, size: 28),
          const SizedBox(height: 4),
          Text(_timerLabel(remaining), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900)),
          Text(_timeText(remaining), style: const TextStyle(fontSize: 38, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  Widget _typingFooter(TypingEngine engine) {
    final total = Duration(minutes: _minutes).inMilliseconds;
    final elapsed = total - engine.remaining.inMilliseconds;
    final progress = (elapsed / total).clamp(0.0, 1.0);

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 10,
            backgroundColor: NeoColors.lavender,
            color: NeoColors.purple,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.info_outline_rounded, size: 18),
            const SizedBox(width: 7),
            Expanded(
              child: Text(
                engine.isComplete
                    ? 'Time is up! Your score has been calculated and saved.'
                    : 'Type from your printed paper. The reference text is never altered by ghost display.',
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5),
              ),
            ),
            if (engine.isRunning && engine.typedText.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: NeoButton(
                  label: 'Clear Input',
                  icon: const Icon(Icons.backspace_outlined, size: 16, color: NeoColors.textPrimary),
                  backgroundColor: NeoColors.pink,
                  height: 36,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  onPressed: () => _confirmClearInput(engine),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: NeoButton(
                  label: 'Submit Test',
                  icon: const Icon(Icons.check_circle_outline_rounded, size: 16, color: NeoColors.textPrimary),
                  backgroundColor: NeoColors.mint,
                  height: 36,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  onPressed: () => _confirmSubmit(engine),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  // ── Setup Screen (Preparation & Configuration) ────────────────────────────

  Widget _setup() => Scaffold(
    backgroundColor: NeoColors.background,
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: NeoBox(
              backgroundColor: NeoColors.surface,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      NeoButton(
                        label: 'Back',
                        icon: const Icon(Icons.arrow_back_rounded, color: NeoColors.textPrimary, size: 16),
                        backgroundColor: NeoColors.surfaceSubtle,
                        height: 36,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        onPressed: () => Navigator.pop(context),
                      ),
                      _modeBadge(),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const AppLogo(size: 44, compact: true),
                  const SizedBox(height: 14),
                  const Text('Typing Master', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 4),
                  const Text(
                    'Prepare your typing test',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: NeoColors.textSecondary),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Configure duration, mode, and auto-loop before starting. Reference passage content will remain blank unless Ghost Passage is enabled.',
                    style: TextStyle(color: NeoColors.textSecondary, fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  const SizedBox(height: 20),

                  // Mode selection: Practice vs Exam Simulation
                  const Text('TEST MODE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _modeOption('practice', 'Practice Mode', Icons.edit_note_rounded),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _modeOption('exam_simulation', 'Exam Simulation', Icons.timer_outlined),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),
                  const Text('SELECT DURATION', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [5, 10, 15, 30].map((m) => _durationChip(m)).toList(),
                  ),
                  const SizedBox(height: 14),
                  NeoBox(
                    backgroundColor: NeoColors.surfaceSubtle,
                    shadowOffset: Offset.zero,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    child: TextField(
                      controller: _customDurationController,
                      keyboardType: TextInputType.number,
                      onChanged: (val) {
                        final parsed = int.tryParse(val);
                        if (parsed != null && parsed > 0 && parsed <= 120) {
                          setState(() => _minutes = parsed);
                        }
                      },
                      decoration: const InputDecoration(
                        labelText: 'Custom duration (1–120 minutes)',
                        border: InputBorder.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Prominent Auto-Loop Toggle
                  GestureDetector(
                    onTap: () => setState(() => _autoLoop = !_autoLoop),
                    child: NeoBox(
                      backgroundColor: _autoLoop ? NeoColors.mint : NeoColors.surfaceSubtle,
                      shadowOffset: Offset.zero,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text('Auto-loop passage', style: TextStyle(fontWeight: FontWeight.w800)),
                                SizedBox(height: 2),
                                Text(
                                  'Automatically restart after finishing the passage if time remains.',
                                  style: TextStyle(fontSize: 12, color: NeoColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: _autoLoop,
                            activeThumbColor: NeoColors.purple,
                            onChanged: (val) => setState(() => _autoLoop = val),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),
                  NeoButton(
                    label: 'Start Test',
                    icon: const Icon(Icons.play_arrow_rounded, color: NeoColors.textPrimary),
                    isFullWidth: true,
                    onPressed: _start,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );

  Widget _durationChip(int minutes) {
    final selected = _minutes == minutes && _customDurationController.text.isEmpty;
    return GestureDetector(
      onTap: () => setState(() {
        _minutes = minutes;
        _customDurationController.clear();
      }),
      child: NeoBox(
        backgroundColor: selected ? NeoColors.yellow : NeoColors.surfaceSubtle,
        shadowOffset: selected ? const Offset(3, 3) : const Offset(2, 2),
        borderRadius: 10,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        child: Text(
          '$minutes min',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 14,
            color: selected ? NeoColors.textPrimary : NeoColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _modeOption(String value, String label, IconData icon) {
    final isSelected = _mode == value;
    return GestureDetector(
      onTap: () => setState(() {
        _mode = value;
        if (_mode == 'exam_simulation') _showGhostPassage = false;
      }),
      child: NeoBox(
        backgroundColor: isSelected ? NeoColors.yellow : NeoColors.surfaceSubtle,
        shadowOffset: isSelected ? const Offset(3, 3) : const Offset(2, 2),
        borderRadius: 10,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: NeoColors.textPrimary),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 13,
                color: isSelected ? NeoColors.textPrimary : NeoColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _modeBadge() => NeoBox(
    backgroundColor: _mode == 'exam_simulation' ? NeoColors.coral : NeoColors.mint,
    shadowOffset: const Offset(2, 2),
    borderRadius: 8,
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    child: Text(
      _mode == 'exam_simulation' ? 'EXAM SIMULATION' : 'PRACTICE MODE',
      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900),
    ),
  );

  Widget _inputStatus(TypingEngine engine) => NeoBox(
    backgroundColor: engine.isComplete ? NeoColors.mint : NeoColors.coral,
    borderRadius: 8,
    shadowOffset: const Offset(2, 2),
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
    child: Text(
      engine.isComplete ? 'FINISHED' : 'TYPING ACTIVE',
      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900),
    ),
  );

  Widget _detailRow(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: NeoColors.textSecondary, fontWeight: FontWeight.w700, fontSize: 12.5),
          ),
        ),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
      ],
    ),
  );

  String _timeText(Duration value) {
    final minutes = value.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = value.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  String _elapsedText(TypingEngine engine) {
    final total = Duration(minutes: _minutes);
    final elapsed = total - engine.remaining;
    final m = elapsed.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = elapsed.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}

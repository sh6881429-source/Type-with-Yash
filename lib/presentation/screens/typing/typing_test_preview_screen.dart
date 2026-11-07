import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/neo_colors.dart';
import '../../../data/models/passage.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/neo_box.dart';
import '../../widgets/neo_button.dart';

/// Browser-compatible demonstration of the Typing Master screen.
///
/// Operates entirely in memory with no SQLite or Windows FFI dependencies.
/// Provides full duration configuration, a drift-free countdown timer,
/// blank typing input (enforcing the Print & Type rule), input clearing,
/// cancellation, and completion states.
class TypingTestPreviewScreen extends StatefulWidget {
  const TypingTestPreviewScreen({super.key, required this.passage});

  final Passage passage;

  @override
  State<TypingTestPreviewScreen> createState() =>
      _TypingTestPreviewScreenState();
}

class _TypingTestPreviewScreenState extends State<TypingTestPreviewScreen> {
  final _controller = TextEditingController();
  final _customDurationController = TextEditingController();
  final _focusNode = FocusNode();

  Timer? _ticker;
  DateTime? _startedAt;
  DateTime? _endsAt;

  int _minutes = 5;
  String _mode = 'Practice';
  bool _autoLoop = false;
  int _repetitionCount = 1;

  Duration _remaining = const Duration(minutes: 5);
  bool _running = false;
  bool _finished = false;

  @override
  void dispose() {
    _ticker?.cancel();
    _controller.dispose();
    _customDurationController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // ── Timer Colour & Label Helpers ──────────────────────────────────────────

  Color _timerColor(Duration remaining) {
    if (_finished || remaining == Duration.zero) return NeoColors.coral;
    if (remaining.inSeconds <= 60) return NeoColors.pink;
    return NeoColors.yellow;
  }

  String _timerLabel(Duration remaining) {
    if (_finished || remaining == Duration.zero) return 'TIME UP';
    if (remaining.inSeconds <= 60) return '⚠ LOW TIME';
    return 'TIME REMAINING';
  }

  String _timerHeaderLabel(Duration remaining) {
    if (_finished || remaining == Duration.zero) return 'TIME UP';
    if (remaining.inSeconds <= 60) return '⚠ LOW TIME';
    return 'TIME LEFT';
  }

  // ── Test Flow Actions ─────────────────────────────────────────────────────

  void _start() {
    final now = DateTime.now();
    final targetEnd = now.add(Duration(minutes: _minutes));

    setState(() {
      _startedAt = now;
      _endsAt = targetEnd;
      _remaining = Duration(minutes: _minutes);
      _running = true;
      _finished = false;
      _repetitionCount = 1;
      _controller.clear();
    });

    _ticker?.cancel();
    // 250ms periodic ticker prevents timer drift by recalculating difference from target end.
    _ticker = Timer.periodic(const Duration(milliseconds: 250), (_) {
      final endsAt = _endsAt;
      if (endsAt == null) return;

      final diff = endsAt.difference(DateTime.now());
      if (diff <= Duration.zero) {
        _ticker?.cancel();
        if (mounted) {
          setState(() {
            _remaining = Duration.zero;
            _running = false;
            _finished = true;
          });
        }
        return;
      }

      if (mounted) {
        setState(() => _remaining = diff);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  void _cancelTest() {
    _ticker?.cancel();
    setState(() {
      _running = false;
      _finished = false;
      _startedAt = null;
      _endsAt = null;
      _controller.clear();
    });
  }

  Future<void> _confirmCancel() async {
    final leave = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: NeoColors.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: NeoColors.border, width: 3),
        ),
        title: const Text(
          'Cancel this test?',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        content: const Text(
          'Your active typing demo will be cancelled and reset.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text(
              'Keep typing',
              style: TextStyle(
                color: NeoColors.textPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(
              'Cancel test',
              style: TextStyle(
                color: NeoColors.coral,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );

    if (leave == true && mounted) {
      _cancelTest();
    }
  }

  Future<void> _confirmClearInput() async {
    final clear = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: NeoColors.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: NeoColors.border, width: 3),
        ),
        title: const Text(
          'Clear your input?',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        content: const Text(
          'This will erase everything you have typed so far in this demo.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text(
              'Keep typing',
              style: TextStyle(
                color: NeoColors.textPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(
              'Clear input',
              style: TextStyle(
                color: NeoColors.coral,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );

    if (clear == true && mounted) {
      setState(() => _controller.clear());
      _focusNode.requestFocus();
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (!_running && !_finished) return _setupScreen();
    if (_finished) return _completedScreen();

    return Scaffold(
      backgroundColor: NeoColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _header(),
              const SizedBox(height: 18),
              Expanded(child: _workspace()),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _header() => NeoBox(
    backgroundColor: NeoColors.surface,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    child: Row(
      children: [
        // Back navigation button
        NeoButton(
          label: '',
          icon: const Icon(Icons.arrow_back_rounded, color: NeoColors.textPrimary, size: 20),
          backgroundColor: NeoColors.surfaceSubtle,
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          onPressed: () {
            if (_running) {
              _confirmCancel();
            } else {
              Navigator.pop(context);
            }
          },
        ),
        const SizedBox(width: 10),
        const Expanded(
          child: AppLogo(size: 38, compact: true, showTagline: false),
        ),
        _badge('BROWSER DEMO', NeoColors.mint),
        const SizedBox(width: 8),
        _badge('$_mode Mode'.toUpperCase(), NeoColors.lavender),
        const SizedBox(width: 10),
        _timerHeaderChip(_remaining),
        const SizedBox(width: 10),
        NeoButton(
          label: 'Cancel',
          icon: const Icon(Icons.close_rounded, color: NeoColors.textPrimary, size: 18),
          backgroundColor: NeoColors.pink,
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          onPressed: _confirmCancel,
        ),
      ],
    ),
  );

  Widget _timerHeaderChip(Duration remaining) {
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
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Workspace ─────────────────────────────────────────────────────────────

  Widget _workspace() => LayoutBuilder(
    builder: (context, constraints) {
      if (constraints.maxWidth >= 800) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(flex: 3, child: _typingArea()),
            const SizedBox(width: 18),
            SizedBox(width: 290, child: _sidePanel()),
          ],
        );
      }
      return Column(
        children: [
          Expanded(child: _typingArea()),
          const SizedBox(height: 14),
          SizedBox(height: 160, child: _sidePanel(isHorizontal: true)),
        ],
      );
    },
  );

  Widget _typingArea() => NeoBox(
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
            _badge(
              _running ? 'TYPING ACTIVE' : 'STOPPED',
              _running ? NeoColors.coral : NeoColors.surfaceSubtle,
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          'Keep your printed passage beside you and type it here. The reference text remains strictly hidden.',
          style: TextStyle(
            color: NeoColors.textSecondary,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 14),
        Expanded(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: NeoColors.surfaceSubtle,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: NeoColors.border, width: 2),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Shortcuts(
                shortcuts: const {
                  SingleActivator(LogicalKeyboardKey.keyV, control: true):
                      DoNothingIntent(),
                  SingleActivator(LogicalKeyboardKey.keyV, meta: true):
                      DoNothingIntent(),
                  SingleActivator(LogicalKeyboardKey.insert, shift: true):
                      DoNothingIntent(),
                },
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  enabled: _running,
                  expands: true,
                  maxLines: null,
                  minLines: null,
                  showCursor: true,
                  cursorColor: NeoColors.textPrimary,
                  cursorWidth: 2.5,
                  keyboardType: TextInputType.multiline,
                  textAlignVertical: TextAlignVertical.top,
                  style: const TextStyle(fontSize: 18, height: 1.55),
                  onChanged: (_) => setState(() {}),
                  enableInteractiveSelection: false,
                  contextMenuBuilder: (_, _) => const SizedBox.shrink(),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Start typing from your printed passage…',
                    hintStyle: TextStyle(
                      color: NeoColors.textSecondary,
                      fontSize: 17,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        _typingFooter(),
      ],
    ),
  );

  Widget _sidePanel({bool isHorizontal = false}) {
    if (isHorizontal) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: _largeTimerBox(_remaining)),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: NeoBox(
              backgroundColor: NeoColors.lavender,
              padding: const EdgeInsets.all(12),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Test details',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                    ),
                    const Divider(color: NeoColors.border, height: 12),
                    _detailRow('Mode', '$_mode Mode'),
                    _detailRow('Duration', '$_minutes min'),
                    _detailRow('Repetition', '$_repetitionCount'),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _largeTimerBox(_remaining),
        const SizedBox(height: 14),
        Expanded(
          child: NeoBox(
            backgroundColor: NeoColors.lavender,
            padding: const EdgeInsets.all(14),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.assignment_turned_in_outlined),
                      SizedBox(width: 8),
                      Text(
                        'Test details',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                  const Divider(color: NeoColors.border, height: 22),
                  _detailRow('Mode', '$_mode Mode'),
                  _detailRow('Duration', '$_minutes minutes'),
                  _detailRow(
                    'Repetition',
                    '$_repetitionCount${_autoLoop ? ' • loop on' : ''}',
                  ),
                  _detailRow('Elapsed', _elapsedText()),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: NeoColors.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: NeoColors.border, width: 1.5),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Preview Mode Only',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: NeoColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Official BSF speed & accuracy scoring operates in the Windows Desktop application.',
                          style: TextStyle(
                            fontSize: 10.5,
                            color: NeoColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
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
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.timer_outlined, size: 30),
          const SizedBox(height: 4),
          Text(
            _timerLabel(remaining),
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
          ),
          Text(
            _timeText(remaining),
            style: const TextStyle(
              fontSize: 38,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _typingFooter() {
    final total = Duration(minutes: _minutes).inMilliseconds;
    final elapsed = total - _remaining.inMilliseconds;
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
            const Expanded(
              child: Text(
                'The reference passage is printed and never shown on this screen.',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5),
              ),
            ),
            if (_controller.text.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: NeoButton(
                  label: 'Clear Input',
                  icon: const Icon(
                    Icons.backspace_outlined,
                    size: 16,
                    color: NeoColors.textPrimary,
                  ),
                  backgroundColor: NeoColors.pink,
                  height: 36,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  onPressed: _confirmClearInput,
                ),
              ),
          ],
        ),
      ],
    );
  }

  // ── Setup Screen ──────────────────────────────────────────────────────────

  Widget _setupScreen() => Scaffold(
    backgroundColor: NeoColors.background,
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
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
                        icon: const Icon(
                          Icons.arrow_back_rounded,
                          color: NeoColors.textPrimary,
                          size: 16,
                        ),
                        backgroundColor: NeoColors.surfaceSubtle,
                        height: 36,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        onPressed: () => Navigator.pop(context),
                      ),
                      _badge('BROWSER DEMO', NeoColors.mint),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const AppLogo(size: 44, compact: true),
                  const SizedBox(height: 14),
                  const Text(
                    'Typing Master',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Prepare your typing test',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: NeoColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Your selected passage is ready to print. In compliance with BSF exam standards, passage content will not appear on the typing screen.',
                    style: TextStyle(
                      color: NeoColors.textSecondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'SELECT DURATION',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [5, 10, 15, 30]
                        .map((m) => _durationChip(m))
                        .toList(),
                  ),
                  const SizedBox(height: 14),
                  NeoBox(
                    backgroundColor: NeoColors.surfaceSubtle,
                    shadowOffset: Offset.zero,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 4,
                    ),
                    child: TextField(
                      controller: _customDurationController,
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        final parsed = int.tryParse(value);
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
                  const Text(
                    'TEST MODE',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _modeOption('Practice', Icons.edit_note_rounded),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _modeOption(
                          'Exam Simulation',
                          Icons.timer_outlined,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  GestureDetector(
                    onTap: () => setState(() => _autoLoop = !_autoLoop),
                    child: NeoBox(
                      backgroundColor: _autoLoop
                          ? NeoColors.mint
                          : NeoColors.surfaceSubtle,
                      shadowOffset: Offset.zero,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'Auto-loop passage',
                                  style: TextStyle(fontWeight: FontWeight.w800),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Restart after an exact repetition.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: NeoColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: _autoLoop,
                            activeThumbColor: NeoColors.purple,
                            onChanged: (value) =>
                                setState(() => _autoLoop = value),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  NeoButton(
                    label: 'Start Test',
                    icon: const Icon(
                      Icons.play_arrow_rounded,
                      color: NeoColors.textPrimary,
                    ),
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
    final selected = _minutes == minutes &&
        _customDurationController.text.isEmpty;
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
            color: selected
                ? NeoColors.textPrimary
                : NeoColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _modeOption(String modeName, IconData icon) {
    final isSelected = _mode == modeName;
    return GestureDetector(
      onTap: () => setState(() => _mode = modeName),
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
              modeName,
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

  // ── Completed Screen ──────────────────────────────────────────────────────

  Widget _completedScreen() => Scaffold(
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
                const Center(
                  child: AppLogo(size: 52, compact: true, showTagline: true),
                ),
                const SizedBox(height: 24),
                NeoBox(
                  backgroundColor: NeoColors.yellow,
                  padding: const EdgeInsets.symmetric(
                    vertical: 28,
                    horizontal: 24,
                  ),
                  child: Column(
                    children: const [
                      Text('🏆', style: TextStyle(fontSize: 54)),
                      SizedBox(height: 10),
                      Text(
                        'Demo Test Completed!',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Browser preview session finished.',
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
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: _statCard(
                        icon: Icons.timer_outlined,
                        label: 'Duration',
                        value: '$_minutes min',
                        color: NeoColors.mint,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _statCard(
                        icon: Icons.repeat_rounded,
                        label: 'Repetitions',
                        value: '$_repetitionCount',
                        color: NeoColors.lavender,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _statCard(
                        icon: Icons.text_fields_rounded,
                        label: 'Characters',
                        value: '${_controller.text.length}',
                        color: NeoColors.pink,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                NeoBox(
                  backgroundColor: NeoColors.surfaceSubtle,
                  shadowOffset: const Offset(3, 3),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: const [
                      Icon(Icons.info_outline_rounded, size: 24),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Browser Demo note: In the production Windows application, test sessions, gross/net WPM, and BSF exam scoring metrics are computed and stored in local SQLite.',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: NeoColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                NeoButton(
                  label: 'Try Another Test',
                  icon: const Icon(
                    Icons.refresh_rounded,
                    color: NeoColors.textPrimary,
                  ),
                  isFullWidth: true,
                  onPressed: _cancelTest,
                ),
                const SizedBox(height: 12),
                NeoButton(
                  label: 'Back to Passage Library',
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    color: NeoColors.textPrimary,
                  ),
                  backgroundColor: NeoColors.surfaceSubtle,
                  isFullWidth: true,
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );

  Widget _statCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) => NeoBox(
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
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    ),
  );

  // ── Helpers ───────────────────────────────────────────────────────────────

  Widget _badge(String text, Color color) => NeoBox(
    backgroundColor: color,
    shadowOffset: const Offset(2, 2),
    borderRadius: 8,
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    child: Text(
      text,
      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900),
    ),
  );

  Widget _detailRow(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: NeoColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w900)),
      ],
    ),
  );

  String _timeText(Duration value) {
    final minutes = value.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = value.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  String _elapsedText() {
    final start = _startedAt;
    if (start == null) return '00:00';
    final elapsed = DateTime.now().difference(start);
    final m = elapsed.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = elapsed.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}

import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../models/passage.dart';
import '../models/repetition.dart';
import '../models/test_session.dart';
import '../repositories/repetition_repository.dart';
import '../repositories/test_session_repository.dart';
import 'scoring_service.dart';

enum TypingSessionState { notStarted, running, completed, cancelled }

typedef SessionWriter = Future<void> Function(TestSession session);
typedef RepetitionWriter = Future<void> Function(Repetition repetition);

/// Shared, platform-independent typing engine for Windows Desktop and Flutter Web.
class TypingEngine extends ChangeNotifier {
  TypingEngine({
    required this.passage,
    required this.duration,
    required this.autoLoop,
    this.mode = 'practice',
    this.characterToWordRatio = 5,
    this.errorPenaltyEnabled = true,
    this.startTimerOnFirstKeystroke = false,
    this.banBackspace = false,
    TestSessionRepository? sessions,
    RepetitionRepository? repetitions,
    DateTime Function()? now,
    SessionWriter? saveSession,
    RepetitionWriter? saveRepetition,
  }) : _sessions = sessions ?? TestSessionRepository(),
       _repetitions = repetitions ?? RepetitionRepository(),
       _now = now ?? DateTime.now,
       _saveSessionOverride = saveSession,
       _saveRepetitionOverride = saveRepetition {
    if (duration <= Duration.zero) {
      throw ArgumentError.value(duration, 'duration', 'must be positive');
    }
  }

  final Passage passage;
  final Duration duration;
  final bool autoLoop;
  final String mode;
  final int characterToWordRatio;
  final bool errorPenaltyEnabled;
  final bool startTimerOnFirstKeystroke;
  final bool banBackspace;

  final TestSessionRepository _sessions;
  final RepetitionRepository _repetitions;
  final DateTime Function() _now;
  final SessionWriter? _saveSessionOverride;
  final RepetitionWriter? _saveRepetitionOverride;

  Timer? _ticker;
  DateTime? _startedAt;
  String? _sessionId;
  DateTime? _repetitionStartedAt;
  int _repetitionNumber = 1;
  final List<String> _completedRepetitionTexts = [];

  String typedText = '';
  bool isRunning = false;
  bool isComplete = false;
  Duration remaining = Duration.zero;
  TypingSessionState state = TypingSessionState.notStarted;

  SessionScore? _lastSessionScore;
  SessionScore? get lastSessionScore => _lastSessionScore;
  String? get sessionId => _sessionId;
  List<String> get completedRepetitionTexts => List.unmodifiable(_completedRepetitionTexts);

  String get currentOrLastTypedText {
    if (typedText.isNotEmpty) return typedText;
    if (_completedRepetitionTexts.isNotEmpty) return _completedRepetitionTexts.join('\n\n');
    return '';
  }

  Future<void> start() async {
    if (isRunning || isComplete) return;
    remaining = duration;
    isRunning = true;
    state = TypingSessionState.running;

    if (!startTimerOnFirstKeystroke) {
      _startedAt ??= _now();
      _sessionId ??= 'session-${_startedAt!.microsecondsSinceEpoch}';
      _repetitionStartedAt ??= _startedAt;
      await _saveSession(completed: false);
      _ticker = Timer.periodic(const Duration(milliseconds: 200), (_) => _tick());
    } else {
      _sessionId ??= 'session-${_now().microsecondsSinceEpoch}';
    }
    notifyListeners();
  }

  void updateText(String value) {
    if (!isRunning || isComplete || value == typedText) return;

    // In exam mode or when banBackspace is enabled, prevent deleting characters
    if ((banBackspace || mode == 'exam_simulation') && value.length < typedText.length) {
      return;
    }

    if (_startedAt == null) {
      _startedAt = _now();
      _repetitionStartedAt = _startedAt;
      unawaited(_saveSession(completed: false));
      _ticker = Timer.periodic(const Duration(milliseconds: 200), (_) => _tick());
    }

    typedText = value;

    // Keep active session saved in case of interruption
    unawaited(_saveSession(completed: false));
    notifyListeners();

    if (_startedAt != null && _now().difference(_startedAt!) >= duration) {
      refreshNow();
      return;
    }

    if (typedText == passage.content) {
      unawaited(_completeRepetition());
    }
  }

  void _tick() => refreshNow();

  /// Recomputes remaining time from the injected wall clock.
  void refreshNow() {
    final started = _startedAt;
    if (!isRunning) return;
    if (started == null) {
      remaining = duration;
      notifyListeners();
      return;
    }
    final used = _now().difference(started);
    remaining = used >= duration ? Duration.zero : duration - used;
    if (remaining == Duration.zero) {
      unawaited(_finish());
    }
    notifyListeners();
  }

  Future<void> _completeRepetition() async {
    if (!isRunning) return;
    _completedRepetitionTexts.add(typedText);
    await _saveSession(completed: false);
    await _saveRepetition(true);

    if (!autoLoop) {
      await _finish(savePartial: false);
      return;
    }

    _repetitionNumber++;
    typedText = '';
    _repetitionStartedAt = _now();
    notifyListeners();
  }

  /// Manually submit/finish the test when the candidate completes the passage.
  Future<void> finishTest() async {
    if (!isRunning || isComplete) return;
    if (typedText.isNotEmpty) {
      _completedRepetitionTexts.add(typedText);
      await _saveSession(completed: false);
      await _saveRepetition(true);
    }
    await _finish(savePartial: false);
  }

  Future<void> _finish({bool savePartial = true}) async {
    if (isComplete) return;
    isRunning = false;
    isComplete = true;
    state = TypingSessionState.completed;
    _ticker?.cancel();

    // Ensure session is saved so the row exists before repetitions referencing it
    await _saveSession(completed: true);

    if (savePartial && typedText.isNotEmpty) {
      await _saveRepetition(false);
    }

    notifyListeners();
  }

  Future<void> cancel() async {
    if (!isRunning || isComplete) return;
    isRunning = false;
    state = TypingSessionState.cancelled;
    _ticker?.cancel();

    if (typedText.isNotEmpty) {
      await _saveRepetition(false);
    }
    await _saveSession(completed: false, endedAt: _now());
    notifyListeners();
  }

  Future<void> _saveRepetition(bool complete) async {
    final sessionId = _sessionId;
    if (sessionId == null) return;

    final started = _repetitionStartedAt ?? _now();
    final elapsedSec = max(1, _now().difference(started).inSeconds);

    final score = ScoringService.evaluateRepetition(
      repetitionNumber: _repetitionNumber,
      referenceText: passage.content,
      typedText: typedText,
      elapsedSeconds: elapsedSec,
      keystrokesPerWord: characterToWordRatio,
      penaltyEnabled: errorPenaltyEnabled,
      useBsfHcmRules: true,
      bsfConfig: const BsfHcmConfig(),
    );

    final repetition = Repetition(
      id: 'repetition-$sessionId-$_repetitionNumber',
      sessionId: sessionId,
      repetitionNumber: _repetitionNumber,
      typedText: typedText,
      referencePassageId: passage.id,
      typedCharacterCount: score.totalTypedCharacters,
      correctCharacters: score.correctCharacters,
      incorrectCharacters: score.incorrectCharacters,
      omittedCharacters: score.missingCharacters,
      extraCharacters: score.extraCharacters,
      isComplete: complete,
      startedAt: started,
      completedAt: _now(),
    );

    if (_saveRepetitionOverride != null) {
      await _saveRepetitionOverride(repetition);
    } else {
      await _repetitions.saveRepetition(repetition);
    }
  }

  Future<void> _saveSession({
    required bool completed,
    DateTime? endedAt,
  }) async {
    final started = _startedAt;
    final sessionId = _sessionId;
    if (started == null || sessionId == null) return;

    final elapsed = _now()
        .difference(started)
        .inSeconds
        .clamp(0, duration.inSeconds);

    final allReps = List<String>.from(_completedRepetitionTexts);
    if (typedText.isNotEmpty) {
      allReps.add(typedText);
    }
    if (allReps.isEmpty && completed) {
      allReps.add('');
    }

    final score = ScoringService.aggregateSession(
      configuredDurationSeconds: duration.inSeconds,
      actualElapsedSeconds: max(1, elapsed),
      characterToWordRatio: characterToWordRatio,
      referenceText: passage.content,
      repetitionsTyped: allReps,
      penaltyEnabled: errorPenaltyEnabled,
      useBsfHcmRules: true,
      bsfConfig: const BsfHcmConfig(),
    );
    _lastSessionScore = score;

    final session = TestSession(
      id: sessionId,
      passageId: passage.id,
      passageTitleSnapshot: passage.title,
      mode: mode,
      configuredDuration: duration.inSeconds,
      actualElapsedDuration: elapsed,
      characterToWordRatio: characterToWordRatio,
      startedAt: started,
      completedAt: completed ? _now() : endedAt,
      totalCharactersTyped: score.totalCharactersTyped,
      totalWordsTyped: score.totalWordsTyped,
      grossWpm: score.grossWpm,
      netWpm: score.netWpm,
      accuracy: score.accuracy,
      totalErrors: score.totalErrors,
      omissions: score.omissions,
      substitutions: score.substitutions,
      insertions: score.insertions,
      completedRepetitions: completeCount,
      isCompleted: completed,
    );

    if (_saveSessionOverride != null) {
      await _saveSessionOverride(session);
    } else {
      await _sessions.saveTestSession(session);
    }
  }

  int get completeCount => autoLoop
      ? _completedRepetitionTexts.length
      : (isComplete && typedText == passage.content ? 1 : 0);

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}

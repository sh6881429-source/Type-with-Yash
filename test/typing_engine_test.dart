import 'package:flutter_test/flutter_test.dart';
import 'package:type_with_yash/data/models/passage.dart';
import 'package:type_with_yash/data/models/repetition.dart';
import 'package:type_with_yash/data/models/test_session.dart';
import 'package:type_with_yash/data/services/typing_engine.dart';

void main() {
  final passage = Passage(
    id: 'typing-test',
    title: 'Typing Test',
    category: 'Education',
    difficulty: 'Easy',
    content: 'Alpha beta.',
    wordCount: 2,
    characterCount: 11,
    estimatedTypingDuration: 1,
    language: 'English',
    sourceType: 'test',
    createdAt: DateTime.utc(2026),
    updatedAt: DateTime.utc(2026),
    isCustom: false,
    version: 1,
  );

  test('creates a session and expires from elapsed wall-clock time', () async {
    var now = DateTime.utc(2026, 1, 1, 12);
    final sessions = <TestSession>[];
    final engine = TypingEngine(
      passage: passage,
      duration: const Duration(seconds: 10),
      autoLoop: false,
      now: () => now,
      saveSession: (session) async => sessions.add(session),
      saveRepetition: (_) async {},
    );
    await engine.start();
    expect(engine.state, TypingSessionState.running);
    now = now.add(const Duration(seconds: 13));
    engine.refreshNow();
    await Future<void>.delayed(Duration.zero);
    expect(engine.remaining, Duration.zero);
    expect(engine.state, TypingSessionState.completed);
    expect(sessions.last.isCompleted, isTrue);
  });

  test(
    'saves separate completed repetitions when auto-loop is enabled',
    () async {
      var now = DateTime.utc(2026, 1, 1);
      final repetitions = <Repetition>[];
      final engine = TypingEngine(
        passage: passage,
        duration: const Duration(minutes: 5),
        autoLoop: true,
        now: () => now,
        saveSession: (_) async {},
        saveRepetition: (repetition) async => repetitions.add(repetition),
      );
      await engine.start();
      engine.updateText(passage.content);
      await Future<void>.delayed(Duration.zero);
      expect(repetitions, hasLength(1));
      expect(repetitions.single.isComplete, isTrue);
      expect(engine.typedText, isEmpty);
      expect(engine.completeCount, 1);
    },
  );

  test('preserves a partial repetition when time expires', () async {
    var now = DateTime.utc(2026, 1, 1);
    final repetitions = <Repetition>[];
    final engine = TypingEngine(
      passage: passage,
      duration: const Duration(seconds: 3),
      autoLoop: true,
      now: () => now,
      saveSession: (_) async {},
      saveRepetition: (repetition) async => repetitions.add(repetition),
    );
    await engine.start();
    engine.updateText('Alpha');
    now = now.add(const Duration(seconds: 3));
    engine.refreshNow();
    await Future<void>.delayed(Duration.zero);
    expect(repetitions.single.typedText, 'Alpha');
    expect(repetitions.single.isComplete, isFalse);
    expect(engine.isRunning, isFalse);
  });

  test('rejects an invalid test duration', () {
    expect(
      () => TypingEngine(
        passage: passage,
        duration: Duration.zero,
        autoLoop: false,
      ),
      throwsArgumentError,
    );
  });
}

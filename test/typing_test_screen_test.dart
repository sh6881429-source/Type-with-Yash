// Chunk 6 — Typing Test Screen Tests
//
// These tests verify the TypingTestScreen and TypingEngine integration using
// injected fakes so no real database is needed.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:type_with_yash/core/theme/neo_colors.dart';
import 'package:type_with_yash/data/models/passage.dart';
import 'package:type_with_yash/data/models/repetition.dart';
import 'package:type_with_yash/data/models/test_session.dart';
import 'package:type_with_yash/data/services/typing_engine.dart';
import 'package:type_with_yash/presentation/screens/typing/test_complete_placeholder_screen.dart';
import 'package:type_with_yash/presentation/screens/typing/typing_test_preview_screen.dart';
import 'package:type_with_yash/presentation/screens/typing/typing_test_screen.dart';

// ── Shared test helpers ──────────────────────────────────────────────────────

/// A minimal passage used across all tests. Content is a private implementation
/// detail — it must never surface in any typing-screen widget tree.
Passage _fakePassage({String content = 'Hello world'}) => Passage(
  id: 'test-passage-1',
  title: 'Test Passage',
  category: 'General',
  difficulty: 'Easy',
  content: content,
  wordCount: 2,
  characterCount: content.length,
  estimatedTypingDuration: 120,
  language: 'English',
  sourceType: 'manual',
  createdAt: DateTime(2024, 1, 1),
  updatedAt: DateTime(2024, 1, 1),
  isCustom: false,
  version: 1,
);

/// Fake session / repetition writers so no SQLite calls are made in tests.
Future<void> _noopSession(TestSession _) async {}
Future<void> _noopRepetition(Repetition _) async {}

/// Wraps [child] inside a MaterialApp that provides all needed directionality
/// and theme services. Uses a fixed 1200×800 logical viewport.
Widget _app(Widget child, WidgetTester tester) {
  tester.view.physicalSize = const Size(1200, 800);
  tester.view.devicePixelRatio = 1.0;
  return MaterialApp(home: child);
}

// ── Passage safety helper ────────────────────────────────────────────────────

/// Returns true if the passage's content string appears anywhere in the widget
/// tree's rendered text nodes.
bool _passageContentVisible(WidgetTester tester, String content) {
  final textWidgets = tester.widgetList<Text>(find.byType(Text));
  for (final t in textWidgets) {
    if ((t.data ?? '').contains(content)) return true;
  }
  final richWidgets = tester.widgetList<RichText>(find.byType(RichText));
  for (final r in richWidgets) {
    final plain = r.text.toPlainText();
    if (plain.contains(content)) return true;
  }
  return false;
}

// ═════════════════════════════════════════════════════════════════════════════
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // ── Group 1: TypingEngine unit tests ─────────────────────────────────────

  group('TypingEngine unit tests', () {
    test('throws on non-positive duration', () {
      expect(
        () => TypingEngine(
          passage: _fakePassage(),
          duration: Duration.zero,
          autoLoop: false,
          saveSession: _noopSession,
          saveRepetition: _noopRepetition,
        ),
        throwsArgumentError,
      );
    });

    test('starts in notStarted state', () {
      final engine = TypingEngine(
        passage: _fakePassage(),
        duration: const Duration(minutes: 5),
        autoLoop: false,
        saveSession: _noopSession,
        saveRepetition: _noopRepetition,
      );
      expect(engine.state, TypingSessionState.notStarted);
      expect(engine.isRunning, isFalse);
      expect(engine.isComplete, isFalse);
      engine.dispose();
    });

    test('transitions to running after start()', () async {
      final engine = TypingEngine(
        passage: _fakePassage(),
        duration: const Duration(minutes: 5),
        autoLoop: false,
        saveSession: _noopSession,
        saveRepetition: _noopRepetition,
      );
      await engine.start();
      expect(engine.state, TypingSessionState.running);
      expect(engine.isRunning, isTrue);
      engine.dispose();
    });

    test('completes when time expires via refreshNow()', () async {
      // Use an injected clock that lies: pretend 6 minutes have elapsed.
      DateTime fakeNow = DateTime(2024, 1, 1, 10, 0, 0);
      final engine = TypingEngine(
        passage: _fakePassage(),
        duration: const Duration(minutes: 5),
        autoLoop: false,
        now: () => fakeNow,
        saveSession: _noopSession,
        saveRepetition: _noopRepetition,
      );
      await engine.start();
      fakeNow = fakeNow.add(const Duration(minutes: 6));
      engine.refreshNow();
      // Allow the unawaited _finish() microtasks to complete before asserting.
      await Future<void>.delayed(Duration.zero);
      expect(engine.isComplete, isTrue);
      expect(engine.state, TypingSessionState.completed);
      // Engine is already disposed internally by _finish; no explicit dispose needed.
    });

    test('cancel() transitions to cancelled state', () async {
      final engine = TypingEngine(
        passage: _fakePassage(),
        duration: const Duration(minutes: 5),
        autoLoop: false,
        saveSession: _noopSession,
        saveRepetition: _noopRepetition,
      );
      await engine.start();
      await engine.cancel();
      expect(engine.state, TypingSessionState.cancelled);
      expect(engine.isRunning, isFalse);
      engine.dispose();
    });

    test('typedText updates via updateText()', () async {
      final engine = TypingEngine(
        passage: _fakePassage(),
        duration: const Duration(minutes: 5),
        autoLoop: false,
        saveSession: _noopSession,
        saveRepetition: _noopRepetition,
      );
      await engine.start();
      engine.updateText('Hello');
      expect(engine.typedText, 'Hello');
      engine.dispose();
    });

    test('remaining decreases to zero after refreshNow with elapsed time', () async {
      DateTime fakeNow = DateTime(2024, 1, 1);
      final engine = TypingEngine(
        passage: _fakePassage(),
        duration: const Duration(minutes: 2),
        autoLoop: false,
        now: () => fakeNow,
        saveSession: _noopSession,
        saveRepetition: _noopRepetition,
      );
      await engine.start();
      expect(engine.remaining, const Duration(minutes: 2));
      fakeNow = fakeNow.add(const Duration(minutes: 3));
      engine.refreshNow();
      await Future<void>.delayed(Duration.zero);
      expect(engine.remaining, Duration.zero);
      // Engine is already disposed internally by _finish; no explicit dispose needed.
    });
  });

  // ── Group 2: TypingTestScreen setup screen ───────────────────────────────

  group('TypingTestScreen setup screen', () {
    testWidgets('shows setup screen initially (no passage content visible)', (
      tester,
    ) async {
      final passage = _fakePassage(content: 'SECRET_REFERENCE_TEXT');
      addTearDown(tester.view.resetPhysicalSize);
      await tester.pumpWidget(_app(TypingTestScreen(passage: passage), tester));
      await tester.pump();

      // The setup screen should be shown.
      expect(find.text('Prepare your typing test'), findsOneWidget);
      // Passage content must NOT appear anywhere.
      expect(_passageContentVisible(tester, 'SECRET_REFERENCE_TEXT'), isFalse);
    });

    testWidgets('duration chip selection is reflected in UI', (tester) async {
      addTearDown(tester.view.resetPhysicalSize);
      await tester.pumpWidget(
        _app(TypingTestScreen(passage: _fakePassage()), tester),
      );
      await tester.pump();

      // Tap "5 min" chip.
      await tester.tap(find.text('5 min'));
      await tester.pump();
      expect(find.text('5 min'), findsOneWidget);
    });

    testWidgets('Start Test button is present on setup screen', (tester) async {
      addTearDown(tester.view.resetPhysicalSize);
      await tester.pumpWidget(
        _app(TypingTestScreen(passage: _fakePassage()), tester),
      );
      await tester.pump();
      expect(find.text('Start Test'), findsOneWidget);
    });

    testWidgets('no overflow at 1200x800 on setup screen', (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      await tester.pumpWidget(
        MaterialApp(home: TypingTestScreen(passage: _fakePassage())),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    testWidgets('no overflow at 1000x650 (minimum window) on setup screen', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1000, 650);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      await tester.pumpWidget(
        MaterialApp(home: TypingTestScreen(passage: _fakePassage())),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  });

  // ── Group 3: TestCompletePlaceholderScreen ───────────────────────────────

  group('TestCompletePlaceholderScreen', () {
    Widget completionScreen() => MaterialApp(
      home: const TestCompletePlaceholderScreen(
        passageTitle: 'The Value of Time',
        durationMinutes: 10,
        repetitionsCompleted: 2,
        sessionId: 'session-abc-123',
      ),
    );

    testWidgets('renders Test Completed banner', (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      await tester.pumpWidget(completionScreen());
      await tester.pump();
      expect(find.text('Test Completed!'), findsOneWidget);
    });

    testWidgets('shows passage title in stats', (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      await tester.pumpWidget(completionScreen());
      await tester.pump();
      expect(find.text('The Value of Time'), findsOneWidget);
    });

    testWidgets('shows duration and repetitions', (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      await tester.pumpWidget(completionScreen());
      await tester.pump();
      expect(find.text('10 min'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('shows session ID', (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      await tester.pumpWidget(completionScreen());
      await tester.pump();
      expect(
        find.textContaining('session-abc-123'),
        findsOneWidget,
      );
    });

    testWidgets('shows Chunk 7 coming soon notice', (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      await tester.pumpWidget(completionScreen());
      await tester.pump();
      expect(find.textContaining('Chunk 7'), findsOneWidget);
    });

    testWidgets('has Try Another Passage button', (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      await tester.pumpWidget(completionScreen());
      await tester.pump();
      expect(find.text('Try Another Passage'), findsOneWidget);
    });

    testWidgets('no overflow at 1200x800', (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      await tester.pumpWidget(completionScreen());
      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    testWidgets('no overflow at 1000x650', (tester) async {
      tester.view.physicalSize = const Size(1000, 650);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      await tester.pumpWidget(completionScreen());
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  });

  // ── Group 4: Timer color helper logic ────────────────────────────────────

  group('Timer colour thresholds (NeoColors)', () {
    // Verify the color constants exist and are distinct — a regression guard.
    test('yellow, pink, and coral are distinct colors', () {
      expect(NeoColors.yellow, isNot(NeoColors.pink));
      expect(NeoColors.yellow, isNot(NeoColors.coral));
      expect(NeoColors.pink, isNot(NeoColors.coral));
    });
  });

  // ── Group 5: Browser Demo (TypingTestPreviewScreen) Tests ────────────────

  group('TypingTestPreviewScreen (Browser Demo)', () {
    testWidgets('shows Typing Master setup screen initially', (tester) async {
      final passage = _fakePassage(content: 'SECRET_WEB_PASSAGE_CONTENT');
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        _app(TypingTestPreviewScreen(passage: passage), tester),
      );
      await tester.pump();

      expect(find.text('Typing Master'), findsOneWidget);
      expect(find.text('BROWSER DEMO'), findsOneWidget);
      expect(find.text('Start Test'), findsOneWidget);
      expect(find.text('5 min'), findsOneWidget);
      expect(find.text('10 min'), findsOneWidget);
      expect(find.text('15 min'), findsOneWidget);
      expect(find.text('30 min'), findsOneWidget);

      // Strict requirement: reference passage is never visible!
      expect(_passageContentVisible(tester, 'SECRET_WEB_PASSAGE_CONTENT'), isFalse);
    });

    testWidgets('duration selection changes selected minutes', (tester) async {
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        _app(TypingTestPreviewScreen(passage: _fakePassage()), tester),
      );
      await tester.pump();

      await tester.tap(find.text('10 min'));
      await tester.pump();
      expect(find.text('10 min'), findsOneWidget);
    });

    testWidgets('tapping Start Test enters workspace with blank input', (
      tester,
    ) async {
      final passage = _fakePassage(content: 'SECRET_WEB_PASSAGE_CONTENT');
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        _app(TypingTestPreviewScreen(passage: passage), tester),
      );
      await tester.pump();

      await tester.tap(find.text('Start Test'));
      await tester.pump();

      // Workspace is active
      expect(find.text('Your typing area'), findsOneWidget);
      expect(find.text('TYPING ACTIVE'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);

      // Input TextField exists and is blank
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller?.text ?? '', isEmpty);

      // Passage content remains strictly hidden
      expect(_passageContentVisible(tester, 'SECRET_WEB_PASSAGE_CONTENT'), isFalse);
    });

    testWidgets('allows typing in blank field', (tester) async {
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        _app(TypingTestPreviewScreen(passage: _fakePassage()), tester),
      );
      await tester.pump();

      await tester.tap(find.text('Start Test'));
      await tester.pump();

      await tester.enterText(find.byType(TextField), 'Candidate typed text');
      await tester.pump();

      expect(find.text('Candidate typed text'), findsOneWidget);
      expect(find.text('Clear Input'), findsOneWidget);
    });

    testWidgets('no overflow at 1200x800 and 1000x650 on setup and workspace', (
      tester,
    ) async {
      for (final size in [const Size(1200, 800), const Size(1000, 650)]) {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(
          MaterialApp(
            home: TypingTestPreviewScreen(
              key: ValueKey(size),
              passage: _fakePassage(),
            ),
          ),
        );
        await tester.pump();
        expect(tester.takeException(), isNull);

        await tester.ensureVisible(find.text('Start Test'));
        await tester.tap(find.text('Start Test'));
        await tester.pump();
        expect(tester.takeException(), isNull);
      }
    });
  });
}

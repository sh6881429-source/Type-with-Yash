import 'package:flutter_test/flutter_test.dart';
import 'package:type_with_yash/data/services/scoring_service.dart';

void main() {
  group('1. Required Mathematical Test Cases (Chunk 10 Table)', () {
    // | Typed characters | Time | Expected Gross WPM |
    // | 250              | 60s  | 50                 |
    // | 500              | 120s | 50                 |
    // | 125              | 30s  | 50                 |
    // | 1000             | 300s | 40                 |
    // | 1250             | 300s | 50                 |
    // | 300              | 60s  | 60                 |

    test('250 typed characters in 60s = 50.0 Gross WPM', () {
      final wpm = ScoringService.calculateGrossWpm(
        totalTypedCharacters: 250,
        elapsedSeconds: 60,
        keystrokesPerWord: 5,
      );
      expect(wpm, equals(50.0));
    });

    test('500 typed characters in 120s = 50.0 Gross WPM', () {
      final wpm = ScoringService.calculateGrossWpm(
        totalTypedCharacters: 500,
        elapsedSeconds: 120,
        keystrokesPerWord: 5,
      );
      expect(wpm, equals(50.0));
    });

    test('125 typed characters in 30s = 50.0 Gross WPM', () {
      final wpm = ScoringService.calculateGrossWpm(
        totalTypedCharacters: 125,
        elapsedSeconds: 30,
        keystrokesPerWord: 5,
      );
      expect(wpm, equals(50.0));
    });

    test('1000 typed characters in 300s = 40.0 Gross WPM', () {
      final wpm = ScoringService.calculateGrossWpm(
        totalTypedCharacters: 1000,
        elapsedSeconds: 300,
        keystrokesPerWord: 5,
      );
      expect(wpm, equals(40.0));
    });

    test('1250 typed characters in 300s = 50.0 Gross WPM', () {
      final wpm = ScoringService.calculateGrossWpm(
        totalTypedCharacters: 1250,
        elapsedSeconds: 300,
        keystrokesPerWord: 5,
      );
      expect(wpm, equals(50.0));
    });

    test('300 typed characters in 60s = 60.0 Gross WPM', () {
      final wpm = ScoringService.calculateGrossWpm(
        totalTypedCharacters: 300,
        elapsedSeconds: 60,
        keystrokesPerWord: 5,
      );
      expect(wpm, equals(60.0));
    });

    test('Zero elapsed seconds safely returns 0.0 without division by zero', () {
      final wpm = ScoringService.calculateGrossWpm(
        totalTypedCharacters: 250,
        elapsedSeconds: 0,
        keystrokesPerWord: 5,
      );
      expect(wpm, equals(0.0));
    });
  });

  group('2. Required Accuracy and Error Classification (Cases 1-15)', () {
    const ref = 'The quick brown fox jumps over the lazy dog.';

    test('Case 1: All characters correct', () {
      final score = ScoringService.evaluateRepetition(
        repetitionNumber: 1,
        referenceText: ref,
        typedText: ref,
        elapsedSeconds: 60,
      );
      expect(score.correctCharacters, equals(ref.length));
      expect(score.incorrectCharacters, equals(0));
      expect(score.missingCharacters, equals(0));
      expect(score.extraCharacters, equals(0));
      expect(score.totalErrors, equals(0));
      expect(score.totalCharacterErrors, equals(score.missingCharacters + score.incorrectCharacters + score.extraCharacters));
      expect(score.accuracy, equals(100.0));
    });

    test('Case 2: One incorrect character (substitution)', () {
      // 'The quixk brown fox...'
      const typed = 'The quixk brown fox jumps over the lazy dog.';
      final score = ScoringService.evaluateRepetition(
        repetitionNumber: 1,
        referenceText: ref,
        typedText: typed,
        elapsedSeconds: 60,
      );
      expect(score.substitutions, equals(1));
      expect(score.omissions, equals(0));
      expect(score.insertions, equals(0));
      expect(score.correctCharacters, equals(ref.length - 1));
      expect(score.totalErrors, equals(1));
      expect(score.totalErrors, equals(score.omissions + score.substitutions + score.insertions));
    });

    test('Case 3: Multiple incorrect characters (substitutions)', () {
      // 'The quixk brown fox jumps over tha lazy dog.' ('c'->'x', 'e'->'a')
      const typed = 'The quixk brown fox jumps over tha lazy dog.';
      final score = ScoringService.evaluateRepetition(
        repetitionNumber: 1,
        referenceText: ref,
        typedText: typed,
        elapsedSeconds: 60,
      );
      expect(score.incorrectCharacters, equals(2));
      expect(score.missingCharacters, equals(0));
      expect(score.extraCharacters, equals(0));
      expect(score.totalErrors, equals(2));
      expect(score.totalErrors, equals(score.omissions + score.substitutions + score.insertions));
    });

    test('Case 4: Missing characters (omissions within attempted text)', () {
      // 'c' omitted in 'quick' -> 'quik' is 1 word error
      const typed = 'The quik brown fox jumps over the lazy dog.';
      final score = ScoringService.evaluateRepetition(
        repetitionNumber: 1,
        referenceText: ref,
        typedText: typed,
        elapsedSeconds: 60,
      );
      expect(score.missingCharacters, equals(1));
      expect(score.incorrectCharacters, equals(0));
      expect(score.totalErrors, equals(1));
      // Sequence alignment ensures 'brown fox jumps...' remains fully correct!
      expect(score.correctCharacters, equals(ref.length - 1));
      expect(score.totalErrors, equals(score.omissions + score.substitutions + score.insertions));
    });

    test('Case 5: Extra characters (insertions)', () {
      // extra 'c' inserted in 'quicck' -> 1 word error
      const typed = 'The quicck brown fox jumps over the lazy dog.';
      final score = ScoringService.evaluateRepetition(
        repetitionNumber: 1,
        referenceText: ref,
        typedText: typed,
        elapsedSeconds: 60,
      );
      expect(score.extraCharacters, equals(1));
      expect(score.incorrectCharacters, equals(0));
      expect(score.totalErrors, equals(1));
      expect(score.correctCharacters, equals(ref.length));
      expect(score.totalErrors, equals(score.omissions + score.substitutions + score.insertions));
    });

    test('Case 6: Incorrect word followed by a correct word', () {
      // 'The quik brown fox' -> 'quik' is wrong, 'brown' and 'fox' are correct
      const typed = 'The quik brown fox';
      final score = ScoringService.evaluateRepetition(
        repetitionNumber: 1,
        referenceText: ref,
        typedText: typed,
        elapsedSeconds: 30,
      );
      expect(score.incorrectWords, equals(1));
      expect(score.correctWords, equals(3)); // The, brown, fox
    });

    test('Case 7 & 8: Backspace and multiple backspaces (submitted text evaluation)', () {
      // In practice scoring, backspacing cleans the input buffer.
      // The submitted text is what is scored:
      // User typed 'The qui', typed 'x', hit backspace, then typed 'c', 'k':
      const afterCorrection = 'The quick';
      final score = ScoringService.evaluateRepetition(
        repetitionNumber: 1,
        referenceText: ref,
        typedText: afterCorrection,
        elapsedSeconds: 15,
      );
      expect(score.incorrectCharacters, equals(0));
      expect(score.totalErrors, equals(0));
      expect(score.correctCharacters, equals(afterCorrection.length));
    });

    test('Case 9: Punctuation errors', () {
      const refPunct = 'The quick, brown fox jumps over the lazy dog!';
      const typed = 'The quick brown fox jumps over the lazy dog?';
      final score = ScoringService.evaluateRepetition(
        repetitionNumber: 1,
        referenceText: refPunct,
        typedText: typed,
        elapsedSeconds: 60,
      );
      expect(score.totalErrors, equals(2));
      expect(score.totalErrors, equals(score.omissions + score.substitutions + score.insertions));
      expect(score.totalCharacterErrors, equals(score.missingCharacters + score.incorrectCharacters + score.extraCharacters));
    });

    test('Case 10: Capitalization errors', () {
      // 'the' instead of 'The'
      const typed = 'the quick brown fox jumps over the lazy dog.';
      final score = ScoringService.evaluateRepetition(
        repetitionNumber: 1,
        referenceText: ref,
        typedText: typed,
        elapsedSeconds: 60,
      );
      expect(score.incorrectCharacters, equals(1)); // 't' != 'T'
      expect(score.totalErrors, equals(1));
      expect(score.totalErrors, equals(score.omissions + score.substitutions + score.insertions));
    });

    test('Case 11: Spaces and repeated spaces', () {
      const typed = 'The   quick   brown';
      final score = ScoringService.evaluateRepetition(
        repetitionNumber: 1,
        referenceText: ref,
        typedText: typed,
        elapsedSeconds: 30,
      );
      expect(score.extraCharacters, greaterThan(0));
      expect(score.totalCharacterErrors, equals(score.missingCharacters + score.incorrectCharacters + score.extraCharacters));
      expect(score.correctWords, equals(3));
      expect(score.totalErrors, equals(0));
    });

    test('Case 12: Test ending in the middle of a word', () {
      const partial = 'The quick bro';
      final score = ScoringService.evaluateRepetition(
        repetitionNumber: 1,
        referenceText: ref,
        typedText: partial,
        elapsedSeconds: 15,
      );
      expect(score.correctCharacters, equals(partial.length));
      expect(score.incorrectCharacters, equals(0));
      expect(score.correctWords, equals(2));
      expect(score.incorrectWords, equals(1));
      expect(score.totalErrors, equals(1));
      expect(score.untypedRemainderCharacters, equals(ref.length - partial.length));
    });

    test('Case 13: Zero typed characters', () {
      final score = ScoringService.evaluateRepetition(
        repetitionNumber: 1,
        referenceText: ref,
        typedText: '',
        elapsedSeconds: 60,
      );
      expect(score.totalTypedCharacters, equals(0));
      expect(score.correctCharacters, equals(0));
      expect(score.totalErrors, equals(0));
      expect(score.grossWpm, equals(0.0));
      expect(score.accuracy, equals(100.0));
      expect(score.untypedRemainderCharacters, equals(ref.length));
    });

    test('Case 14: Empty reference passage', () {
      final score = ScoringService.evaluateRepetition(
        repetitionNumber: 1,
        referenceText: '',
        typedText: 'hello',
        elapsedSeconds: 30,
      );
      expect(score.extraCharacters, equals(5));
      expect(score.correctCharacters, equals(0));
      expect(score.accuracy, equals(0.0));
    });

    test('Case 15: Unicode and newline handling', () {
      const unicodeRef = 'Hello “World” — Special — Newline\nNext line.';
      final score = ScoringService.evaluateRepetition(
        repetitionNumber: 1,
        referenceText: unicodeRef,
        typedText: unicodeRef,
        elapsedSeconds: 60,
      );
      expect(score.correctCharacters, equals(unicodeRef.length));
      expect(score.totalErrors, equals(0));
      expect(score.accuracy, equals(100.0));
    });
  });

  group('3. User Scenario & Sequence Alignment Regressions', () {
    test('Ancient Trade Routes: 84 typed chars out of ~7000 char passage', () {
      // Reproduces the exact user test scenario:
      // Passage is 7,036 characters long.
      // Candidate typed 84 characters in 60s.
      final longPassage = 'Ancient Trade Routes were vital arteries of commerce connecting distant civilizations. ' * 85;
      expect(longPassage.length, greaterThan(7000));

      // Candidate typed 84 characters with clean typing:
      final typed84 = longPassage.substring(0, 84);

      final score = ScoringService.evaluateRepetition(
        repetitionNumber: 1,
        referenceText: longPassage,
        typedText: typed84,
        elapsedSeconds: 60,
        keystrokesPerWord: 5,
      );

      // Gross WPM = (84 / 5) / 1.0 = 16.8
      expect(score.grossWpm, equals(16.8));
      expect(score.correctCharacters, equals(84));
      expect(score.incorrectCharacters, equals(0));
      expect(score.missingCharacters, equals(0));
      expect(score.extraCharacters, equals(0));
      expect(score.totalCharacterErrors, equals(0));
      // Word level: 10 complete correct words, 1 incomplete word ('civilization' for 'civilizations.')
      expect(score.correctWords, equals(10));
      expect(score.substitutions, equals(1));
      expect(score.totalErrors, equals(1));
      expect(score.netWpm, equals(15.8));
      expect(score.accuracy, equals(100.0));

      // Untyped passage tail is tracked separately and is NOT an omission error:
      expect(score.untypedRemainderCharacters, equals(longPassage.length - 84));
      expect(score.totalErrors, equals(score.omissions + score.substitutions + score.insertions));
      expect(score.totalCharacterErrors, equals(score.missingCharacters + score.incorrectCharacters + score.extraCharacters));
    });

    test('Ancient Trade Routes with 2 typos in 84 characters', () {
      final longPassage = 'Ancient Trade Routes were vital arteries of commerce connecting distant civilizations. ' * 80;
      // Change 2 characters in the 84-character string
      final typedList = longPassage.substring(0, 84).split('');
      typedList[10] = 'X'; // typo 1 in word 'Trade' -> 'TXade'
      typedList[30] = 'Z'; // typo 2 in word 'arteries' -> 'aZteries'
      final typed84WithTypos = typedList.join();

      final score = ScoringService.evaluateRepetition(
        repetitionNumber: 1,
        referenceText: longPassage,
        typedText: typed84WithTypos,
        elapsedSeconds: 60,
      );

      expect(score.grossWpm, equals(16.8));
      expect(score.incorrectCharacters, equals(2));
      expect(score.correctCharacters, equals(82));
      // 2 character typos in 'Trade' and 'arteries', plus 1 incomplete word 'civilization'
      expect(score.substitutions, equals(3));
      expect(score.totalErrors, equals(3));
      // Net WPM = 16.8 - (3 / 1.0) = 13.8
      expect(score.netWpm, equals(13.8));
      // Accuracy = 82 / 84 = 97.6%
      expect(score.accuracy, equals(97.6));
    });

    test('Total Errors identity invariant holds across all evaluations', () {
      const ref = 'Typing tests must be transparent and mathematically rigorous.';
      const testCases = [
        'Typing tests must be transparent and mathematically rigorous.',
        'Typing tests must be transparent and mathematically',
        'Typing tasts must be transparent and mathematically rigorous.',
        'Typing tests  must be transparent',
        'Typing tests must be transparent and mathematically rigorous! Extra words.',
        '',
      ];

      for (final typed in testCases) {
        final score = ScoringService.evaluateRepetition(
          repetitionNumber: 1,
          referenceText: ref,
          typedText: typed,
          elapsedSeconds: 60,
        );

        expect(
          score.totalErrors,
          equals(score.omissions + score.substitutions + score.insertions),
          reason: 'Total Errors must equal omissions + substitutions + insertions for "$typed"',
        );
        expect(
          score.totalCharacterErrors,
          equals(score.missingCharacters + score.incorrectCharacters + score.extraCharacters),
          reason: 'Total character errors invariant for "$typed"',
        );
      }
    });
  });

  group('4. BSF Head Constable (Ministerial) Scoring Verification', () {
    const bsfConfig = BsfHcmConfig();

    test('BSF HCM Case 1: 600 gross words, 2 errors in 10 min (Pass)', () {
      // 3000 keystrokes = 600 words
      final result = ScoringService.calculateBsfHcmMetrics(
        totalKeystrokes: 3000,
        totalErrors: 2,
        elapsedMinutes: 10.0,
        config: bsfConfig,
      );

      expect(result.grossWords, equals(600.0));
      expect(result.grossWpm, equals(60.0));
      expect(result.allowedErrors, equals(30)); // floor(0.05 * 600) = 30
      expect(result.excessErrors, equals(0));
      expect(result.penaltyWords, equals(0.0));
      expect(result.netWords, equals(600.0));
      expect(result.netWpm, equals(60.0));
      expect(result.accuracy, equals(99.7)); // (600 - 2) / 600 * 100 = 99.67% -> 99.7%
      expect(result.isQualified, isTrue);
    });

    test('BSF HCM Case 2: 350 gross words, 2 errors in 10 min (Pass, Exactly 35 WPM)', () {
      // 1750 keystrokes = 350 words
      final result = ScoringService.calculateBsfHcmMetrics(
        totalKeystrokes: 1750,
        totalErrors: 2,
        elapsedMinutes: 10.0,
        config: bsfConfig,
      );

      expect(result.grossWords, equals(350.0));
      expect(result.grossWpm, equals(35.0));
      expect(result.allowedErrors, equals(17)); // floor(0.05 * 350) = floor(17.5) = 17
      expect(result.excessErrors, equals(0));
      expect(result.penaltyWords, equals(0.0));
      expect(result.netWords, equals(350.0));
      expect(result.netWpm, equals(35.0));
      expect(result.accuracy, equals(99.4)); // (350 - 2) / 350 * 100 = 99.43% -> 99.4%
      expect(result.isQualified, isTrue);
    });

    test('BSF HCM Case 3: 500 gross words, 25 errors in 10 min (Pass, Exactly 5% errors)', () {
      // 2500 keystrokes = 500 words
      final result = ScoringService.calculateBsfHcmMetrics(
        totalKeystrokes: 2500,
        totalErrors: 25,
        elapsedMinutes: 10.0,
        config: bsfConfig,
      );

      expect(result.grossWords, equals(500.0));
      expect(result.grossWpm, equals(50.0));
      expect(result.allowedErrors, equals(25)); // floor(0.05 * 500) = 25
      expect(result.excessErrors, equals(0));
      expect(result.penaltyWords, equals(0.0));
      expect(result.netWords, equals(500.0));
      expect(result.netWpm, equals(50.0));
      expect(result.accuracy, equals(95.0)); // (500 - 25) / 500 * 100 = 95.0%
      expect(result.isQualified, isTrue);
    });

    test('BSF HCM Case 4: 400 gross words, 30 errors in 10 min (Fail, 10 excess errors)', () {
      // 2000 keystrokes = 400 words
      final result = ScoringService.calculateBsfHcmMetrics(
        totalKeystrokes: 2000,
        totalErrors: 30,
        elapsedMinutes: 10.0,
        config: bsfConfig,
      );

      expect(result.grossWords, equals(400.0));
      expect(result.grossWpm, equals(40.0));
      expect(result.allowedErrors, equals(20)); // floor(0.05 * 400) = 20
      expect(result.excessErrors, equals(10)); // 30 - 20 = 10
      expect(result.penaltyWords, equals(100.0)); // 10 * 10 = 100
      expect(result.netWords, equals(300.0)); // 400 - 100 = 300
      expect(result.netWpm, equals(30.0)); // 300 / 10 = 30.0
      expect(result.accuracy, equals(92.5)); // (400 - 30) / 400 * 100 = 92.5%
      expect(result.isQualified, isFalse); // netWpm 30 < 35, acc 92.5% < 95%
    });

    test('BSF HCM Case 5: 370 gross words, 18 errors in 10 min (Pass)', () {
      // 1850 keystrokes = 370 words
      final result = ScoringService.calculateBsfHcmMetrics(
        totalKeystrokes: 1850,
        totalErrors: 18,
        elapsedMinutes: 10.0,
        config: bsfConfig,
      );

      expect(result.grossWords, equals(370.0));
      expect(result.grossWpm, equals(37.0));
      expect(result.allowedErrors, equals(18)); // floor(0.05 * 370) = floor(18.5) = 18
      expect(result.excessErrors, equals(0)); // 18 - 18 = 0
      expect(result.penaltyWords, equals(0.0));
      expect(result.netWords, equals(370.0));
      expect(result.netWpm, equals(37.0));
      expect(result.accuracy, equals(95.1)); // (370 - 18) / 370 * 100 = 95.135% -> 95.1%
      expect(result.isQualified, isTrue);
    });

    test('BSF HCM Hindi Threshold: 30 WPM config', () {
      final hindiConfig = BsfHcmConfig.defaultHindi;
      // 1600 keystrokes = 320 words in 10 min = 32 Gross WPM, 10 errors
      final result = ScoringService.calculateBsfHcmMetrics(
        totalKeystrokes: 1600,
        totalErrors: 10,
        elapsedMinutes: 10.0,
        config: hindiConfig,
      );

      expect(result.grossWpm, equals(32.0));
      expect(result.allowedErrors, equals(16)); // floor(0.05 * 320) = 16
      expect(result.excessErrors, equals(0));
      expect(result.netWpm, equals(32.0));
      expect(result.isQualified, isTrue); // 32 WPM >= 30 WPM Hindi qualifying threshold
    });

    test('BSF HCM Edge Case: Zero typed keystrokes safely handled', () {
      final result = ScoringService.calculateBsfHcmMetrics(
        totalKeystrokes: 0,
        totalErrors: 0,
        elapsedMinutes: 10.0,
        config: bsfConfig,
      );

      expect(result.grossWords, equals(0.0));
      expect(result.grossWpm, equals(0.0));
      expect(result.allowedErrors, equals(0));
      expect(result.excessErrors, equals(0));
      expect(result.penaltyWords, equals(0.0));
      expect(result.netWords, equals(0.0));
      expect(result.netWpm, equals(0.0));
      expect(result.accuracy, equals(100.0));
      expect(result.isQualified, isFalse);
    });

    test('BSF HCM Edge Case: Heavy errors exceeding gross words clamp net words to 0.0', () {
      // 500 keystrokes = 100 words, 50 errors (allowed: 5, excess: 45, penalty: 450 words)
      final result = ScoringService.calculateBsfHcmMetrics(
        totalKeystrokes: 500,
        totalErrors: 50,
        elapsedMinutes: 10.0,
        config: bsfConfig,
      );

      expect(result.grossWords, equals(100.0));
      expect(result.allowedErrors, equals(5));
      expect(result.excessErrors, equals(45));
      expect(result.penaltyWords, equals(450.0));
      expect(result.netWords, equals(0.0)); // max(0, 100 - 450)
      expect(result.netWpm, equals(0.0));
      expect(result.accuracy, equals(50.0)); // (100 - 50) / 100 * 100 = 50.0%
      expect(result.isQualified, isFalse);
    });

    test('calculateNetWpm with useBsfHcmRules integrates BSF HCM deduction', () {
      final netWpm = ScoringService.calculateNetWpm(
        totalTypedCharacters: 2000,
        totalErrors: 30,
        elapsedSeconds: 600,
        useBsfHcmRules: true,
      );
      // Matches Case 4: 400 gross words, 30 errors -> allowed 20, excess 10 -> netWpm = 30.0
      expect(netWpm, equals(30.0));
    });

    test('calculateNetWpm with penaltyEnabled=false returns raw Gross WPM', () {
      final netWpm = ScoringService.calculateNetWpm(
        totalTypedCharacters: 2000,
        totalErrors: 30,
        elapsedSeconds: 600,
        penaltyEnabled: false,
      );
      expect(netWpm, equals(40.0));
    });
  });

  group('5. Word-Level Error Classification (USER_REQUEST Specification)', () {
    const actual = 'THE INDIA';

    test('Table Case 1: "THE INDIA" vs "TEE INDIA" -> 1 word error', () {
      final score = ScoringService.evaluateRepetition(
        repetitionNumber: 1,
        referenceText: actual,
        typedText: 'TEE INDIA',
        elapsedSeconds: 60,
      );
      expect(score.totalErrors, equals(1));
      expect(score.incorrectWords, equals(1));
      expect(score.substitutions, equals(1));
      expect(score.correctWords, equals(1));
      expect(score.missingWords, equals(0));
      expect(score.extraWords, equals(0));
      expect(score.totalPenaltyErrors, equals(1));
    });

    test('Table Case 2: "THE INDIA" vs "TXX INDIA" -> 1 word error', () {
      final score = ScoringService.evaluateRepetition(
        repetitionNumber: 1,
        referenceText: actual,
        typedText: 'TXX INDIA',
        elapsedSeconds: 60,
      );
      expect(score.totalErrors, equals(1));
      expect(score.incorrectWords, equals(1));
      expect(score.substitutions, equals(1));
      expect(score.correctWords, equals(1));
      expect(score.missingWords, equals(0));
      expect(score.extraWords, equals(0));
      expect(score.totalPenaltyErrors, equals(1));
    });

    test('Table Case 3: "THE INDIA" vs "TH INDIA" -> 1 word error', () {
      final score = ScoringService.evaluateRepetition(
        repetitionNumber: 1,
        referenceText: actual,
        typedText: 'TH INDIA',
        elapsedSeconds: 60,
      );
      expect(score.totalErrors, equals(1));
      expect(score.incorrectWords, equals(1));
      expect(score.substitutions, equals(1));
      expect(score.correctWords, equals(1));
      expect(score.totalPenaltyErrors, equals(1));
    });

    test('Table Case 4: "THE INDIA" vs "THE INDEA" -> 1 word error', () {
      final score = ScoringService.evaluateRepetition(
        repetitionNumber: 1,
        referenceText: actual,
        typedText: 'THE INDEA',
        elapsedSeconds: 60,
      );
      expect(score.totalErrors, equals(1));
      expect(score.incorrectWords, equals(1));
      expect(score.substitutions, equals(1));
      expect(score.correctWords, equals(1));
      expect(score.totalPenaltyErrors, equals(1));
    });

    test('Table Case 5: "THE INDIA" vs "THE INDIA" -> 0 word errors', () {
      final score = ScoringService.evaluateRepetition(
        repetitionNumber: 1,
        referenceText: actual,
        typedText: 'THE INDIA',
        elapsedSeconds: 60,
      );
      expect(score.totalErrors, equals(0));
      expect(score.incorrectWords, equals(0));
      expect(score.substitutions, equals(0));
      expect(score.missingWords, equals(0));
      expect(score.extraWords, equals(0));
      expect(score.correctWords, equals(2));
      expect(score.totalPenaltyErrors, equals(0));
    });

    test('Table Case 6: "THE INDIA" vs "THE INDIA EXTRA" -> 1 word error', () {
      final score = ScoringService.evaluateRepetition(
        repetitionNumber: 1,
        referenceText: actual,
        typedText: 'THE INDIA EXTRA',
        elapsedSeconds: 60,
      );
      expect(score.totalErrors, equals(1));
      expect(score.extraWords, equals(1));
      expect(score.insertions, equals(1));
      expect(score.correctWords, equals(2));
      expect(score.incorrectWords, equals(0));
      expect(score.totalPenaltyErrors, equals(1));
    });

    test('Table Case 7: "THE INDIA" vs "INDIA" -> 1 word error', () {
      final score = ScoringService.evaluateRepetition(
        repetitionNumber: 1,
        referenceText: actual,
        typedText: 'INDIA',
        elapsedSeconds: 60,
      );
      expect(score.totalErrors, equals(1));
      expect(score.missingWords, equals(1));
      expect(score.omissions, equals(1));
      expect(score.correctWords, equals(1));
      expect(score.incorrectWords, equals(0));
      expect(score.totalPenaltyErrors, equals(1));
    });

    test('Additional Test: Two or more incorrect characters in one word = 1 word error', () {
      final score = ScoringService.evaluateRepetition(
        repetitionNumber: 1,
        referenceText: 'BEAUTIFUL INDIA',
        typedText: 'BXXTIXXX INDIA',
        elapsedSeconds: 60,
      );
      expect(score.totalErrors, equals(1));
      expect(score.incorrectWords, equals(1));
      expect(score.correctWords, equals(1));
    });

    test('Additional Test: Multiple incorrect words in one sentence', () {
      final score = ScoringService.evaluateRepetition(
        repetitionNumber: 1,
        referenceText: 'THE INDIA IS GREAT',
        typedText: 'TEE INDEA IS GREAT',
        elapsedSeconds: 60,
      );
      expect(score.totalErrors, equals(2));
      expect(score.incorrectWords, equals(2));
      expect(score.correctWords, equals(2));
    });

    test('Additional Test: Missing words', () {
      final score = ScoringService.evaluateRepetition(
        repetitionNumber: 1,
        referenceText: 'THE QUICK BROWN FOX JUMPS',
        typedText: 'THE BROWN JUMPS',
        elapsedSeconds: 60,
      );
      // 'QUICK' and 'FOX' omitted -> 2 omissions
      expect(score.omissions, equals(2));
      expect(score.missingWords, equals(2));
      expect(score.correctWords, equals(3));
      expect(score.totalErrors, equals(2));
    });

    test('Additional Test: Extra words', () {
      final score = ScoringService.evaluateRepetition(
        repetitionNumber: 1,
        referenceText: 'THE FOX',
        typedText: 'THE QUICK FOX',
        elapsedSeconds: 60,
      );
      expect(score.insertions, equals(1));
      expect(score.extraWords, equals(1));
      expect(score.correctWords, equals(2));
      expect(score.totalErrors, equals(1));
    });

    test('Additional Test: Repeated words', () {
      final score = ScoringService.evaluateRepetition(
        repetitionNumber: 1,
        referenceText: 'THE FOX',
        typedText: 'THE THE FOX',
        elapsedSeconds: 60,
      );
      expect(score.insertions, equals(1));
      expect(score.extraWords, equals(1));
      expect(score.correctWords, equals(2));
      expect(score.totalErrors, equals(1));
    });

    test('Additional Test: Punctuation differences', () {
      final score = ScoringService.evaluateRepetition(
        repetitionNumber: 1,
        referenceText: 'THE INDIA,',
        typedText: 'THE INDIA.',
        elapsedSeconds: 60,
      );
      expect(score.totalErrors, equals(1));
      expect(score.incorrectWords, equals(1));
      expect(score.correctWords, equals(1));
    });

    test('Additional Test: Correct words following incorrect words', () {
      final score = ScoringService.evaluateRepetition(
        repetitionNumber: 1,
        referenceText: 'FIRST SECOND THIRD FOURTH',
        typedText: 'WRONG SECOND WRONG2 FOURTH',
        elapsedSeconds: 60,
      );
      expect(score.correctWords, equals(2)); // SECOND and FOURTH
      expect(score.incorrectWords, equals(2)); // WRONG and WRONG2
      expect(score.totalErrors, equals(2));
    });

    test('Verification: Separate counters maintained and no double-counting', () {
      final score = ScoringService.evaluateRepetition(
        repetitionNumber: 1,
        referenceText: 'ALPHA BRAVO CHARLIE DELTA ECHO',
        typedText: 'ALPHA BZZZZ DELTA EXTRA ECHO',
        elapsedSeconds: 60,
      );
      // ALPHA: correct
      // BRAVO -> BZZZZ: substitution (1)
      // CHARLIE: omitted (1)
      // DELTA: correct
      // EXTRA: extra/inserted (1)
      // ECHO: correct
      expect(score.correctWords, equals(3));
      expect(score.substitutions, equals(1));
      expect(score.incorrectWords, equals(1));
      expect(score.omissions, equals(1));
      expect(score.missingWords, equals(1));
      expect(score.insertions, equals(1));
      expect(score.extraWords, equals(1));
      expect(score.totalErrors, equals(3));
      expect(score.totalErrors, equals(score.omissions + score.substitutions + score.insertions));
    });
  });

  group('6. Gross and Net WPM Calculation (USER_REQUEST Specification)', () {
    test('Section 5 Test Case: 1500 chars, 10 min, 10 penalty errors -> Gross 30, Net 29', () {
      final gross = ScoringService.calculateGrossWpm(
        totalTypedCharacters: 1500,
        elapsedSeconds: 600, // 10 minutes
        keystrokesPerWord: 5,
      );
      final net = ScoringService.calculateNetWpm(
        totalTypedCharacters: 1500,
        totalErrors: 10,
        elapsedSeconds: 600,
        keystrokesPerWord: 5,
      );

      // Gross WPM = 1500 / 5 / 10 = 30 WPM
      expect(gross, equals(30.0));
      // Net WPM = 30 - (10 / 10) = 29 WPM
      expect(net, equals(29.0));
      // Verify Gross and Net WPM display different values when errors occur
      expect(gross != net, isTrue);
    });

    test('Zero error typing produces exactly equal Gross WPM and Net WPM', () {
      final gross = ScoringService.calculateGrossWpm(
        totalTypedCharacters: 1500,
        elapsedSeconds: 600,
        keystrokesPerWord: 5,
      );
      final net = ScoringService.calculateNetWpm(
        totalTypedCharacters: 1500,
        totalErrors: 0,
        elapsedSeconds: 600,
        keystrokesPerWord: 5,
      );

      expect(gross, equals(30.0));
      expect(net, equals(30.0));
      expect(gross == net, isTrue);
    });

    test('Net WPM decreases proportionally when penalty errors increase', () {
      final net10 = ScoringService.calculateNetWpm(
        totalTypedCharacters: 1500,
        totalErrors: 10,
        elapsedSeconds: 600,
      );
      final net20 = ScoringService.calculateNetWpm(
        totalTypedCharacters: 1500,
        totalErrors: 20,
        elapsedSeconds: 600,
      );

      expect(net10, equals(29.0));
      expect(net20, equals(28.0));
      expect(net20 < net10, isTrue);
    });

    test('Short session (60s) with 2 errors scales penalty correctly', () {
      // 300 chars in 60s (1 min) = 60 Gross WPM. 2 errors -> Net WPM = 60 - (2 / 1) = 58 WPM.
      final gross = ScoringService.calculateGrossWpm(
        totalTypedCharacters: 300,
        elapsedSeconds: 60,
      );
      final net = ScoringService.calculateNetWpm(
        totalTypedCharacters: 300,
        totalErrors: 2,
        elapsedSeconds: 60,
      );

      expect(gross, equals(60.0));
      expect(net, equals(58.0));
    });

    test('Elapsed time of 0 seconds safely returns 0.0 without division by zero', () {
      final gross = ScoringService.calculateGrossWpm(
        totalTypedCharacters: 1500,
        elapsedSeconds: 0,
      );
      final net = ScoringService.calculateNetWpm(
        totalTypedCharacters: 1500,
        totalErrors: 10,
        elapsedSeconds: 0,
      );

      expect(gross, equals(0.0));
      expect(net, equals(0.0));
    });
  });
}

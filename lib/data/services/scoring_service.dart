import 'dart:math';

/// Detailed result of evaluating a single repetition.
class RepetitionScore {
  const RepetitionScore({
    required this.repetitionNumber,
    required this.totalTypedCharacters,
    required this.correctCharacters,
    required this.incorrectCharacters,
    required this.missingCharacters,
    required this.extraCharacters,
    this.untypedRemainderCharacters = 0,
    required this.totalWordsTyped,
    required this.correctWords,
    required this.incorrectWords,
    required this.missingWords,
    required this.extraWords,
    required this.spellingErrors,
    required this.grossWpm,
    required this.netWpm,
    required this.accuracy,
    required this.isComplete,
    this.bsfHcmResult,
  });

  final int repetitionNumber;
  final int totalTypedCharacters;
  final int correctCharacters;
  final int incorrectCharacters; // Substitutions
  final int missingCharacters;   // Omissions within attempted text
  final int extraCharacters;     // Insertions
  final int untypedRemainderCharacters; // Untyped passage tail (NOT an error)

  final int totalWordsTyped;
  final int correctWords;
  final int incorrectWords;
  final int missingWords;
  final int extraWords;

  final List<WordMistake> spellingErrors;
  final double grossWpm;
  final double netWpm;
  final double accuracy;
  final bool isComplete;
  final BsfHcmResult? bsfHcmResult;

  int get totalErrors => missingWords + incorrectWords + extraWords;
  int get totalPenaltyErrors => totalErrors;
  int get substitutions => incorrectWords;
  int get omissions => missingWords;
  int get insertions => extraWords;

  int get characterSubstitutions => incorrectCharacters;
  int get characterOmissions => missingCharacters;
  int get characterInsertions => extraCharacters;
  int get totalCharacterErrors => missingCharacters + incorrectCharacters + extraCharacters;
}

/// A single aligned word pair between reference and typed input.
class WordAlignmentItem {
  const WordAlignmentItem({
    required this.expectedWord,
    required this.typedWord,
    this.type,
  });

  final String expectedWord;
  final String typedWord;
  final WordMistakeType? type;

  bool get isMatch => type == null;
}

/// Detailed result of word-level sequence alignment.
class WordAlignmentResult {
  const WordAlignmentResult({
    required this.correctWords,
    required this.substitutions,
    required this.omissions,
    required this.insertions,
    required this.untypedRemainderWords,
    required this.alignedWords,
    required this.spellingErrors,
  });

  final int correctWords;
  final int substitutions;
  final int omissions;
  final int insertions;
  final int untypedRemainderWords;
  final List<WordAlignmentItem> alignedWords;
  final List<WordMistake> spellingErrors;

  int get totalErrors => substitutions + omissions + insertions;
  int get totalPenaltyErrors => totalErrors;
  int get incorrectWords => substitutions;
}

/// A specific word-level mistake comparison.
class WordMistake {
  const WordMistake({
    required this.wordIndex,
    required this.expectedWord,
    required this.typedWord,
    required this.type,
  });

  final int wordIndex;
  final String expectedWord;
  final String typedWord;
  final WordMistakeType type;
}

enum WordMistakeType { substitution, omission, insertion }
enum _WordStep { diag, up, left }

/// Aggregate scoring summary across an entire test session.
class SessionScore {
  const SessionScore({
    required this.configuredDurationSeconds,
    required this.actualElapsedSeconds,
    required this.characterToWordRatio,
    required this.totalCharactersTyped,
    required this.totalWordsTyped,
    required this.correctCharacters,
    required this.incorrectCharacters,
    required this.omittedCharacters,
    required this.extraCharacters,
    this.untypedRemainderCharacters = 0,
    required this.correctWords,
    required this.incorrectWords,
    required this.missingWords,
    required this.extraWords,
    required this.grossWpm,
    required this.netWpm,
    required this.accuracy,
    required this.totalErrors,
    required this.completedRepetitions,
    required this.repetitionScores,
    this.bsfHcmResult,
  });

  final int configuredDurationSeconds;
  final int actualElapsedSeconds;
  final int characterToWordRatio;

  final int totalCharactersTyped;
  final int totalWordsTyped;
  final int correctCharacters;
  final int incorrectCharacters; // Character substitutions
  final int omittedCharacters;   // Character omissions
  final int extraCharacters;     // Character insertions
  final int untypedRemainderCharacters; // Untyped passage tail (NOT an error)

  final int correctWords;
  final int incorrectWords;
  final int missingWords;
  final int extraWords;

  final double grossWpm;
  final double netWpm;
  final double accuracy;
  final int totalErrors;
  final int completedRepetitions;

  final List<RepetitionScore> repetitionScores;
  final BsfHcmResult? bsfHcmResult;

  int get substitutions => incorrectWords;
  int get omissions => missingWords;
  int get insertions => extraWords;
  int get totalPenaltyErrors => totalErrors;

  int get characterSubstitutions => incorrectCharacters;
  int get characterOmissions => omittedCharacters;
  int get characterInsertions => extraCharacters;
  int get totalCharacterErrors => omittedCharacters + incorrectCharacters + extraCharacters;
}

/// Configuration model for BSF Head Constable (Ministerial) typing test evaluation.
class BsfHcmConfig {
  const BsfHcmConfig({
    this.requiredWpm = 35.0,
    this.errorTolerance = 0.05,
    this.penaltyPerError = 10.0,
    this.qualifyingAccuracy = 95.0,
    this.standardKeystrokesPerWord = 5,
    this.standardDurationMinutes = 10.0,
  });

  /// Qualifying speed threshold in WPM (English: 35 WPM, Hindi: 30 WPM).
  final double requiredWpm;

  /// Error tolerance allowance (default: 5% = 0.05 of gross words).
  final double errorTolerance;

  /// Words deducted from gross count per excess error (default: 10 words).
  final double penaltyPerError;

  /// Minimum qualifying accuracy percentage (default: 95.0%).
  final double qualifyingAccuracy;

  /// Standard characters / keystrokes per word (default: 5).
  final int standardKeystrokesPerWord;

  /// Standard test duration in minutes (default: 10.0).
  final double standardDurationMinutes;

  static const defaultEnglish = BsfHcmConfig();
  static const defaultHindi = BsfHcmConfig(requiredWpm: 30.0);
}

/// Complete mathematical breakdown of BSF HCM scoring criteria.
class BsfHcmResult {
  const BsfHcmResult({
    required this.totalKeystrokes,
    required this.grossWords,
    required this.elapsedMinutes,
    required this.grossWpm,
    required this.totalErrors,
    required this.allowedErrors,
    required this.excessErrors,
    required this.penaltyWords,
    required this.netWords,
    required this.netWpm,
    required this.accuracy,
    required this.isQualified,
    required this.config,
  });

  final int totalKeystrokes;
  final double grossWords;
  final double elapsedMinutes;
  final double grossWpm;
  final int totalErrors;
  final int allowedErrors;
  final int excessErrors;
  final double penaltyWords;
  final double netWords;
  final double netWpm;
  final double accuracy;
  final bool isQualified;
  final BsfHcmConfig config;
}

/// Pure Dart, deterministic scoring and comparison service used identically
/// across Windows Desktop and Flutter Web.
class ScoringService {
  ScoringService._();

  /// Calculates Gross WPM based on standard formula:
  /// Gross WPM = (Total typed characters / keystrokesPerWord) / elapsedMinutes.
  static double calculateGrossWpm({
    required int totalTypedCharacters,
    required int elapsedSeconds,
    int keystrokesPerWord = 5,
  }) {
    if (elapsedSeconds <= 0 || keystrokesPerWord <= 0) return 0.0;
    final elapsedMinutes = elapsedSeconds / 60.0;
    final standardWords = totalTypedCharacters / keystrokesPerWord;
    final wpm = standardWords / elapsedMinutes;
    return (wpm * 100).roundToDouble() / 100.0;
  }

  /// Calculates Net WPM based on Practice Scoring formula or BSF HCM rules:
  /// When [useBsfHcmRules] is true:
  ///   allowedErrors = floor(errorTolerance * grossWords) [default 5%]
  ///   excessErrors = max(0, totalErrors - allowedErrors)
  ///   penaltyWords = penaltyPerError (10) * excessErrors
  ///   netWords = max(0, grossWords - penaltyWords)
  ///   netWpm = netWords / elapsedMinutes
  /// When [useBsfHcmRules] is false and [penaltyEnabled] is true:
  ///   Net WPM = max(0, Gross WPM - (totalErrors / elapsedMinutes))
  /// When error penalty is disabled, Net WPM = Gross WPM.
  static double calculateNetWpm({
    required int totalTypedCharacters,
    required int totalErrors,
    required int elapsedSeconds,
    int keystrokesPerWord = 5,
    bool penaltyEnabled = true,
    bool useBsfHcmRules = false,
    BsfHcmConfig bsfConfig = const BsfHcmConfig(),
  }) {
    if (elapsedSeconds <= 0 || keystrokesPerWord <= 0) return 0.0;
    final gross = calculateGrossWpm(
      totalTypedCharacters: totalTypedCharacters,
      elapsedSeconds: elapsedSeconds,
      keystrokesPerWord: keystrokesPerWord,
    );

    if (!penaltyEnabled) {
      return gross;
    }

    if (useBsfHcmRules) {
      final elapsedMinutes = elapsedSeconds / 60.0;
      final bsf = calculateBsfHcmMetrics(
        totalKeystrokes: totalTypedCharacters,
        totalErrors: totalErrors,
        elapsedMinutes: elapsedMinutes,
        config: bsfConfig,
      );
      return bsf.netWpm;
    }

    final elapsedMinutes = elapsedSeconds / 60.0;
    final errorPenalty = totalErrors / elapsedMinutes;
    final net = max(0.0, gross - errorPenalty);
    return (net * 100).roundToDouble() / 100.0;
  }

  /// Evaluates typing metrics according to BSF Head Constable (Ministerial) rules:
  /// - Standard word length = 5 keystrokes
  /// - Gross Words = totalKeystrokes / standardKeystrokesPerWord (5)
  /// - Gross WPM = grossWords / elapsedMinutes
  /// - Allowed Errors = floor(errorTolerance * grossWords) [up to 5% errors ignored]
  /// - Excess Errors = max(0, totalErrors - allowedErrors)
  /// - Penalty Words = penaltyPerError (10) * excessErrors
  /// - Net Words = max(0, grossWords - penaltyWords)
  /// - Net WPM = netWords / elapsedMinutes
  /// - Accuracy = ((grossWords - totalErrors) / grossWords) * 100 (clamped [0, 100])
  /// - Qualifying condition: netWpm >= requiredWpm (35 WPM English, 30 WPM Hindi)
  static BsfHcmResult calculateBsfHcmMetrics({
    required int totalKeystrokes,
    required int totalErrors,
    required double elapsedMinutes,
    BsfHcmConfig config = const BsfHcmConfig(),
  }) {
    if (elapsedMinutes <= 0 || config.standardKeystrokesPerWord <= 0) {
      return BsfHcmResult(
        totalKeystrokes: totalKeystrokes,
        grossWords: 0.0,
        elapsedMinutes: elapsedMinutes,
        grossWpm: 0.0,
        totalErrors: totalErrors,
        allowedErrors: 0,
        excessErrors: totalErrors,
        penaltyWords: 0.0,
        netWords: 0.0,
        netWpm: 0.0,
        accuracy: 0.0,
        isQualified: false,
        config: config,
      );
    }

    final double grossWords = totalKeystrokes / config.standardKeystrokesPerWord;
    final double rawGrossWpm = grossWords / elapsedMinutes;
    final double grossWpm = (rawGrossWpm * 100).roundToDouble() / 100.0;

    final int allowedErrors = (config.errorTolerance * grossWords).floor();
    final int excessErrors = max(0, totalErrors - allowedErrors);
    final double penaltyWords = config.penaltyPerError * excessErrors;
    final double netWords = max(0.0, grossWords - penaltyWords);

    final double rawNetWpm = netWords / elapsedMinutes;
    final double netWpm = (rawNetWpm * 100).roundToDouble() / 100.0;

    final double rawAccuracy = grossWords > 0
        ? ((grossWords - totalErrors) / grossWords) * 100.0
        : (totalErrors == 0 ? 100.0 : 0.0);
    final double accuracy = (max(0.0, min(100.0, rawAccuracy)) * 10).roundToDouble() / 10.0;

    final bool isQualified = netWpm >= config.requiredWpm;

    return BsfHcmResult(
      totalKeystrokes: totalKeystrokes,
      grossWords: grossWords,
      elapsedMinutes: elapsedMinutes,
      grossWpm: grossWpm,
      totalErrors: totalErrors,
      allowedErrors: allowedErrors,
      excessErrors: excessErrors,
      penaltyWords: penaltyWords,
      netWords: netWords,
      netWpm: netWpm,
      accuracy: accuracy,
      isQualified: isQualified,
      config: config,
    );
  }

  /// Calculates Accuracy percentage:
  /// (correctCharacters / totalTypedCharacters) * 100.
  /// If totalTypedCharacters is 0, returns 100.0%.
  static double calculateAccuracy({
    required int correctCharacters,
    required int totalTypedCharacters,
  }) {
    if (totalTypedCharacters <= 0) return 100.0;
    final raw = (correctCharacters / totalTypedCharacters) * 100.0;
    return (max(0.0, min(100.0, raw)) * 10).roundToDouble() / 10.0;
  }

  /// Evaluates a single repetition against the reference passage using
  /// sequence alignment to correctly classify matches, substitutions,
  /// omissions, and insertions without misaligning following text.
  /// Word-level error classification groups mistakes properly:
  /// - Multiple character mistakes within the same word = 1 substitution error.
  /// - Omitted word = 1 omission error.
  /// - Extra word = 1 insertion error.
  /// - Completely correct word = 0 errors.
  /// Untyped passage tail is NOT counted as errors.
  static RepetitionScore evaluateRepetition({
    required int repetitionNumber,
    required String referenceText,
    required String typedText,
    required int elapsedSeconds,
    int keystrokesPerWord = 5,
    bool penaltyEnabled = true,
    bool useBsfHcmRules = false,
    BsfHcmConfig bsfConfig = const BsfHcmConfig(),
  }) {
    final charAlignment = alignTexts(referenceText, typedText);
    final wordAlignment = alignWords(referenceText, typedText);

    final correctChars = charAlignment.correctCharacters;
    final substitutionsChars = charAlignment.substitutions;
    final omissionsChars = charAlignment.omissions;
    final insertionsChars = charAlignment.insertions;
    final untypedRemainder = charAlignment.untypedRemainder;

    final grossWpm = calculateGrossWpm(
      totalTypedCharacters: typedText.length,
      elapsedSeconds: elapsedSeconds,
      keystrokesPerWord: keystrokesPerWord,
    );

    // Single source of truth: Word-level total penalty errors
    final totalWordErrors = wordAlignment.totalErrors;

    final netWpm = calculateNetWpm(
      totalTypedCharacters: typedText.length,
      totalErrors: totalWordErrors,
      elapsedSeconds: elapsedSeconds,
      keystrokesPerWord: keystrokesPerWord,
      penaltyEnabled: penaltyEnabled,
      useBsfHcmRules: useBsfHcmRules,
      bsfConfig: bsfConfig,
    );

    final bsfResult = calculateBsfHcmMetrics(
      totalKeystrokes: typedText.length,
      totalErrors: totalWordErrors,
      elapsedMinutes: elapsedSeconds / 60.0,
      config: bsfConfig,
    );

    final accuracy = useBsfHcmRules
        ? bsfResult.accuracy
        : calculateAccuracy(
            correctCharacters: correctChars,
            totalTypedCharacters: typedText.length,
          );

    final isComplete = typedText == referenceText;
    final typedWords = _tokenizeWords(typedText);

    return RepetitionScore(
      repetitionNumber: repetitionNumber,
      totalTypedCharacters: typedText.length,
      correctCharacters: correctChars,
      incorrectCharacters: substitutionsChars,
      missingCharacters: omissionsChars,
      extraCharacters: insertionsChars,
      untypedRemainderCharacters: untypedRemainder,
      totalWordsTyped: typedWords.length,
      correctWords: wordAlignment.correctWords,
      incorrectWords: wordAlignment.incorrectWords,
      missingWords: wordAlignment.omissions,
      extraWords: wordAlignment.insertions,
      spellingErrors: wordAlignment.spellingErrors,
      grossWpm: grossWpm,
      netWpm: netWpm,
      accuracy: accuracy,
      isComplete: isComplete,
      bsfHcmResult: bsfResult,
    );
  }

  /// Aggregates scoring across all repetitions of a test session.
  static SessionScore aggregateSession({
    required int configuredDurationSeconds,
    required int actualElapsedSeconds,
    required int characterToWordRatio,
    required String referenceText,
    required List<String> repetitionsTyped,
    bool penaltyEnabled = true,
    bool useBsfHcmRules = false,
    BsfHcmConfig bsfConfig = const BsfHcmConfig(),
  }) {
    final repetitionScores = <RepetitionScore>[];
    int totalTypedChars = 0;
    int totalWords = 0;
    int correctChars = 0;
    int incorrectChars = 0;
    int omittedChars = 0;
    int extraChars = 0;
    int untypedRemainder = 0;
    int correctWords = 0;
    int incorrectWords = 0;
    int missingWords = 0;
    int extraWords = 0;
    int completedRepetitions = 0;

    final repElapsed = repetitionsTyped.isEmpty
        ? actualElapsedSeconds
        : max(1, actualElapsedSeconds ~/ repetitionsTyped.length);

    for (int i = 0; i < repetitionsTyped.length; i++) {
      final repTyped = repetitionsTyped[i];
      final repScore = evaluateRepetition(
        repetitionNumber: i + 1,
        referenceText: referenceText,
        typedText: repTyped,
        elapsedSeconds: repElapsed,
        keystrokesPerWord: characterToWordRatio,
        penaltyEnabled: penaltyEnabled,
        useBsfHcmRules: useBsfHcmRules,
        bsfConfig: bsfConfig,
      );

      repetitionScores.add(repScore);
      totalTypedChars += repScore.totalTypedCharacters;
      totalWords += repScore.totalWordsTyped;
      correctChars += repScore.correctCharacters;
      incorrectChars += repScore.incorrectCharacters;
      omittedChars += repScore.missingCharacters;
      extraChars += repScore.extraCharacters;
      untypedRemainder += repScore.untypedRemainderCharacters;
      correctWords += repScore.correctWords;
      incorrectWords += repScore.incorrectWords;
      missingWords += repScore.missingWords;
      extraWords += repScore.extraWords;

      if (repScore.isComplete) {
        completedRepetitions++;
      }
    }

    final grossWpm = calculateGrossWpm(
      totalTypedCharacters: totalTypedChars,
      elapsedSeconds: actualElapsedSeconds,
      keystrokesPerWord: characterToWordRatio,
    );

    // Single source of truth: Word-level Total Errors = Omissions + Substitutions + Insertions
    final totalErrors = missingWords + incorrectWords + extraWords;

    final netWpm = calculateNetWpm(
      totalTypedCharacters: totalTypedChars,
      totalErrors: totalErrors,
      elapsedSeconds: actualElapsedSeconds,
      keystrokesPerWord: characterToWordRatio,
      penaltyEnabled: penaltyEnabled,
      useBsfHcmRules: useBsfHcmRules,
      bsfConfig: bsfConfig,
    );

    final bsfResult = calculateBsfHcmMetrics(
      totalKeystrokes: totalTypedChars,
      totalErrors: totalErrors,
      elapsedMinutes: actualElapsedSeconds / 60.0,
      config: bsfConfig,
    );

    final accuracy = useBsfHcmRules
        ? bsfResult.accuracy
        : calculateAccuracy(
            correctCharacters: correctChars,
            totalTypedCharacters: totalTypedChars,
          );

    return SessionScore(
      configuredDurationSeconds: configuredDurationSeconds,
      actualElapsedSeconds: actualElapsedSeconds,
      characterToWordRatio: characterToWordRatio,
      totalCharactersTyped: totalTypedChars,
      totalWordsTyped: totalWords,
      correctCharacters: correctChars,
      incorrectCharacters: incorrectChars,
      omittedCharacters: omittedChars,
      extraCharacters: extraChars,
      untypedRemainderCharacters: untypedRemainder,
      correctWords: correctWords,
      incorrectWords: incorrectWords,
      missingWords: missingWords,
      extraWords: extraWords,
      grossWpm: grossWpm,
      netWpm: netWpm,
      accuracy: accuracy,
      totalErrors: totalErrors,
      completedRepetitions: completedRepetitions,
      repetitionScores: repetitionScores,
      bsfHcmResult: bsfResult,
    );
  }

  static List<String> _tokenizeWords(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return const [];
    return trimmed.split(RegExp(r'\s+'));
  }

  /// Sequence Alignment algorithm at the Word Level.
  /// Aligns [typedText] with [referenceText] using dynamic programming to
  /// accurately distinguish correct words, substituted words, omitted words,
  /// and inserted words without cascading misalignment.
  /// - One incorrect word = one word-level error (regardless of character count).
  /// - Completely correct word = 0 errors.
  /// - Missing word = 1 omission error.
  /// - Extra word = 1 insertion error.
  /// - Untyped passage tail is NOT penalized.
  static WordAlignmentResult alignWords(String referenceText, String typedText) {
    final refWords = _tokenizeWords(referenceText);
    final typedWords = _tokenizeWords(typedText);

    if (refWords.isEmpty && typedWords.isEmpty) {
      return const WordAlignmentResult(
        correctWords: 0,
        substitutions: 0,
        omissions: 0,
        insertions: 0,
        untypedRemainderWords: 0,
        alignedWords: [],
        spellingErrors: [],
      );
    }

    if (refWords.isEmpty) {
      final aligned = <WordAlignmentItem>[];
      final errors = <WordMistake>[];
      for (int i = 0; i < typedWords.length; i++) {
        aligned.add(
          WordAlignmentItem(
            expectedWord: '',
            typedWord: typedWords[i],
            type: WordMistakeType.insertion,
          ),
        );
        errors.add(
          WordMistake(
            wordIndex: i,
            expectedWord: '',
            typedWord: typedWords[i],
            type: WordMistakeType.insertion,
          ),
        );
      }
      return WordAlignmentResult(
        correctWords: 0,
        substitutions: 0,
        omissions: 0,
        insertions: typedWords.length,
        untypedRemainderWords: 0,
        alignedWords: aligned,
        spellingErrors: errors,
      );
    }

    if (typedWords.isEmpty) {
      return WordAlignmentResult(
        correctWords: 0,
        substitutions: 0,
        omissions: 0,
        insertions: 0,
        untypedRemainderWords: refWords.length,
        alignedWords: const [],
        spellingErrors: const [],
      );
    }

    final m = typedWords.length;
    final n = refWords.length;

    // Window limit for prefix alignment
    final int windowN;
    if (m >= n || n <= 50) {
      windowN = n;
    } else {
      final maxLookahead = max<int>(15, (m * 0.4).round());
      windowN = min(n, m + maxLookahead);
    }

    // DP table: (m + 1) rows, (windowN + 1) cols
    // dp[i][j]: minimum penalty cost to align typedWords[0..i-1] with refWords[0..j-1]
    final dp = List.generate(m + 1, (_) => List<int>.filled(windowN + 1, 0));
    final matches = List.generate(m + 1, (_) => List<int>.filled(windowN + 1, 0));
    final steps = List.generate(m + 1, (_) => List<_WordStep>.filled(windowN + 1, _WordStep.diag));

    for (int i = 0; i <= m; i++) {
      dp[i][0] = i; // insertions in typed
      matches[i][0] = 0;
      steps[i][0] = _WordStep.up;
    }
    for (int j = 0; j <= windowN; j++) {
      dp[0][j] = j; // omissions in reference
      matches[0][j] = 0;
      steps[0][j] = _WordStep.left;
    }

    for (int i = 1; i <= m; i++) {
      final tWord = typedWords[i - 1];
      for (int j = 1; j <= windowN; j++) {
        final rWord = refWords[j - 1];
        final bool isMatch = (tWord == rWord);

        final int subCost = dp[i - 1][j - 1] + (isMatch ? 0 : 1);
        final int subMatches = matches[i - 1][j - 1] + (isMatch ? 1 : 0);

        final int insCost = dp[i - 1][j] + 1;
        final int insMatches = matches[i - 1][j];

        final int delCost = dp[i][j - 1] + 1;
        final int delMatches = matches[i][j - 1];

        // Choose best predecessor: min cost, on tie max matches, on tie prefer sub
        _WordStep step = _WordStep.diag;
        int bestCost = subCost;
        int bestMatches = subMatches;

        if (insCost < bestCost || (insCost == bestCost && insMatches > bestMatches)) {
          bestCost = insCost;
          bestMatches = insMatches;
          step = _WordStep.up;
        }

        if (delCost < bestCost || (delCost == bestCost && delMatches > bestMatches)) {
          bestCost = delCost;
          bestMatches = delMatches;
          step = _WordStep.left;
        }

        dp[i][j] = bestCost;
        matches[i][j] = bestMatches;
        steps[i][j] = step;
      }
    }

    // Find optimal ending j in reference for the prefix of typedWords
    int bestJ = windowN;
    if (m < n) {
      int minCost = 1 << 30;
      int maxMatch = -1;

      final int searchStart = max<int>(1, m - max<int>(10, (m * 0.35).round()));
      final int searchEnd = windowN;

      for (int j = searchStart; j <= searchEnd; j++) {
        final cost = dp[m][j];
        final match = matches[m][j];

        if (cost < minCost ||
            (cost == minCost && match > maxMatch) ||
            (cost == minCost && match == maxMatch && (j - m).abs() < (bestJ - m).abs())) {
          minCost = cost;
          maxMatch = match;
          bestJ = j;
        }
      }
    } else {
      bestJ = min(n, windowN);
    }

    // Traceback from (m, bestJ)
    int currI = m;
    int currJ = bestJ;

    int correctWords = 0;
    int substitutions = 0;
    int omissions = 0;
    int insertions = 0;

    final revAligned = <WordAlignmentItem>[];
    final revErrors = <WordMistake>[];

    while (currI > 0 || currJ > 0) {
      if (currI > 0 && currJ > 0 && steps[currI][currJ] == _WordStep.diag) {
        final tWord = typedWords[currI - 1];
        final rWord = refWords[currJ - 1];
        final bool isMatch = (tWord == rWord);

        if (isMatch) {
          correctWords++;
          revAligned.add(
            WordAlignmentItem(
              expectedWord: rWord,
              typedWord: tWord,
              type: null,
            ),
          );
        } else {
          substitutions++;
          revAligned.add(
            WordAlignmentItem(
              expectedWord: rWord,
              typedWord: tWord,
              type: WordMistakeType.substitution,
            ),
          );
          revErrors.add(
            WordMistake(
              wordIndex: currJ - 1,
              expectedWord: rWord,
              typedWord: tWord,
              type: WordMistakeType.substitution,
            ),
          );
        }
        currI--;
        currJ--;
      } else if (currI > 0 && (currJ == 0 || steps[currI][currJ] == _WordStep.up)) {
        insertions++;
        revAligned.add(
          WordAlignmentItem(
            expectedWord: '',
            typedWord: typedWords[currI - 1],
            type: WordMistakeType.insertion,
          ),
        );
        revErrors.add(
          WordMistake(
            wordIndex: currJ,
            expectedWord: '',
            typedWord: typedWords[currI - 1],
            type: WordMistakeType.insertion,
          ),
        );
        currI--;
      } else if (currJ > 0 && (currI == 0 || steps[currI][currJ] == _WordStep.left)) {
        omissions++;
        revAligned.add(
          WordAlignmentItem(
            expectedWord: refWords[currJ - 1],
            typedWord: '',
            type: WordMistakeType.omission,
          ),
        );
        revErrors.add(
          WordMistake(
            wordIndex: currJ - 1,
            expectedWord: refWords[currJ - 1],
            typedWord: '',
            type: WordMistakeType.omission,
          ),
        );
        currJ--;
      } else {
        break;
      }
    }

    final untyped = n - bestJ;

    return WordAlignmentResult(
      correctWords: correctWords,
      substitutions: substitutions,
      omissions: omissions,
      insertions: insertions,
      untypedRemainderWords: max(0, untyped),
      alignedWords: revAligned.reversed.toList(),
      spellingErrors: revErrors.reversed.toList(),
    );
  }

  /// Sequence Alignment algorithm (Semi-Global Prefix Alignment)
  /// Aligns [typedText] with the attempted prefix of [referenceText].
  /// Distinguishes matches, substitutions, omissions, insertions, and untyped tail.
  static AlignmentResult alignTexts(String referenceText, String typedText) {
    if (referenceText.isEmpty && typedText.isEmpty) {
      return const AlignmentResult(
        correctCharacters: 0,
        substitutions: 0,
        omissions: 0,
        insertions: 0,
        untypedRemainder: 0,
        alignedRef: '',
        alignedTyped: '',
      );
    }

    if (referenceText.isEmpty) {
      return AlignmentResult(
        correctCharacters: 0,
        substitutions: 0,
        omissions: 0,
        insertions: typedText.length,
        untypedRemainder: 0,
        alignedRef: '-' * typedText.length,
        alignedTyped: typedText,
      );
    }

    if (typedText.isEmpty) {
      return AlignmentResult(
        correctCharacters: 0,
        substitutions: 0,
        omissions: 0,
        insertions: 0,
        untypedRemainder: referenceText.length,
        alignedRef: '',
        alignedTyped: '',
      );
    }

    final refRunes = referenceText.runes.toList();
    final typedRunes = typedText.runes.toList();
    final m = typedRunes.length;
    final n = refRunes.length;

    // Window limit for prefix alignment
    final maxLookahead = max<int>(100, (m * 0.35).round());
    final windowN = min(n, m + maxLookahead);

    // DP table: (m + 1) rows, (windowN + 1) cols
    final dp = List.generate(m + 1, (_) => List<int>.filled(windowN + 1, 0));

    for (int i = 0; i <= m; i++) {
      dp[i][0] = i; // insertions in typed
    }
    for (int j = 0; j <= windowN; j++) {
      dp[0][j] = j; // omissions in reference
    }

    for (int i = 1; i <= m; i++) {
      final tChar = typedRunes[i - 1];
      for (int j = 1; j <= windowN; j++) {
        final rChar = refRunes[j - 1];
        final cost = (tChar == rChar) ? 0 : 1;

        final subCost = dp[i - 1][j - 1] + cost;
        final insCost = dp[i - 1][j] + 1; // gap in ref
        final delCost = dp[i][j - 1] + 1; // gap in typed

        dp[i][j] = min(subCost, min(insCost, delCost));
      }
    }

    // Find optimal ending j in reference for the prefix of typedText
    int bestJ = windowN;
    int minCost = 1 << 30;

    final int searchStart = max<int>(1, m - max<int>(30, (m * 0.2).round()));
    final int searchEnd = windowN;

    for (int j = searchStart; j <= searchEnd; j++) {
      final score = dp[m][j];
      if (score < minCost) {
        minCost = score;
        bestJ = j;
      } else if (score == minCost && (j - m).abs() < (bestJ - m).abs()) {
        bestJ = j;
      }
    }

    // Traceback from (m, bestJ)
    int currI = m;
    int currJ = bestJ;

    int correct = 0;
    int substitutions = 0;
    int omissions = 0;
    int insertions = 0;

    final revRef = <int>[];
    final revTyped = <int>[];

    while (currI > 0 || currJ > 0) {
      if (currI > 0 && currJ > 0) {
        final tChar = typedRunes[currI - 1];
        final rChar = refRunes[currJ - 1];
        final matchCost = (tChar == rChar) ? 0 : 1;

        if (dp[currI][currJ] == dp[currI - 1][currJ - 1] + matchCost) {
          if (matchCost == 0) {
            correct++;
          } else {
            substitutions++;
          }
          revRef.add(rChar);
          revTyped.add(tChar);
          currI--;
          currJ--;
          continue;
        }
      }

      if (currI > 0 && dp[currI][currJ] == dp[currI - 1][currJ] + 1) {
        insertions++;
        revRef.add(0x2D); // '-'
        revTyped.add(typedRunes[currI - 1]);
        currI--;
        continue;
      }

      if (currJ > 0 && dp[currI][currJ] == dp[currI][currJ - 1] + 1) {
        omissions++;
        revRef.add(refRunes[currJ - 1]);
        revTyped.add(0x2D); // '-'
        currJ--;
        continue;
      }

      if (currI > 0) {
        insertions++;
        revRef.add(0x2D);
        revTyped.add(typedRunes[currI - 1]);
        currI--;
      } else if (currJ > 0) {
        omissions++;
        revRef.add(refRunes[currJ - 1]);
        revTyped.add(0x2D);
        currJ--;
      }
    }

    final untyped = n - bestJ;

    return AlignmentResult(
      correctCharacters: correct,
      substitutions: substitutions,
      omissions: omissions,
      insertions: insertions,
      untypedRemainder: max(0, untyped),
      alignedRef: String.fromCharCodes(revRef.reversed),
      alignedTyped: String.fromCharCodes(revTyped.reversed),
    );
  }
}

class AlignmentResult {
  const AlignmentResult({
    required this.correctCharacters,
    required this.substitutions,
    required this.omissions,
    required this.insertions,
    required this.untypedRemainder,
    required this.alignedRef,
    required this.alignedTyped,
  });

  final int correctCharacters;
  final int substitutions;
  final int omissions;
  final int insertions;
  final int untypedRemainder;
  final String alignedRef;
  final String alignedTyped;

  int get totalErrors => substitutions + omissions + insertions;
  int get totalTyped => correctCharacters + substitutions + insertions;
}

/// Architectural specifications for upcoming test rules & scoring engines.
///
/// Preserved as planned requirements for future chunks:
/// 1. Error penalty enabled/disabled.
/// 2. Character-to-word ratio configurable, defaulting to 5 keystrokes = 1 word.
/// 3. Error threshold configuration, with 5% available as a configurable practice setting.
/// 4. Extra-error deduction enabled/disabled and configurable.
/// 5. Clear distinction between custom practice scoring and verified official exam scoring.
///
/// PERMANENT RULE:
/// During an actual typing test, the reference passage must NEVER appear on the typing screen.
/// The input area must remain completely blank.
class PlannedRulesAndScoring {
  PlannedRulesAndScoring._();

  /// Default practice ratio. It is configurable, not a verified official rule.
  static const int defaultKeystrokesPerWord = 5;

  /// Default practice threshold, preserved as configurable future data.
  static const double defaultErrorAllowancePercent = 5.0;

  /// Suggested practice durations in minutes.
  static const List<int> standardDurationsMinutes = [5, 10, 15, 30];

  /// Default practice duration.
  static const int officialExamDurationMinutes = 10;

  /// Suggested practice target; verify any recruitment requirement separately.
  static const int targetSpeedWpmEnglish = 35;
}

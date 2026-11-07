class ApplicationSettings {
  const ApplicationSettings({
    this.onboardingCompleted = false,
    this.defaultTestDuration = 10,
    this.customTestDuration = 10,
    this.characterToWordRatio = 5,
    this.defaultTestMode = 'practice',
    this.soundEnabled = true,
    this.themePreference = 'light',
    this.autoLoopEnabled = false,
    this.errorPenaltyEnabled = false,
    this.errorThresholdPercentage = 5,
    this.extraErrorDeductionEnabled = false,
    this.extraErrorDeductionValue = 0,
    this.dailyPracticeGoalMinutes = 15,
    this.scoringProfile = 'custom_practice',
  });
  final bool onboardingCompleted,
      soundEnabled,
      autoLoopEnabled,
      errorPenaltyEnabled,
      extraErrorDeductionEnabled;
  final int defaultTestDuration,
      customTestDuration,
      characterToWordRatio,
      extraErrorDeductionValue,
      dailyPracticeGoalMinutes;
  final double errorThresholdPercentage;
  final String defaultTestMode, themePreference, scoringProfile;
  factory ApplicationSettings.fromMap(Map<String, Object?> map) =>
      ApplicationSettings(
        onboardingCompleted: (map['onboarding_completed'] as int? ?? 0) == 1,
        defaultTestDuration: map['default_test_duration'] as int? ?? 10,
        customTestDuration: map['custom_test_duration'] as int? ?? 10,
        characterToWordRatio: map['character_to_word_ratio'] as int? ?? 5,
        defaultTestMode: map['default_test_mode'] as String? ?? 'practice',
        soundEnabled: (map['sound_enabled'] as int? ?? 1) == 1,
        themePreference: map['theme_preference'] as String? ?? 'light',
        autoLoopEnabled: (map['auto_loop_enabled'] as int? ?? 0) == 1,
        errorPenaltyEnabled: (map['error_penalty_enabled'] as int? ?? 0) == 1,
        errorThresholdPercentage:
            (map['error_threshold_percentage'] as num? ?? 5).toDouble(),
        extraErrorDeductionEnabled:
            (map['extra_error_deduction_enabled'] as int? ?? 0) == 1,
        extraErrorDeductionValue:
            map['extra_error_deduction_value'] as int? ?? 0,
        dailyPracticeGoalMinutes:
            map['daily_practice_goal_minutes'] as int? ?? 15,
        scoringProfile: map['scoring_profile'] as String? ?? 'custom_practice',
      );
  Map<String, Object?> toMap() => {
    'id': 1,
    'onboarding_completed': onboardingCompleted ? 1 : 0,
    'default_test_duration': defaultTestDuration,
    'custom_test_duration': customTestDuration,
    'character_to_word_ratio': characterToWordRatio,
    'default_test_mode': defaultTestMode,
    'sound_enabled': soundEnabled ? 1 : 0,
    'theme_preference': themePreference,
    'auto_loop_enabled': autoLoopEnabled ? 1 : 0,
    'error_penalty_enabled': errorPenaltyEnabled ? 1 : 0,
    'error_threshold_percentage': errorThresholdPercentage,
    'extra_error_deduction_enabled': extraErrorDeductionEnabled ? 1 : 0,
    'extra_error_deduction_value': extraErrorDeductionValue,
    'daily_practice_goal_minutes': dailyPracticeGoalMinutes,
    'scoring_profile': scoringProfile,
  };
  ApplicationSettings copyWith({
    bool? onboardingCompleted,
    int? defaultTestDuration,
    int? customTestDuration,
    int? characterToWordRatio,
    String? defaultTestMode,
    bool? soundEnabled,
    String? themePreference,
    bool? autoLoopEnabled,
    bool? errorPenaltyEnabled,
    double? errorThresholdPercentage,
    bool? extraErrorDeductionEnabled,
    int? extraErrorDeductionValue,
    int? dailyPracticeGoalMinutes,
    String? scoringProfile,
  }) => ApplicationSettings(
    onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
    defaultTestDuration: defaultTestDuration ?? this.defaultTestDuration,
    customTestDuration: customTestDuration ?? this.customTestDuration,
    characterToWordRatio: characterToWordRatio ?? this.characterToWordRatio,
    defaultTestMode: defaultTestMode ?? this.defaultTestMode,
    soundEnabled: soundEnabled ?? this.soundEnabled,
    themePreference: themePreference ?? this.themePreference,
    autoLoopEnabled: autoLoopEnabled ?? this.autoLoopEnabled,
    errorPenaltyEnabled: errorPenaltyEnabled ?? this.errorPenaltyEnabled,
    errorThresholdPercentage:
        errorThresholdPercentage ?? this.errorThresholdPercentage,
    extraErrorDeductionEnabled:
        extraErrorDeductionEnabled ?? this.extraErrorDeductionEnabled,
    extraErrorDeductionValue:
        extraErrorDeductionValue ?? this.extraErrorDeductionValue,
    dailyPracticeGoalMinutes:
        dailyPracticeGoalMinutes ?? this.dailyPracticeGoalMinutes,
    scoringProfile: scoringProfile ?? this.scoringProfile,
  );
}

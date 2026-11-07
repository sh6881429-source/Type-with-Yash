import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/application_settings.dart';

/// Browser-compatible application settings storage using SharedPreferences (localStorage).
/// Persists settings across browser refreshes and restarts without SQLite.
class SettingsRepository {
  static const _storageKey = 'type_with_yash_app_settings';

  Future<ApplicationSettings> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_storageKey);
    if (jsonStr == null || jsonStr.isEmpty) {
      return const ApplicationSettings();
    }

    try {
      final map = jsonDecode(jsonStr) as Map;
      return _validated(ApplicationSettings.fromMap(Map<String, Object?>.from(map)));
    } catch (_) {
      return const ApplicationSettings();
    }
  }

  Future<void> saveSettings(ApplicationSettings s) async {
    final valid = _validated(s);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(valid.toMap()));
  }

  Future<void> updateSetting(String key, Object value) async {
    const allowed = {
      'onboarding_completed',
      'default_test_duration',
      'custom_test_duration',
      'character_to_word_ratio',
      'default_test_mode',
      'sound_enabled',
      'theme_preference',
      'auto_loop_enabled',
      'error_penalty_enabled',
      'error_threshold_percentage',
      'extra_error_deduction_enabled',
      'extra_error_deduction_value',
      'daily_practice_goal_minutes',
      'scoring_profile',
    };
    if (!allowed.contains(key)) throw ArgumentError.value(key, 'key');

    final current = await loadSettings();
    final map = current.toMap();
    map[key] = value;
    await saveSettings(ApplicationSettings.fromMap(map));
  }

  Future<void> resetSettingsToDefaults() =>
      saveSettings(const ApplicationSettings());

  ApplicationSettings _validated(ApplicationSettings s) {
    if (s.characterToWordRatio < 1 ||
        s.characterToWordRatio > 20 ||
        s.defaultTestDuration < 1 ||
        s.defaultTestDuration > 120 ||
        s.customTestDuration < 1 ||
        s.customTestDuration > 120 ||
        s.errorThresholdPercentage < 0 ||
        s.errorThresholdPercentage > 100 ||
        s.extraErrorDeductionValue < 0) {
      return const ApplicationSettings();
    }
    return s;
  }
}

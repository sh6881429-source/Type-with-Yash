import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../database/app_database.dart';
import '../models/application_settings.dart';

class SettingsRepository {
  SettingsRepository({AppDatabase? database})
    : _database = database ?? AppDatabase.instance;
  final AppDatabase _database;

  Future<ApplicationSettings> loadSettings() async {
    final db = await _database.database;
    final rows = await db.query('app_settings', where: 'id=1');
    if (rows.isEmpty) {
      final d = ApplicationSettings();
      await db.insert('app_settings', d.toMap());
      return d;
    }
    final map = Map<String, Object?>.from(rows.first);
    if (!map.containsKey('daily_practice_goal_minutes')) {
      final meta = await db.query('app_metadata', where: 'key=?', whereArgs: ['daily_practice_goal_minutes']);
      if (meta.isNotEmpty) {
        map['daily_practice_goal_minutes'] = int.tryParse(meta.first['value'] as String? ?? '15') ?? 15;
      }
    }
    return _validated(ApplicationSettings.fromMap(map));
  }

  Future<void> saveSettings(ApplicationSettings s) async {
    final valid = _validated(s);
    final db = await _database.database;
    await db.insert(
      'app_metadata',
      {'key': 'daily_practice_goal_minutes', 'value': valid.dailyPracticeGoalMinutes.toString()},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    try {
      await db.update(
        'app_settings',
        valid.toMap(),
        where: 'id=1',
      );
    } catch (_) {
      final map = valid.toMap()..remove('daily_practice_goal_minutes');
      await db.update('app_settings', map, where: 'id=1');
    }
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

    final db = await _database.database;
    if (key == 'daily_practice_goal_minutes') {
      await db.insert(
        'app_metadata',
        {'key': 'daily_practice_goal_minutes', 'value': value.toString()},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      try {
        await db.update('app_settings', {key: value}, where: 'id=1');
      } catch (_) {}
      return;
    }

    await db.update('app_settings', {
      key: value,
    }, where: 'id=1');
    await loadSettings();
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

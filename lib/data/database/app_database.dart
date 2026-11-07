import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class AppDatabase {
  AppDatabase._();
  static final AppDatabase instance = AppDatabase._();
  static const schemaVersion = 1;
  Database? _database;
  Future<Database> get database async => _database ??= await _open();
  Future<Database> _open() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    final Directory directory = await getApplicationSupportDirectory();
    final db = await databaseFactory.openDatabase(
      path.join(directory.path, 'type_with_yash.sqlite'),
      options: OpenDatabaseOptions(
        version: schemaVersion,
        onConfigure: (db) async => db.execute('PRAGMA foreign_keys = ON'),
        onCreate: _create,
        onUpgrade: _upgrade,
      ),
    );
    return db;
  }

  Future<void> _create(Database db, int version) async {
    await db.execute(
      'CREATE TABLE passages (id TEXT PRIMARY KEY, title TEXT NOT NULL UNIQUE, category TEXT NOT NULL, difficulty TEXT NOT NULL CHECK(difficulty IN (\'Easy\',\'Medium\',\'Hard\')), content TEXT NOT NULL UNIQUE, word_count INTEGER NOT NULL, character_count INTEGER NOT NULL, estimated_typing_duration INTEGER NOT NULL, language TEXT NOT NULL, source_type TEXT NOT NULL, created_at TEXT NOT NULL, updated_at TEXT NOT NULL, is_custom INTEGER NOT NULL DEFAULT 0 CHECK(is_custom IN (0,1)), version INTEGER NOT NULL)',
    );
    await db.execute(
      'CREATE TABLE test_sessions (id TEXT PRIMARY KEY, passage_id TEXT NOT NULL, passage_title_snapshot TEXT NOT NULL, mode TEXT NOT NULL, configured_duration INTEGER NOT NULL, actual_elapsed_duration INTEGER NOT NULL, character_to_word_ratio INTEGER NOT NULL, started_at TEXT NOT NULL, completed_at TEXT, total_characters_typed INTEGER NOT NULL DEFAULT 0, total_words_typed INTEGER NOT NULL DEFAULT 0, gross_wpm REAL NOT NULL DEFAULT 0, net_wpm REAL NOT NULL DEFAULT 0, accuracy REAL NOT NULL DEFAULT 0, total_errors INTEGER NOT NULL DEFAULT 0, omissions INTEGER NOT NULL DEFAULT 0, substitutions INTEGER NOT NULL DEFAULT 0, insertions INTEGER NOT NULL DEFAULT 0, backspace_count INTEGER NOT NULL DEFAULT 0, completed_repetitions INTEGER NOT NULL DEFAULT 0, is_completed INTEGER NOT NULL DEFAULT 0 CHECK(is_completed IN (0,1)), FOREIGN KEY(passage_id) REFERENCES passages(id) ON DELETE RESTRICT)',
    );
    await db.execute(
      'CREATE TABLE repetitions (id TEXT PRIMARY KEY, session_id TEXT NOT NULL, repetition_number INTEGER NOT NULL, typed_text TEXT NOT NULL, reference_passage_id TEXT NOT NULL, typed_character_count INTEGER NOT NULL DEFAULT 0, correct_characters INTEGER NOT NULL DEFAULT 0, incorrect_characters INTEGER NOT NULL DEFAULT 0, omitted_characters INTEGER NOT NULL DEFAULT 0, extra_characters INTEGER NOT NULL DEFAULT 0, is_complete INTEGER NOT NULL DEFAULT 0 CHECK(is_complete IN (0,1)), started_at TEXT NOT NULL, completed_at TEXT, UNIQUE(session_id,repetition_number), FOREIGN KEY(session_id) REFERENCES test_sessions(id) ON DELETE CASCADE, FOREIGN KEY(reference_passage_id) REFERENCES passages(id) ON DELETE RESTRICT)',
    );
    await db.execute(
      'CREATE TABLE app_settings (id INTEGER PRIMARY KEY CHECK(id=1), onboarding_completed INTEGER NOT NULL DEFAULT 0, default_test_duration INTEGER NOT NULL DEFAULT 10, custom_test_duration INTEGER NOT NULL DEFAULT 10, character_to_word_ratio INTEGER NOT NULL DEFAULT 5, default_test_mode TEXT NOT NULL DEFAULT \'practice\', sound_enabled INTEGER NOT NULL DEFAULT 1, theme_preference TEXT NOT NULL DEFAULT \'light\', auto_loop_enabled INTEGER NOT NULL DEFAULT 0, error_penalty_enabled INTEGER NOT NULL DEFAULT 0, error_threshold_percentage REAL NOT NULL DEFAULT 5, extra_error_deduction_enabled INTEGER NOT NULL DEFAULT 0, extra_error_deduction_value INTEGER NOT NULL DEFAULT 0, scoring_profile TEXT NOT NULL DEFAULT \'custom_practice\')',
    );
    await db.execute(
      'CREATE TABLE app_metadata (key TEXT PRIMARY KEY, value TEXT NOT NULL)',
    );
    await db.execute(
      'CREATE INDEX idx_passages_category ON passages(category)',
    );
    await db.execute(
      'CREATE INDEX idx_passages_difficulty ON passages(difficulty)',
    );
    await db.execute(
      'CREATE INDEX idx_sessions_passage ON test_sessions(passage_id)',
    );
    await db.execute(
      'CREATE INDEX idx_sessions_started ON test_sessions(started_at)',
    );
    await db.execute(
      'CREATE INDEX idx_repetitions_session ON repetitions(session_id)',
    );
    await db.insert('app_settings', {'id': 1});
  }

  Future<void> _upgrade(Database db, int oldVersion, int newVersion) async {
    /* Future migrations are additive and preserve user data. */
  }
  Future<void> close() async {
    await _database?.close();
    _database = null;
  }
}

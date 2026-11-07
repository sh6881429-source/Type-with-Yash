import 'package:flutter/services.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../database/app_database.dart';
import 'passage_library_validator.dart';

class PassageSeeder {
  static const _asset = 'assets/data/passages.json',
      _seedKey = 'bundled_passages_version';
  static Future<void> seedIfNeeded() async {
    final db = await AppDatabase.instance.database;
    final version = (await db.query(
      'app_metadata',
      where: 'key=?',
      whereArgs: [_seedKey],
    )).cast<Map<String, Object?>>();
    if (version.isNotEmpty && version.first['value'] == '1') return;
    final passages = PassageLibraryValidator.decodeAndValidate(
      await rootBundle.loadString(_asset),
    );
    await db.transaction((txn) async {
      for (final passage in passages) {
        await txn.insert(
          'passages',
          passage.toMap(),
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }
      await txn.insert('app_metadata', {
        'key': _seedKey,
        'value': '1',
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    });
  }
}

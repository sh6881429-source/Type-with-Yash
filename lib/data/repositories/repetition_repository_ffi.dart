import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../database/app_database.dart';
import '../models/repetition.dart';

class RepetitionRepository {
  RepetitionRepository({AppDatabase? database})
    : _database = database ?? AppDatabase.instance;
  final AppDatabase _database;

  Future<void> saveRepetition(Repetition r) async {
    await (await _database.database).insert(
      'repetitions',
      r.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Repetition>> getRepetitionsBySession(String id) async =>
      (await (await _database.database).query(
        'repetitions',
        where: 'session_id=?',
        whereArgs: [id],
        orderBy: 'repetition_number',
      )).map(Repetition.fromMap).toList();

  Future<void> deleteRepetitionsBySession(String id) async {
    await (await _database.database).delete(
      'repetitions',
      where: 'session_id=?',
      whereArgs: [id],
    );
  }

  Future<void> deleteAllRepetitions() async {
    await (await _database.database).delete('repetitions');
  }
}

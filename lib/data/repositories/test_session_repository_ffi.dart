import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../database/app_database.dart';
import '../models/test_session.dart';

class TestSessionRepository {
  TestSessionRepository({AppDatabase? database})
    : _database = database ?? AppDatabase.instance;
  final AppDatabase _database;

  Future<void> saveTestSession(TestSession s) async {
    await (await _database.database).insert(
      'test_sessions',
      s.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<TestSession?> getSessionById(String id) async {
    final r = await (await _database.database).query(
      'test_sessions',
      where: 'id=?',
      whereArgs: [id],
    );
    return r.isEmpty ? null : TestSession.fromMap(r.first);
  }

  Future<List<TestSession>> getAllSessions() async =>
      (await (await _database.database).query(
        'test_sessions',
        orderBy: 'started_at DESC',
      )).map(TestSession.fromMap).toList();

  Future<List<TestSession>> getSessionsByPassage(String id) async =>
      (await (await _database.database).query(
        'test_sessions',
        where: 'passage_id=?',
        whereArgs: [id],
        orderBy: 'started_at DESC',
      )).map(TestSession.fromMap).toList();

  Future<List<TestSession>> getSessionsByDateRange(
    DateTime from,
    DateTime to,
  ) async => (await (await _database.database).query(
    'test_sessions',
    where: 'started_at >= ? AND started_at <= ?',
    whereArgs: [from.toIso8601String(), to.toIso8601String()],
    orderBy: 'started_at DESC',
  )).map(TestSession.fromMap).toList();

  Future<void> deleteSession(String id) async {
    await (await _database.database).delete(
      'test_sessions',
      where: 'id=?',
      whereArgs: [id],
    );
  }

  Future<void> deleteAllSessions() async {
    await (await _database.database).delete('test_sessions');
  }
}

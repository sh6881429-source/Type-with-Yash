import 'dart:math';

import '../database/app_database.dart';
import '../models/passage.dart';

class PassageRepository {
  PassageRepository({AppDatabase? database})
    : _database = database ?? AppDatabase.instance;
  final AppDatabase _database;
  Future<List<Passage>> getAllPassages() => _query();
  Future<Passage?> getPassageById(String id) => _one('id=?', [id]);
  Future<List<Passage>> getPassagesByCategory(String value) =>
      _query(where: 'category=?', args: [value]);
  Future<List<Passage>> getPassagesByDifficulty(String value) =>
      _query(where: 'difficulty=?', args: [value]);
  Future<List<Passage>> searchPassages(String query) => _query(
    where: 'title LIKE ? OR content LIKE ?',
    args: ['%$query%', '%$query%'],
  );
  Future<Passage?> getRandomPassage() async {
    final values = await getAllPassages();
    return values.isEmpty ? null : values[Random().nextInt(values.length)];
  }

  Future<int> getPassageCount() async => (await _database.database)
      .rawQuery('SELECT COUNT(*) AS count FROM passages')
      .then((rows) => rows.first['count'] as int);
  Future<void> addCustomPassage(Passage passage) async {
    if (!passage.isCustom)
      throw ArgumentError('Custom passages must set isCustom to true.');
    await (await _database.database).insert('passages', passage.toMap());
  }

  Future<void> updateCustomPassage(Passage passage) async {
    if (!passage.isCustom)
      throw StateError('Bundled passages cannot be modified.');
    final count = await (await _database.database).update(
      'passages',
      passage.toMap(),
      where: 'id=? AND is_custom=1',
      whereArgs: [passage.id],
    );
    if (count != 1) throw StateError('Custom passage not found.');
  }

  Future<void> deleteCustomPassage(String id) async {
    final count = await (await _database.database).delete(
      'passages',
      where: 'id=? AND is_custom=1',
      whereArgs: [id],
    );
    if (count != 1)
      throw StateError('Only an existing custom passage can be deleted.');
  }

  Future<List<Passage>> _query({String? where, List<Object?>? args}) async =>
      (await (await _database.database).query(
        'passages',
        where: where,
        whereArgs: args,
        orderBy: 'title',
      )).map(Passage.fromMap).toList();
  Future<Passage?> _one(String where, List<Object?> args) async {
    final values = await _query(where: where, args: args);
    return values.isEmpty ? null : values.first;
  }
}

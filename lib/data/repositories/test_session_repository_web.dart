import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/test_session.dart';

/// Browser-compatible test session storage using SharedPreferences (localStorage).
/// Persists across browser refreshes and restarts without SQLite.
class TestSessionRepository {
  static const _storageKey = 'type_with_yash_test_sessions';

  Future<List<TestSession>> _loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_storageKey);
    if (jsonStr == null || jsonStr.isEmpty) return [];

    try {
      final list = jsonDecode(jsonStr) as List;
      return list
          .map((item) => TestSession.fromMap(Map<String, Object?>.from(item as Map)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveAll(List<TestSession> sessions) async {
    final prefs = await SharedPreferences.getInstance();
    final list = sessions.map((s) => s.toMap()).toList();
    await prefs.setString(_storageKey, jsonEncode(list));
  }

  Future<void> saveTestSession(TestSession s) async {
    final all = await _loadAll();
    final index = all.indexWhere((item) => item.id == s.id);
    if (index >= 0) {
      all[index] = s;
    } else {
      all.insert(0, s);
    }
    await _saveAll(all);
  }

  Future<TestSession?> getSessionById(String id) async {
    final all = await _loadAll();
    return all.where((item) => item.id == id).firstOrNull;
  }

  Future<List<TestSession>> getAllSessions() async {
    final all = await _loadAll();
    all.sort((a, b) => b.startedAt.compareTo(a.startedAt));
    return all;
  }

  Future<List<TestSession>> getSessionsByPassage(String id) async {
    final all = await getAllSessions();
    return all.where((item) => item.passageId == id).toList();
  }

  Future<List<TestSession>> getSessionsByDateRange(
    DateTime from,
    DateTime to,
  ) async {
    final all = await getAllSessions();
    return all
        .where(
          (item) =>
              item.startedAt.isAfter(from.subtract(const Duration(seconds: 1))) &&
              item.startedAt.isBefore(to.add(const Duration(seconds: 1))),
        )
        .toList();
  }

  Future<void> deleteSession(String id) async {
    final all = await _loadAll();
    all.removeWhere((item) => item.id == id);
    await _saveAll(all);
  }

  Future<void> deleteAllSessions() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

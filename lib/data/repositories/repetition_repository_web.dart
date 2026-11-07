import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/repetition.dart';

/// Browser-compatible repetition storage using SharedPreferences (localStorage).
/// Persists across browser refreshes and restarts without SQLite.
class RepetitionRepository {
  static const _storageKey = 'type_with_yash_repetitions';

  Future<List<Repetition>> _loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_storageKey);
    if (jsonStr == null || jsonStr.isEmpty) return [];

    try {
      final list = jsonDecode(jsonStr) as List;
      return list
          .map((item) => Repetition.fromMap(Map<String, Object?>.from(item as Map)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveAll(List<Repetition> repetitions) async {
    final prefs = await SharedPreferences.getInstance();
    final list = repetitions.map((r) => r.toMap()).toList();
    await prefs.setString(_storageKey, jsonEncode(list));
  }

  Future<void> saveRepetition(Repetition r) async {
    final all = await _loadAll();
    final index = all.indexWhere(
      (item) => item.sessionId == r.sessionId && item.repetitionNumber == r.repetitionNumber,
    );
    if (index >= 0) {
      all[index] = r;
    } else {
      all.add(r);
    }
    await _saveAll(all);
  }

  Future<List<Repetition>> getRepetitionsBySession(String id) async {
    final all = await _loadAll();
    final filtered = all.where((item) => item.sessionId == id).toList();
    filtered.sort((a, b) => a.repetitionNumber.compareTo(b.repetitionNumber));
    return filtered;
  }

  Future<void> deleteRepetitionsBySession(String id) async {
    final all = await _loadAll();
    all.removeWhere((item) => item.sessionId == id);
    await _saveAll(all);
  }

  Future<void> deleteAllRepetitions() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }
}

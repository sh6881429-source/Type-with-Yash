import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/passage.dart';

class PassageRepository {
  static const _customPassagesKey = 'type_with_yash_custom_passages';
  static List<Passage>? _bundledCached;

  Future<List<Passage>> _getBundled() async {
    return _bundledCached ??=
        (jsonDecode(await rootBundle.loadString('assets/data/passages.json'))
                as List)
            .map(
              (value) => Passage.fromMap(Map<String, Object?>.from(value as Map)),
            )
            .toList();
  }

  Future<List<Passage>> _getCustom() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_customPassagesKey);
    if (jsonStr == null || jsonStr.isEmpty) return [];
    try {
      final list = jsonDecode(jsonStr) as List;
      return list
          .map((value) => Passage.fromMap(Map<String, Object?>.from(value as Map)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveCustom(List<Passage> custom) async {
    final prefs = await SharedPreferences.getInstance();
    final list = custom.map((p) => p.toMap()).toList();
    await prefs.setString(_customPassagesKey, jsonEncode(list));
  }

  Future<List<Passage>> getAllPassages() async {
    final bundled = await _getBundled();
    final custom = await _getCustom();
    return [...bundled, ...custom];
  }

  Future<Passage?> getPassageById(String id) async {
    final values = await getAllPassages();
    return values.where((p) => p.id == id).firstOrNull;
  }

  Future<List<Passage>> getPassagesByCategory(String value) async =>
      (await getAllPassages()).where((p) => p.category == value).toList();

  Future<List<Passage>> getPassagesByDifficulty(String value) async =>
      (await getAllPassages()).where((p) => p.difficulty == value).toList();

  Future<List<Passage>> searchPassages(String query) async {
    final q = query.trim().toLowerCase();
    return (await getAllPassages())
        .where(
          (p) =>
              q.isEmpty ||
              p.title.toLowerCase().contains(q) ||
              p.category.toLowerCase().contains(q) ||
              p.content.toLowerCase().contains(q),
        )
        .toList();
  }

  Future<Passage?> getRandomPassage() async {
    final values = await getAllPassages();
    return values.isEmpty ? null : values[Random().nextInt(values.length)];
  }

  Future<int> getPassageCount() async => (await getAllPassages()).length;

  Future<void> addCustomPassage(Passage passage) async {
    if (!passage.isCustom) {
      throw ArgumentError('Custom passages must set isCustom to true.');
    }
    final custom = await _getCustom();
    custom.add(passage);
    await _saveCustom(custom);
  }

  Future<void> updateCustomPassage(Passage passage) async {
    if (!passage.isCustom) {
      throw StateError('Bundled passages cannot be modified.');
    }
    final custom = await _getCustom();
    final idx = custom.indexWhere((p) => p.id == passage.id && p.isCustom);
    if (idx < 0) throw StateError('Custom passage not found.');
    custom[idx] = passage;
    await _saveCustom(custom);
  }

  Future<void> deleteCustomPassage(String id) async {
    final custom = await _getCustom();
    final beforeCount = custom.length;
    custom.removeWhere((p) => p.id == id && p.isCustom);
    if (custom.length == beforeCount) {
      throw StateError('Only an existing custom passage can be deleted.');
    }
    await _saveCustom(custom);
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

import 'dart:convert';

import '../models/passage.dart';

class PassageLibraryValidator {
  static const categories = {
    'Indian History',
    'Indian Geography',
    'Indian Polity',
    'Indian Economy',
    'Science and Technology',
    'Environment and Biodiversity',
    'Education',
    'Social Development',
    'General Awareness',
    'Technology and Digital India',
    'Ethics, Discipline, and National Development',
  };
  static const difficulties = {'Easy', 'Medium', 'Hard'};
  static List<Passage> decodeAndValidate(String source) {
    final raw = jsonDecode(source) as List<dynamic>;
    final passages = raw
        .map((e) => Passage.fromMap(Map<String, Object?>.from(e as Map)))
        .toList();
    if (passages.length != 100)
      throw const FormatException(
        'The bundled library must contain exactly 100 passages.',
      );
    final ids = <String>{}, titles = <String>{}, contents = <String>{};
    for (final p in passages) {
      final words = _wordCount(p.content);
      if (!ids.add(p.id) || !titles.add(p.title) || !contents.add(p.content))
        throw const FormatException(
          'Passage IDs, titles, and content must be unique.',
        );
      if (p.content.trim().isEmpty ||
          words < 900 ||
          words > 1100 ||
          p.wordCount != words ||
          p.characterCount != p.content.length)
        throw FormatException('Invalid counts for ${p.id}.');
      if (!difficulties.contains(p.difficulty) ||
          !categories.contains(p.category))
        throw FormatException('Invalid category or difficulty for ${p.id}.');
    }
    for (var i = 0; i < passages.length; i++)
      for (var j = i + 1; j < passages.length; j++) {
        // This catches near-identical libraries while permitting ordinary
        // formal-English connective language to recur naturally.
        if (_similarity(passages[i].content, passages[j].content) > .80)
          throw FormatException(
            'Passages ${passages[i].id} and ${passages[j].id} are too similar.',
          );
      }
    return passages;
  }

  static int _wordCount(String value) =>
      RegExp(r"[A-Za-z0-9]+(?:['’-][A-Za-z0-9]+)?").allMatches(value).length;
  static double _similarity(String a, String b) {
    final x = _shingles(a), y = _shingles(b);
    final union = x.union(y).length;
    return union == 0 ? 0 : x.intersection(y).length / union;
  }

  static Set<String> _shingles(String value) {
    final w = RegExp('[A-Za-z]+')
        .allMatches(value.toLowerCase())
        .map((e) => e.group(0)!)
        .toList();
    return {
      for (var i = 0; i + 4 <= w.length; i++) w.sublist(i, i + 4).join(' '),
    };
  }
}

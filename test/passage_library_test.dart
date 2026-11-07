import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:type_with_yash/data/services/passage_library_validator.dart';

void main() {
  test(
    'bundled passage library is complete, valid, and non-duplicated',
    () async {
      final source = await File('assets/data/passages.json').readAsString();
      final passages = PassageLibraryValidator.decodeAndValidate(source);
      expect(passages, hasLength(100));
      expect(passages.map((p) => p.id).toSet(), hasLength(100));
      expect(passages.map((p) => p.title).toSet(), hasLength(100));
      for (final passage in passages) {
        expect(passage.wordCount, inInclusiveRange(900, 1100));
        expect(passage.characterCount, passage.content.length);
      }
    },
  );
}

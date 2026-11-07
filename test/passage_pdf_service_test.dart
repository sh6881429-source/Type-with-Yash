import 'package:flutter_test/flutter_test.dart';
import 'package:type_with_yash/data/models/passage.dart';
import 'package:type_with_yash/data/services/passage_pdf_service.dart';

void main() {
  test('creates a valid multi-page A4 PDF for a complete passage', () async {
    final text = List.filled(
      120,
      'This is a complete printable passage paragraph with ordinary punctuation, numbers such as 12, and enough words to span more than one A4 page.',
    ).join('\n\n');
    final passage = Passage(
      id: 'pdf-test-001',
      title: 'PDF Test Passage',
      category: 'Education',
      difficulty: 'Medium',
      content: text,
      wordCount: 1920,
      characterCount: text.length,
      estimatedTypingDuration: 10,
      language: 'English',
      sourceType: 'test',
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
      isCustom: false,
      version: 1,
    );
    final bytes = await PassagePdfService.build(passage);
    expect(bytes.length, greaterThan(1000));
    expect(String.fromCharCodes(bytes.take(4)), equals('%PDF'));
  });
}

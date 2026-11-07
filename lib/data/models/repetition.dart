class Repetition {
  const Repetition({
    required this.id,
    required this.sessionId,
    required this.repetitionNumber,
    required this.typedText,
    required this.referencePassageId,
    required this.typedCharacterCount,
    required this.correctCharacters,
    required this.incorrectCharacters,
    required this.omittedCharacters,
    required this.extraCharacters,
    required this.isComplete,
    required this.startedAt,
    this.completedAt,
  });
  final String id, sessionId, typedText, referencePassageId;
  final int repetitionNumber,
      typedCharacterCount,
      correctCharacters,
      incorrectCharacters,
      omittedCharacters,
      extraCharacters;
  final bool isComplete;
  final DateTime startedAt;
  final DateTime? completedAt;
  factory Repetition.fromMap(Map<String, Object?> m) => Repetition(
    id: m['id'] as String,
    sessionId: m['session_id'] as String,
    repetitionNumber: m['repetition_number'] as int,
    typedText: m['typed_text'] as String,
    referencePassageId: m['reference_passage_id'] as String,
    typedCharacterCount: m['typed_character_count'] as int,
    correctCharacters: m['correct_characters'] as int,
    incorrectCharacters: m['incorrect_characters'] as int,
    omittedCharacters: m['omitted_characters'] as int,
    extraCharacters: m['extra_characters'] as int,
    isComplete: (m['is_complete'] as int) == 1,
    startedAt: DateTime.parse(m['started_at'] as String),
    completedAt: m['completed_at'] == null
        ? null
        : DateTime.parse(m['completed_at'] as String),
  );
  Map<String, Object?> toMap() => {
    'id': id,
    'session_id': sessionId,
    'repetition_number': repetitionNumber,
    'typed_text': typedText,
    'reference_passage_id': referencePassageId,
    'typed_character_count': typedCharacterCount,
    'correct_characters': correctCharacters,
    'incorrect_characters': incorrectCharacters,
    'omitted_characters': omittedCharacters,
    'extra_characters': extraCharacters,
    'is_complete': isComplete ? 1 : 0,
    'started_at': startedAt.toIso8601String(),
    'completed_at': completedAt?.toIso8601String(),
  };
}

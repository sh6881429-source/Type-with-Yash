class Passage {
  const Passage({
    required this.id,
    required this.title,
    required this.category,
    required this.difficulty,
    required this.content,
    required this.wordCount,
    required this.characterCount,
    required this.estimatedTypingDuration,
    required this.language,
    required this.sourceType,
    required this.createdAt,
    required this.updatedAt,
    required this.isCustom,
    required this.version,
  });

  final String id, title, category, difficulty, content, language, sourceType;
  final int wordCount, characterCount, estimatedTypingDuration, version;
  final DateTime createdAt, updatedAt;
  final bool isCustom;

  factory Passage.fromMap(Map<String, Object?> map) => Passage(
    id: map['id']! as String,
    title: map['title']! as String,
    category: map['category']! as String,
    difficulty: map['difficulty']! as String,
    content: map['content']! as String,
    wordCount: map['word_count']! as int,
    characterCount: map['character_count']! as int,
    estimatedTypingDuration: map['estimated_typing_duration']! as int,
    language: map['language']! as String,
    sourceType: map['source_type']! as String,
    createdAt: DateTime.parse(map['created_at']! as String),
    updatedAt: DateTime.parse(map['updated_at']! as String),
    isCustom: (map['is_custom']! as int) == 1,
    version: map['version']! as int,
  );

  Map<String, Object?> toMap() => {
    'id': id,
    'title': title,
    'category': category,
    'difficulty': difficulty,
    'content': content,
    'word_count': wordCount,
    'character_count': characterCount,
    'estimated_typing_duration': estimatedTypingDuration,
    'language': language,
    'source_type': sourceType,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
    'is_custom': isCustom ? 1 : 0,
    'version': version,
  };

  Passage copyWith({
    String? title,
    String? category,
    String? difficulty,
    String? content,
    int? wordCount,
    int? characterCount,
    int? estimatedTypingDuration,
    DateTime? updatedAt,
  }) => Passage(
    id: id,
    title: title ?? this.title,
    category: category ?? this.category,
    difficulty: difficulty ?? this.difficulty,
    content: content ?? this.content,
    wordCount: wordCount ?? this.wordCount,
    characterCount: characterCount ?? this.characterCount,
    estimatedTypingDuration:
        estimatedTypingDuration ?? this.estimatedTypingDuration,
    language: language,
    sourceType: sourceType,
    createdAt: createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    isCustom: isCustom,
    version: version,
  );
}

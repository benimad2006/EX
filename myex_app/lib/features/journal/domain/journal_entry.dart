/// Journal entry kinds. "letter" is a letter you won't send (never leaves the
/// app, unlike Draft Jail which is about a text you might send).
enum JournalKind {
  reflection,
  letter,
  gratitude,
  list;

  static JournalKind parse(String? s) =>
      values.where((k) => k.name == s).firstOrNull ?? reflection;
}

class JournalEntry {
  const JournalEntry({
    required this.id,
    required this.kind,
    required this.body,
    required this.createdAt,
    required this.updatedAt,
    this.prompt,
    this.moodLevel,
  });

  final String id;
  final JournalKind kind;

  /// The guided prompt the entry answered, if any (stored as shown).
  final String? prompt;
  final String body;
  final int? moodLevel;
  final DateTime createdAt;
  final DateTime updatedAt;

  JournalEntry copyWith({
    JournalKind? kind,
    String? prompt,
    String? body,
    int? moodLevel,
    DateTime? updatedAt,
  }) => JournalEntry(
    id: id,
    kind: kind ?? this.kind,
    prompt: prompt ?? this.prompt,
    body: body ?? this.body,
    moodLevel: moodLevel ?? this.moodLevel,
    createdAt: createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  /// First line, for list rows.
  String get headline {
    final t = body.trim();
    final nl = t.indexOf('\n');
    return nl == -1 ? t : t.substring(0, nl);
  }

  factory JournalEntry.fromRow(Map<String, dynamic> r) => JournalEntry(
    id: r['id'] as String,
    kind: JournalKind.parse(r['kind'] as String?),
    prompt: r['prompt'] as String?,
    body: r['body'] as String? ?? '',
    moodLevel: (r['mood_level'] as num?)?.toInt(),
    createdAt: DateTime.parse(r['created_at'] as String).toLocal(),
    updatedAt: DateTime.parse(
      (r['updated_at'] ?? r['created_at']) as String,
    ).toLocal(),
  );
}

/// Case-insensitive search over body and prompt, optionally by kind.
List<JournalEntry> filterJournal(
  List<JournalEntry> all, {
  String query = '',
  JournalKind? kind,
}) {
  final q = query.trim().toLowerCase();
  return [
    for (final e in all)
      if ((kind == null || e.kind == kind) &&
          (q.isEmpty ||
              e.body.toLowerCase().contains(q) ||
              (e.prompt?.toLowerCase().contains(q) ?? false)))
        e,
  ];
}

/// Mood check-in (docs/design: words over faces). Level 1 = heaviest,
/// 5 = lightest. Feelings are fixed keys, localized in the UI.
enum MoodWord {
  heartbroken,
  lonely,
  angry,
  anxious,
  numb,
  confused,
  tired,
  hopeful,
  calm,
  relieved,
  proud,
  grateful;

  static MoodWord? parse(String? s) =>
      values.where((f) => f.name == s).firstOrNull;
}

class MoodEntry {
  const MoodEntry({
    required this.id,
    required this.level,
    required this.feelings,
    required this.createdAt,
    this.note,
  }) : assert(level >= 1 && level <= 5);

  final String id;
  final int level;
  final List<MoodWord> feelings;
  final String? note;
  final DateTime createdAt;

  factory MoodEntry.fromRow(Map<String, dynamic> r) => MoodEntry(
    id: r['id'] as String,
    level: (r['level'] as num).toInt(),
    feelings: [
      for (final f in (r['feelings'] as List? ?? const []))
        ?MoodWord.parse(f as String?),
    ],
    note: r['note'] as String?,
    createdAt: DateTime.parse(r['created_at'] as String).toLocal(),
  );
}

/// Local calendar day key (yyyy-mm-dd) for grouping.
DateTime dayOf(DateTime t) => DateTime(t.year, t.month, t.day);

/// Average mood per day for the last [days] days ending today, oldest first.
/// Days without a check-in are null (the chart leaves a gap, never a zero).
List<double?> dailyMoodAverages(
  List<MoodEntry> entries,
  DateTime now, {
  int days = 14,
}) {
  final today = dayOf(now);
  final sums = <DateTime, (int, int)>{};
  for (final e in entries) {
    final d = dayOf(e.createdAt);
    final (s, n) = sums[d] ?? (0, 0);
    sums[d] = (s + e.level, n + 1);
  }
  return [
    for (var i = days - 1; i >= 0; i--)
      switch (sums[today.subtract(Duration(days: i))]) {
        (final s, final n) => s / n,
        null => null,
      },
  ];
}

/// The latest check-in made today, if any.
MoodEntry? todaysMood(List<MoodEntry> entries, DateTime now) {
  final today = dayOf(now);
  MoodEntry? best;
  for (final e in entries) {
    if (dayOf(e.createdAt) != today) continue;
    if (best == null || e.createdAt.isAfter(best.createdAt)) best = e;
  }
  return best;
}

/// Most frequent feelings (top [n]) across [entries].
List<MoodWord> mostFrequentFeelings(List<MoodEntry> entries, {int n = 3}) {
  final c = <MoodWord, int>{};
  for (final e in entries) {
    for (final f in e.feelings) {
      c[f] = (c[f] ?? 0) + 1;
    }
  }
  final sorted = c.entries.toList()
    ..sort((a, b) {
      final byCount = b.value.compareTo(a.value);
      return byCount != 0 ? byCount : a.key.index.compareTo(b.key.index);
    });
  return [for (final e in sorted.take(n)) e.key];
}

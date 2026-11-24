import '../../../l10n/app_localizations.dart';
import '../domain/journal_entry.dart';
import '../domain/mood.dart';

/// Localized words for mood levels, feelings, journal kinds and prompts.
extension JournalLabels on AppLocalizations {
  List<String> get moodWords => [
    moodLevel1,
    moodLevel2,
    moodLevel3,
    moodLevel4,
    moodLevel5,
  ];

  String moodWord(int level) => moodWords[(level - 1).clamp(0, 4)];

  String feeling(MoodWord f) => switch (f) {
    MoodWord.heartbroken => moodWordHeartbroken,
    MoodWord.lonely => moodWordLonely,
    MoodWord.angry => moodWordAngry,
    MoodWord.anxious => moodWordAnxious,
    MoodWord.numb => moodWordNumb,
    MoodWord.confused => moodWordConfused,
    MoodWord.tired => moodWordTired,
    MoodWord.hopeful => moodWordHopeful,
    MoodWord.calm => moodWordCalm,
    MoodWord.relieved => moodWordRelieved,
    MoodWord.proud => moodWordProud,
    MoodWord.grateful => moodWordGrateful,
  };

  String journalKind(JournalKind k) => switch (k) {
    JournalKind.reflection => journalKindReflection,
    JournalKind.letter => journalKindLetter,
    JournalKind.gratitude => journalKindGratitude,
    JournalKind.list => journalKindList,
  };

  List<String> prompts(JournalKind k) => switch (k) {
    JournalKind.reflection => [
      journalPromptReflection1,
      journalPromptReflection2,
      journalPromptReflection3,
      journalPromptReflection4,
    ],
    JournalKind.letter => [
      journalPromptLetter1,
      journalPromptLetter2,
      journalPromptLetter3,
    ],
    JournalKind.gratitude => [
      journalPromptGratitude1,
      journalPromptGratitude2,
      journalPromptGratitude3,
    ],
    JournalKind.list => [
      journalPromptList1,
      journalPromptList2,
      journalPromptList3,
    ],
  };

  /// One prompt per calendar day, rotating through every kind.
  (JournalKind, String) promptOfTheDay(DateTime now) {
    final all = [
      for (final k in JournalKind.values)
        for (final p in prompts(k)) (k, p),
    ];
    final dayIndex = DateTime(
      now.year,
      now.month,
      now.day,
    ).difference(DateTime(2026)).inDays;
    return all[dayIndex % all.length];
  }
}

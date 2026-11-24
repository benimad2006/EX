import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myex_app/core/design/theme_mode.dart';
import 'package:myex_app/core/design/tokens.dart';
import 'package:myex_app/demo/demo_repositories.dart';
import 'package:myex_app/demo/demo_store.dart';
import 'package:myex_app/features/insights/domain/week_summary.dart';
import 'package:myex_app/features/journal/domain/journal_entry.dart';
import 'package:myex_app/features/journal/domain/mood.dart';
import 'package:myex_app/features/no_contact/domain/no_contact.dart';

void main() {
  final now = DateTime(2026, 11, 24, 20);
  DateTime ago(int d, [int h = 21]) =>
      DateTime(2026, 11, 24, h).subtract(Duration(days: d));
  MoodEntry mood(int level, DateTime at, [List<MoodWord> f = const []]) =>
      MoodEntry(id: '$at$level', level: level, feelings: f, createdAt: at);

  group('appearance', () {
    test('system follows the device; explicit modes win', () {
      expect(
        paletteFor(AppearanceMode.system, Brightness.dark),
        MyExPalette.night,
      );
      expect(
        paletteFor(AppearanceMode.system, Brightness.light),
        MyExPalette.light,
      );
      expect(
        paletteFor(AppearanceMode.light, Brightness.dark),
        MyExPalette.light,
      );
      expect(
        paletteFor(AppearanceMode.dark, Brightness.light),
        MyExPalette.night,
      );
    });

    test('both palettes define all five mood steps', () {
      expect(MyExPalette.light.mood, hasLength(5));
      expect(MyExPalette.night.mood, hasLength(5));
    });
  });

  group('mood', () {
    test('daily averages: oldest first, gaps stay null (never zero)', () {
      final avg = dailyMoodAverages(
        [mood(2, ago(0, 9)), mood(4, ago(0)), mood(1, ago(2))],
        now,
        days: 4,
      );
      expect(avg, [null, 1.0, null, 3.0]);
    });

    test('today = the latest check-in today', () {
      final t = todaysMood([
        mood(2, ago(0, 9)),
        mood(5, ago(0, 18)),
        mood(1, ago(1)),
      ], now);
      expect(t?.level, 5);
      expect(todaysMood([mood(3, ago(1))], now), isNull);
    });

    test('most frequent feelings, ties by declaration order', () {
      final top = mostFrequentFeelings([
        mood(2, ago(0), [MoodWord.lonely, MoodWord.tired]),
        mood(2, ago(1), [MoodWord.lonely, MoodWord.calm]),
        mood(3, ago(2), [MoodWord.calm]),
      ]);
      expect(top, [MoodWord.lonely, MoodWord.calm, MoodWord.tired]);
    });

    test('week trend compares this week with the one before', () {
      final lighter = WeekSummary.of([
        mood(4, ago(1)),
        mood(4, ago(2)),
        mood(2, ago(8)),
        mood(2, ago(9)),
      ], now);
      expect(lighter.trend, WeekTrend.lighter);
      expect(lighter.checkIns, 2);
      expect(
        WeekSummary.of([mood(2, ago(1)), mood(4, ago(8))], now).trend,
        WeekTrend.heavier,
      );
      expect(
        WeekSummary.of([mood(3, ago(1)), mood(3, ago(8))], now).trend,
        WeekTrend.steady,
      );
      expect(WeekSummary.of([mood(3, ago(1))], now).trend, WeekTrend.unknown);
    });
  });

  group('journal', () {
    JournalEntry e(String id, JournalKind k, String body, {String? prompt}) =>
        JournalEntry(
          id: id,
          kind: k,
          body: body,
          prompt: prompt,
          createdAt: now,
          updatedAt: now,
        );
    final all = [
      e('1', JournalKind.letter, 'Dear you,\nI am fine.'),
      e('2', JournalKind.list, 'Things', prompt: 'Three things you won’t miss'),
      e('3', JournalKind.reflection, 'Dinner was hard'),
    ];

    test('search is case-insensitive over body and prompt', () {
      expect(filterJournal(all, query: 'DINNER').map((x) => x.id), ['3']);
      expect(filterJournal(all, query: 'miss').map((x) => x.id), ['2']);
    });

    test('kind filter combines with search', () {
      expect(filterJournal(all, kind: JournalKind.letter).single.id, '1');
      expect(
        filterJournal(all, kind: JournalKind.letter, query: 'dinner'),
        isEmpty,
      );
    });

    test('headline is the first line', () {
      expect(all.first.headline, 'Dear you,');
    });
  });

  group('no contact', () {
    final s = NoContactState(
      attempts: [
        NoContactAttempt(id: 'b', startedOn: ago(9), goalDays: 30),
        NoContactAttempt(
          id: 'a',
          startedOn: ago(16),
          endedOn: ago(10),
          goalDays: 30,
        ),
      ],
    );

    test('days you chose yourself never reset across runs', () {
      expect(s.currentDays(now), 9);
      expect(s.chosenDays(now), 9 + 6);
      expect(s.bestRun(now), 9);
      expect(s.past.single.id, 'a');
    });

    test('next target: the next milestone before the goal, then the goal', () {
      expect(s.nextTarget(now), 14);
      final atGoal = NoContactState(
        attempts: [NoContactAttempt(id: 'x', startedOn: ago(7), goalDays: 7)],
      );
      expect(atGoal.currentDays(now), 7);
      expect(atGoal.nextTarget(now), 14); // goal reached: keep going
      expect(s.reachedMilestones(now), [1, 3, 7]);
    });

    test(
      'demo "I reached out" keeps the old run and starts a new one',
      () async {
        final store = DemoStore();
        final repo = DemoNoContactRepository(store);
        await repo.start(goalDays: 60);
        await repo.reachedOut(reflection: '  It was their birthday.  ');
        final st = await repo.load();
        expect(st.attempts, hasLength(2));
        expect(st.current?.goalDays, 60);
        expect(st.past.single.reflection, 'It was their birthday.');
      },
    );
  });

  group('journal views', () {
    test('words per day: oldest first, today last', () {
      JournalEntry e(String body, DateTime at) => JournalEntry(
        id: body,
        kind: JournalKind.reflection,
        body: body,
        createdAt: at,
        updatedAt: at,
      );
      final w = wordsPerDay(
        [
          e('one two three', ago(0)),
          e('four five', ago(0, 9)),
          e('six', ago(2)),
          e('too old to count', ago(9)),
        ],
        now,
        days: 3,
      );
      expect(w, [1, 0, 5]);
      expect(wordCount('  '), 0);
    });

    test('mood by day averages each calendar day', () {
      final m = moodByDay([mood(2, ago(1, 9)), mood(4, ago(1, 22))]);
      expect(m[DateTime(2026, 11, 23)], 3.0);
    });

    test('feeling counts within the period, most first', () {
      final c = feelingCounts(
        [
          mood(2, ago(0), [MoodWord.lonely, MoodWord.calm]),
          mood(3, ago(3), [MoodWord.calm]),
          mood(1, ago(20), [MoodWord.angry]),
        ],
        now,
      );
      expect(c, [(MoodWord.calm, 2), (MoodWord.lonely, 1)]);
    });
  });
}

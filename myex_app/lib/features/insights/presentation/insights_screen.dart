import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/design/design.dart';
import '../../../core/router/app_router.dart';
import '../../../core/util/context_x.dart';
import '../../journal/data/journal_repository.dart';
import '../../journal/domain/journal_entry.dart';
import '../../journal/domain/mood.dart';
import '../../journal/presentation/journal_labels.dart';
import '../../journal/presentation/mood_checkin_sheet.dart';
import '../../no_contact/data/no_contact_repository.dart';
import '../../plan/application/plan_progress.dart';
import '../domain/week_summary.dart';

/// Insights: 14-day mood line, a calm week summary, and counts. Recovery is
/// framed as non-linear; nothing here says "behind" or "failed".
class InsightsScreen extends ConsumerStatefulWidget {
  const InsightsScreen({super.key});

  @override
  ConsumerState<InsightsScreen> createState() => _InsightsScreenState();

  static String _weekLine(BuildContext context, WeekSummary w) {
    final l = context.l10n;
    return [
      l.insightsWeekCheckins(w.checkIns),
      switch (w.trend) {
        WeekTrend.lighter => l.insightsWeekUp,
        WeekTrend.heavier => l.insightsWeekDown,
        WeekTrend.steady => l.insightsWeekSame,
        WeekTrend.unknown => null,
      },
    ].whereType<String>().join(' ');
  }
}

enum _Period { week, month }

class _InsightsScreenState extends ConsumerState<InsightsScreen> {
  _Period _period = _Period.week;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final now = DateTime.now();
    final moods = ref.watch(moodEntriesProvider).value;
    final journal = ref.watch(journalEntriesProvider).value ?? const [];
    final nc = ref.watch(noContactProvider).value;
    final plan = ref.watch(planStateProvider).value;
    final days = _period == _Period.week ? 7 : 30;
    final fmt = DateFormat.MMMd(context.localeName);
    final dayLetter = DateFormat('EEEEE', context.localeName);
    final words = wordsPerDay(journal, now, days: days);
    final totalWords = words.fold<int>(0, (a, b) => a + b);
    final felt = moods == null
        ? const <(MoodWord, int)>[]
        : feelingCounts(moods, now, days: days).take(5).toList();

    return Scaffold(
      body: ScreenBackground(
        child: LargeTitleScrollView(
          title: l.insightsTitle,
          bottomPadding: MyExSpacing.s8 + MediaQuery.paddingOf(context).bottom,
          leading: GlassIconButton(
            icon: MyExIcons.back,
            semanticLabel: l.commonBack,
            onPressed: () =>
                context.canPop() ? context.pop() : context.go(Routes.home),
          ),
          onRefresh: () async => ref
            ..invalidate(moodEntriesProvider)
            ..invalidate(journalEntriesProvider)
            ..invalidate(noContactProvider),
          children: [
            PillTabs<_Period>(
              value: _period,
              tabs: {
                _Period.week: l.insightsPeriodWeek,
                _Period.month: l.insightsPeriodMonth,
              },
              onChanged: (p) => setState(() => _period = p),
            ),
            if (moods == null)
              const SkeletonBox(height: 240)
            else if (moods.isEmpty)
              EmptyState(
                title: l.insightsEmptyTitle,
                body: l.insightsEmptyBody,
                actionLabel: l.insightsCheckInNow,
                onAction: () => showMoodCheckIn(context),
              )
            else ...[
              _WeekCard(summary: WeekSummary.of(moods, now)),
              SolidCard(
                padding: const EdgeInsets.all(MyExSpacing.s5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _period == _Period.week
                          ? l.insightsMoodWeek
                          : l.insightsMoodMonth,
                      style: MyExType.headline,
                    ),
                    const Gap(MyExSpacing.s4),
                    MoodLineChart(
                      key: ValueKey(_period),
                      values: dailyMoodAverages(moods, now, days: days),
                      semanticLabel: l.insightsChartSemantics(
                        InsightsScreen._weekLine(
                          context,
                          WeekSummary.of(moods, now),
                        ),
                      ),
                      xLabels: [
                        fmt.format(now.subtract(Duration(days: days - 1))),
                        fmt.format(now.subtract(Duration(days: days ~/ 2))),
                        fmt.format(now),
                      ],
                    ),
                    const Gap(MyExSpacing.s4),
                    Text(l.insightsNonLinear, style: MyExType.footnote),
                  ],
                ),
              ),
            ],
            SolidCard(
              key: const Key('insights-words'),
              padding: const EdgeInsets.all(MyExSpacing.s5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Expanded(
                        child: Text(l.insightsWords, style: MyExType.headline),
                      ),
                      Text(
                        l.insightsWordsTotal(totalWords),
                        style: MyExType.footnote,
                      ),
                    ],
                  ),
                  const Gap(MyExSpacing.s4),
                  TrackBars(
                    key: ValueKey('bars-$_period'),
                    values: words,
                    labels: _period == _Period.week
                        ? [
                            for (var i = 6; i >= 0; i--)
                              dayLetter.format(now.subtract(Duration(days: i))),
                          ]
                        : const [],
                    semanticLabel:
                        '${l.insightsWords}: ${l.insightsWordsTotal(totalWords)}',
                  ),
                ],
              ),
            ),
            SolidCard(
              key: const Key('insights-feelings'),
              padding: const EdgeInsets.all(MyExSpacing.s5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.insightsFeelingsTitle, style: MyExType.headline),
                  const Gap(MyExSpacing.s3),
                  if (felt.isEmpty)
                    Text(l.insightsFeelingsEmpty, style: MyExType.subheadline)
                  else
                    FeelingBars(
                      items: [
                        for (final (f, n) in felt)
                          (l.feeling(f), n, feelingTint(f)),
                      ],
                    ),
                ],
              ),
            ),
            StatPair(
              left: StatTile(
                value: '${moods?.length ?? 0}',
                label: l.insightsCheckins,
                onTap: () => showMoodCheckIn(context),
              ),
              right: StatTile(
                value: '${journal.length}',
                label: l.insightsEntries,
                onTap: () => context.go(Routes.journal),
              ),
            ),
            StatPair(
              left: StatTile(
                value: '${plan?.doneCount ?? 0}',
                label: l.insightsPlanDays,
                onTap: () => context.go(Routes.plan),
              ),
              right: StatTile(
                value: '${nc?.chosenDays(now) ?? 0}',
                label: l.noContactChosen,
                onTap: () => context.push(Routes.noContact),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeekCard extends StatelessWidget {
  const _WeekCard({required this.summary});
  final WeekSummary summary;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final feelings = summary.topFeelings.map(l.feeling).join(', ');
    return SolidCard(
      padding: const EdgeInsets.all(MyExSpacing.s5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const MiraOrb(size: MyExSizes.miraInline),
              const Gap(MyExSpacing.s2),
              Text(l.insightsWeek, style: MyExType.headline),
            ],
          ),
          const Gap(MyExSpacing.s3),
          Text(
            InsightsScreen._weekLine(context, summary),
            style: MyExType.body,
          ),
          if (feelings.isNotEmpty) ...[
            const Gap(MyExSpacing.s2),
            Text(l.insightsWeekFeelings(feelings), style: MyExType.subheadline),
          ],
        ],
      ),
    );
  }
}

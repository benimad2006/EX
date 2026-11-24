import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/design/design.dart';
import '../../../core/router/app_router.dart';
import '../../../core/util/context_x.dart';
import '../../journal/data/journal_repository.dart';
import '../../journal/domain/mood.dart';
import '../../journal/presentation/journal_labels.dart';
import '../../journal/presentation/mood_checkin_sheet.dart';
import '../../no_contact/data/no_contact_repository.dart';
import '../../plan/application/plan_progress.dart';
import '../domain/week_summary.dart';

/// Insights: 14-day mood line, a calm week summary, and counts. Recovery is
/// framed as non-linear; nothing here says "behind" or "failed".
class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final now = DateTime.now();
    final moods = ref.watch(moodEntriesProvider).value;
    final journal = ref.watch(journalEntriesProvider).value ?? const [];
    final nc = ref.watch(noContactProvider).value;
    final plan = ref.watch(planStateProvider).value;

    final fmt = DateFormat.MMMd(context.localeName);

    return Scaffold(
      body: ScreenBackground(
        child: LargeTitleScrollView(
          title: l.insightsTitle,
          bottomPadding: MyExSpacing.s8 + MediaQuery.paddingOf(context).bottom,
          leading: GlassIconButton(
            icon: Icons.chevron_left_rounded,
            semanticLabel: l.commonBack,
            onPressed: () =>
                context.canPop() ? context.pop() : context.go(Routes.home),
          ),
          onRefresh: () async => ref
            ..invalidate(moodEntriesProvider)
            ..invalidate(journalEntriesProvider)
            ..invalidate(noContactProvider),
          children: [
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
              SolidCard(
                padding: const EdgeInsets.all(MyExSpacing.s5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l.insightsMood, style: MyExType.headline),
                    const Gap(MyExSpacing.s4),
                    MoodLineChart(
                      values: dailyMoodAverages(moods, now),
                      semanticLabel: l.insightsChartSemantics(
                        _weekLine(context, WeekSummary.of(moods, now)),
                      ),
                      xLabels: [
                        fmt.format(now.subtract(const Duration(days: 13))),
                        fmt.format(now.subtract(const Duration(days: 7))),
                        fmt.format(now),
                      ],
                    ),
                    const Gap(MyExSpacing.s4),
                    Text(l.insightsNonLinear, style: MyExType.footnote),
                  ],
                ),
              ),
              _WeekCard(summary: WeekSummary.of(moods, now)),
            ],
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

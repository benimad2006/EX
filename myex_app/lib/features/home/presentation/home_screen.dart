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
import '../../monetization/application/monetization_providers.dart';
import '../../monetization/domain/paywall_offer.dart';
import '../../monetization/presentation/paywall_copy.dart';
import '../../monetization/presentation/widgets/status_chips.dart';
import '../../no_contact/data/no_contact_repository.dart';
import '../../no_contact/domain/no_contact.dart';
import '../../onboarding/application/onboarding_controller.dart';
import '../../plan/application/plan_progress.dart';
import '../../plan/domain/plan_models.dart';

/// Home (spec H1): large title "Today", the streak hero (the app's only
/// gradient), then grouped lists. Premium is a quiet row, never a pop-up.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String _greeting(BuildContext context) {
    final l = context.l10n;
    final h = DateTime.now().hour;
    if (h < 5) return l.homeGreetingLate;
    if (h < 12) return l.homeGreetingMorning;
    if (h < 18) return l.homeGreetingAfternoon;
    return l.homeGreetingEvening;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final name = ref.watch(onboardingProvider).name;
    final premium = ref.watch(premiumProvider).value;
    final isPremium = premium?.isActive ?? false;
    final limits = ref.watch(limitsProvider).value;
    final nc = ref.watch(noContactProvider).value;
    final moods = ref.watch(moodEntriesProvider).value;
    final entries = ref.watch(journalEntriesProvider).value;
    final offer = isPremium ? null : ref.watch(paywallOfferProvider).value;
    final trialDays = offer == null
        ? null
        : PaywallCopy(offer: offer, l10n: l).trialDays;
    final greeting = _greeting(context);
    final plan = ref.watch(planStateProvider).value;

    return ScreenBackground(
      child: LargeTitleScrollView(
        title: l.homeTitle,
        subtitle: name == null ? greeting : l.homeGreetingName(greeting, name),
        trailing: const CoinChip(),
        onRefresh: () async {
          invalidateMonetization(ref);
          ref
            ..invalidate(noContactProvider)
            ..invalidate(moodEntriesProvider)
            ..invalidate(journalEntriesProvider);
        },
        children: [
          if (premium?.billingIssue ?? false)
            BillingIssueBanner(
              title: l.billingIssueTitle,
              message: l.meBillingIssue,
              actionLabel: l.billingIssueCta,
              onAction: () =>
                  Links.openManageSubscriptions(premium?.managementUrl),
            ),
          _StreakHero(state: nc, onTap: () => context.push(Routes.noContact)),
          _MoodCard(moods: moods),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SectionHeader(l.homeDayHeader),
              InsetGroup(
                children: [
                  _todayRow(context, ref, plan),
                  ListRow(
                    leading: const IconSquare(
                      icon: Icons.chat_bubble_outline_rounded,
                      tone: IconTone.neutral,
                    ),
                    title: l.homeMiraTitle,
                    subtitle: isPremium
                        ? l.homeMiraUnlimited
                        : limits == null
                        ? null
                        : l.homeMiraFreeLeft(limits.freeMessagesLeft),
                    onTap: () => context.go(Routes.coach),
                  ),
                  ListRow(
                    key: const Key('home-journal-row'),
                    leading: const IconSquare(
                      icon: Icons.book_outlined,
                      tone: IconTone.neutral,
                    ),
                    title: l.homeJournalTitle,
                    subtitle: entries == null
                        ? null
                        : l.homeJournalSub(entries.length),
                    onTap: () => context.go(Routes.journal),
                  ),
                ],
              ),
            ],
          ),
          InsetGroup(
            children: [
              ListRow(
                leading: const IconSquare(
                  icon: Icons.edit_outlined,
                  tone: IconTone.neutral,
                ),
                title: l.homeDraftTitle,
                subtitle: l.homeDraftSub,
                onTap: () => context.push(Routes.drafts),
              ),
              ListRow(
                key: const Key('home-sos-row'),
                leading: const IconSquare(
                  icon: Icons.favorite_border_rounded,
                  tone: IconTone.danger,
                ),
                title: l.homeSosTitle,
                subtitle: l.homeSosSub,
                onTap: () => context.push(Routes.sosFrom('home')),
              ),
            ],
          ),
          if (premium != null && premium.isActive && premium.isTrial)
            InsetGroup(
              children: [
                ListRow(
                  leading: const IconSquare(icon: Icons.schedule_rounded),
                  title: l.homeTrialTitle(_daysLeft(premium.expiresAt)),
                  subtitle: l.homeTrialSub,
                  onTap: () => context.push(Routes.trial),
                ),
              ],
            )
          else if (!isPremium)
            InsetGroup(
              children: [
                ListRow(
                  leading: const IconSquare(
                    icon: Icons.lock_outline_rounded,
                    tone: IconTone.neutral,
                  ),
                  title: l.homeUpsellTitle,
                  value: trialDays != null
                      ? l.homeUpsellTryFree
                      : l.homeUpsellSeePlans,
                  onTap: () =>
                      context.push(Routes.paywallFor(PaywallTrigger.homeChip)),
                ),
              ],
            ),
        ],
      ),
    );
  }

  /// Today's plan step (real progress), or the plan overview while loading.
  Widget _todayRow(BuildContext context, WidgetRef ref, PlanState? plan) {
    final l = context.l10n;
    final t = plan?.teasers.where((t) => t.day == plan.currentDay).firstOrNull;
    if (plan == null || t == null || plan.finished) {
      return ListRow(
        leading: const IconSquare(icon: Icons.calendar_today_outlined),
        title: l.homePlanTitle,
        subtitle: plan?.finished ?? false ? l.planFinished : null,
        onTap: () => context.go(Routes.plan),
      );
    }
    final status = plan.statusOf(t.day);
    return ListRow(
      key: const Key('home-today-row'),
      leading: const IconSquare(icon: Icons.calendar_today_outlined),
      title: t.title,
      subtitle: switch (status) {
        PlanDayStatus.open => l.planRowToday(t.day, t.minutes),
        PlanDayStatus.locked => l.planRowLocked(t.day),
        _ => l.planRowOpensAt(
          t.day,
          context.timeOfDay(PlanSchedule.nextReset(plan.now)),
        ),
      },
      onTap: () => status == PlanDayStatus.open
          ? context.push(Routes.planDay(t.day))
          : context.go(Routes.plan),
    );
  }

  static int _daysLeft(DateTime? end) {
    if (end == null) return 0;
    final d = end.difference(DateTime.now()).inHours / 24;
    return d <= 0 ? 0 : d.ceil();
  }
}

class _StreakHero extends StatelessWidget {
  const _StreakHero({required this.state, required this.onTap});

  final NoContactState? state;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final now = DateTime.now();
    final s = state;
    final labelStyle = MyExType.subheadline.copyWith(
      color: MyExColors.onHero,
      fontWeight: FontWeight.w600,
    );
    final label = Row(
      children: [
        const Icon(Icons.local_fire_department_outlined, size: MyExSizes.icon),
        const Gap(MyExSpacing.s1 + 2),
        Text(l.homeHeroLabel, style: labelStyle),
      ],
    );
    if (s == null) return const SkeletonBox(height: 168);
    if (s.current == null) {
      return HeroCard(
        key: const Key('home-hero-start'),
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            label,
            const Gap(MyExSpacing.s3),
            Text(
              l.homeHeroStart,
              style: MyExType.display.copyWith(
                color: MyExColors.onHero,
                fontSize: 30,
                height: 34 / 30,
              ),
            ),
            const Gap(MyExSpacing.s4),
            Row(
              children: [
                Text(
                  l.homeHeroChooseGoal,
                  style: MyExType.headline.copyWith(color: MyExColors.onHero),
                ),
                const Gap(MyExSpacing.s1),
                const Icon(Icons.arrow_forward_rounded, size: MyExSizes.icon),
              ],
            ),
          ],
        ),
      );
    }
    final days = s.currentDays(now);
    final target = s.nextTarget(now);
    final chosen = s.chosenDays(now);
    return Semantics(
      button: true,
      label: '${l.homeHeroLabel}: $days ${l.homeHeroUnit(days)}',
      excludeSemantics: true,
      child: HeroCard(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            label,
            const Gap(MyExSpacing.s1),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '$days',
                  style: MyExType.numeral(
                    MyExType.numeralHero,
                  ).copyWith(color: MyExColors.onHero),
                ),
                const Gap(MyExSpacing.s2),
                Text(
                  l.homeHeroUnit(days),
                  style: MyExType.title3.copyWith(color: MyExColors.onHero),
                ),
              ],
            ),
            const Gap(MyExSpacing.s3),
            ProgressBar(
              value: target == 0 ? 0 : days / target,
              color: MyExColors.onHero,
              track: MyExColors.heroTrack,
            ),
            const Gap(MyExSpacing.s2),
            Text(
              l.homeHeroNext(target - days, target),
              style: MyExType.subheadline.copyWith(color: MyExColors.onHero),
            ),
            if (chosen > days) ...[
              const Gap(MyExSpacing.s1),
              Text(
                l.homeHeroChosen(chosen),
                style: MyExType.footnote.copyWith(
                  color: MyExColors.onHero.withValues(alpha: 0.85),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Inline check-in (two taps) + this week's dots. The dots open Insights.
class _MoodCard extends StatelessWidget {
  const _MoodCard({required this.moods});
  final List<MoodEntry>? moods;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final now = DateTime.now();
    final all = moods ?? const <MoodEntry>[];
    final today = todaysMood(all, now);
    final week = dailyMoodAverages(all, now, days: 7);
    final letter = DateFormat('EEEEE', context.localeName);
    return SolidCard(
      key: const Key('home-mood-card'),
      padding: const EdgeInsets.all(MyExSpacing.s5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (today == null) ...[
            Text(l.homeMoodTitle, style: MyExType.headline),
            const Gap(MyExSpacing.s3),
            MoodScale(
              value: null,
              dotSize: 34,
              words: l.moodWords,
              semantics: l.moodScaleSemantics,
              onChanged: (lv) => showMoodCheckIn(context, initialLevel: lv),
            ),
          ] else ...[
            Row(
              children: [
                MoodDot(level: today.level.toDouble(), size: 14),
                const Gap(MyExSpacing.s2),
                Expanded(
                  child: Text(
                    l.homeMoodDone(l.moodWord(today.level)),
                    style: MyExType.headline,
                  ),
                ),
              ],
            ),
            if (today.feelings.isNotEmpty) ...[
              const Gap(MyExSpacing.s1),
              Text(
                today.feelings.map(l.feeling).join(' · '),
                style: MyExType.subheadline,
              ),
            ],
            const Gap(MyExSpacing.s2),
            Row(
              children: [
                TextLinkButton(
                  label: l.homeMoodWrite,
                  small: true,
                  semibold: true,
                  onPressed: () => context.push(Routes.journalEntry()),
                ),
                const Gap(MyExSpacing.s4),
                TextLinkButton(
                  label: l.homeMoodAgain,
                  small: true,
                  tone: TextLinkTone.muted,
                  onPressed: () => showMoodCheckIn(context),
                ),
              ],
            ),
          ],
          const Gap(MyExSpacing.s4),
          Divider(
            height: MyExSizes.hairline,
            thickness: MyExSizes.hairline,
            color: MyExColors.sep,
          ),
          const Gap(MyExSpacing.s4),
          Pressable(
            onTap: () => context.push(Routes.insights),
            pressedScale: 0.98,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Text(l.homeWeekTitle, style: MyExType.subheadline),
                    const Spacer(),
                    Text(
                      l.homeWeekSee,
                      style: MyExType.subheadline.copyWith(
                        color: MyExColors.accentInk,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: MyExSizes.icon,
                      color: MyExColors.accentInk,
                    ),
                  ],
                ),
                const Gap(MyExSpacing.s3),
                WeekStrip(
                  days: [
                    for (var i = 0; i < 7; i++)
                      (
                        letter.format(now.subtract(Duration(days: 6 - i))),
                        week[i],
                        i == 6,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

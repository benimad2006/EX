import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/analytics/analytics.dart';
import '../../../core/analytics/track_once.dart';
import '../../../core/design/design.dart';
import '../../../core/router/app_router.dart';
import '../../../core/util/context_x.dart';
import '../../onboarding/application/onboarding_controller.dart';
import '../../onboarding/presentation/onboarding_labels.dart';
import '../../plan/application/plan_progress.dart';
import '../domain/monetization_ids.dart';
import '../domain/paywall_offer.dart';

/// "Plan ready" (spec S1 + research R1/R12/R20): value before price. Every
/// row comes from the user's answers; the first 3 days are shown concretely.
/// One of the four Lumi screens.
class PlanReadyScreen extends ConsumerWidget {
  const PlanReadyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final a = ref.watch(onboardingProvider);
    final teasers = ref.watch(planStateProvider).value?.teasers ?? const [];
    final rows = <(String, String?)>[
      (
        l.planReadyWhatHappened,
        a.whatHappened == null ? null : l.whatHappenedLabel(a.whatHappened!),
      ),
      (
        l.planReadyWhen,
        a.endedWhen == null ? null : l.endedWhenLabel(a.endedWhen!),
      ),
      (l.planReadyTrack, a.contact == null ? null : l.trackLabel(a.contact)),
      (
        l.planReadyAttachment,
        a.attachmentStyle == null
            ? null
            : l.attachmentLabel(a.attachmentStyle!),
      ),
      (l.planReadyFocus, a.focus == null ? null : l.focusLabel(a.focus!)),
    ].where((r) => r.$2 != null && r.$2!.isNotEmpty).toList();

    final firstDays = [
      for (final t in teasers)
        if (t.day <= MonetizationDisplay.freePlanDays) t,
    ];

    return TrackOnce(
      onShown: ref.read(analyticsProvider).planReadyView,
      child: Scaffold(
        body: ScreenBackground(
          child: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: kScreenPadding.copyWith(top: MyExSpacing.s6),
                    children: [
                      const Center(child: NightMark()),
                      const Gap(MyExSpacing.s4),
                      DisplayText(
                        a.name == null
                            ? l.planReadyTitle
                            : l.planReadyTitleNamed(a.name!),
                      ),
                      const Gap(MyExSpacing.s2),
                      Text(
                        l.planReadySub,
                        textAlign: TextAlign.center,
                        style: MyExType.body.copyWith(color: MyExColors.ink2),
                      ),
                      const Gap(MyExSpacing.section),
                      if (rows.isNotEmpty)
                        InsetGroup(
                          children: [
                            for (final (k, v) in rows)
                              ListRow(title: k, value: v, chevron: false),
                          ],
                        ),
                      if (firstDays.isNotEmpty) ...[
                        SectionHeader(l.planReadyFirstDays),
                        InsetGroup(
                          children: [
                            for (final t in firstDays)
                              ListRow(
                                leading: DayBadge(
                                  day: t.day,
                                  tone: t.day == 1
                                      ? DayBadgeTone.today
                                      : DayBadgeTone.open,
                                ),
                                title: t.title,
                                subtitle: t.day == 1
                                    ? l.planReadyTonight(t.minutes)
                                    : l.planReadyDayRow(t.day),
                                chevron: false,
                              ),
                          ],
                        ),
                      ],
                      if (a.hardest != null) ...[
                        const Gap(MyExSpacing.s4),
                        InsetGroup(
                          children: [
                            ListRow(
                              leading: const IconSquare(
                                icon: MyExIcons.heart,
                                tone: IconTone.neutral,
                              ),
                              title: l.planReadySupport(
                                l.hardestLabel(a.hardest!),
                              ),
                              chevron: false,
                            ),
                          ],
                        ),
                      ],
                      const Gap(MyExSpacing.s4),
                      Footnote(l.planReadyLocked),
                      const Gap(MyExSpacing.s1),
                      Footnote(l.planReadyNote),
                    ],
                  ),
                ),
                Padding(
                  padding: kScreenPadding.copyWith(
                    top: MyExSpacing.s3,
                    bottom: MyExSpacing.s4,
                  ),
                  child: PrimaryButton(
                    label: l.planReadyCta,
                    onPressed: () => context.push(
                      Routes.paywallFor(PaywallTrigger.onboarding),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

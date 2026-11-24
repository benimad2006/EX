import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/analytics/analytics.dart';
import '../../../core/analytics/track_once.dart';
import '../../../core/design/design.dart';
import '../../../core/router/app_router.dart';
import '../../../core/util/context_x.dart';
import '../../monetization/application/monetization_providers.dart';
import '../../monetization/domain/price_format.dart';
import '../data/lifecycle_repository.dart';

/// Trial status (M7 / spec S7): days left, the real value recap, what happens
/// next with the StoreKit price, and the cancel path right here.
class TrialStatusScreen extends ConsumerWidget {
  const TrialStatusScreen({super.key});

  static const _trialDaysFallback = 7;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final premium = ref.watch(premiumProvider).value;
    final recap = ref.watch(valueRecapProvider).value;
    final offer = ref.watch(paywallOfferProvider).value;
    final end = premium?.expiresAt;
    final inTrial =
        (premium?.isActive ?? false) && premium!.isTrial && end != null;

    final daysLeft = !inTrial
        ? 0
        : (end.difference(DateTime.now()).inHours / 24).ceil().clamp(0, 365);
    final intro = offer?.annual.intro;
    final total =
        (intro == null ? null : TrialMath.days(intro, DateTime.now())) ??
        _trialDaysFallback;

    return TrackOnce(
      onShown: () =>
          ref.read(analyticsProvider).trialStatusView(daysLeft: daysLeft),
      child: Scaffold(
        body: ScreenBackground(
          child: Column(
            children: [
              Expanded(
                child: LargeTitleScrollView(
                  title: l.trialTitle,
                  largeTitle: false,
                  bottomPadding: MyExSpacing.s6,
                  leading: GlassIconButton(
                    icon: MyExIcons.back,
                    semanticLabel: l.commonBack,
                    onPressed: () => context.canPop()
                        ? context.pop()
                        : context.go(Routes.home),
                  ),
                  children: [
                    if (!inTrial)
                      Footnote(l.trialNotActive)
                    else
                      SolidCard(
                        child: Row(
                          children: [
                            ProgressRing(
                              value: total == 0
                                  ? 0
                                  : (total - daysLeft) / total,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '$daysLeft',
                                    style: MyExType.numeral(
                                      MyExType.numeralRing,
                                    ),
                                  ),
                                  Text(
                                    l.trialDaysLeft(daysLeft),
                                    style: MyExType.caption1,
                                  ),
                                ],
                              ),
                            ),
                            const Gap(MyExSpacing.s4),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l.trialFreeUntil(context.shortDate(end)),
                                    style: MyExType.headline,
                                  ),
                                  Text(
                                    !premium.willRenew
                                        ? l.trialEndsNoCharge(
                                            context.shortDate(end),
                                          )
                                        : offer == null
                                        ? l.trialThenNoPrice
                                        : l.trialThen(offer.annual.priceString),
                                    style: MyExType.subheadline,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SectionHeader(l.trialSoFar),
                        SolidCard(
                          child: IntrinsicHeight(
                            child: Row(
                              children: [
                                _Stat(value: recap?.talks, label: l.trialTalks),
                                VerticalDivider(
                                  width: MyExSpacing.s4,
                                  thickness: MyExSizes.hairline,
                                  color: MyExColors.sep,
                                ),
                                _Stat(
                                  value: recap?.draftsNotSent,
                                  label: l.trialDrafts,
                                ),
                                VerticalDivider(
                                  width: MyExSpacing.s4,
                                  thickness: MyExSizes.hairline,
                                  color: MyExColors.sep,
                                ),
                                _Stat(
                                  value: recap?.daysDone,
                                  label: l.trialDaysDone,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SolidCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l.trialNextTitle, style: MyExType.headline),
                          Text(l.trialNextBody, style: MyExType.subheadline),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  MyExSpacing.margin,
                  MyExSpacing.s3,
                  MyExSpacing.margin,
                  MediaQuery.paddingOf(context).bottom + MyExSpacing.s2,
                ),
                child: Column(
                  children: [
                    PrimaryButton(
                      label: l.trialBack,
                      onPressed: () => context.go(Routes.home),
                    ),
                    TextLinkButton(
                      label: l.meManage,
                      onPressed: () =>
                          Links.openManageSubscriptions(premium?.managementUrl),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});
  final int? value;
  final String label;

  @override
  Widget build(BuildContext context) => Expanded(
    child: MergeSemantics(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value?.toString() ?? '–',
            style: MyExType.title1.copyWith(fontFeatures: MyExType.tabular),
          ),
          Text(label, style: MyExType.footnote),
        ],
      ),
    ),
  );
}

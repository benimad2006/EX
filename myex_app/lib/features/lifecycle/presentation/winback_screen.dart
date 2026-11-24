import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/analytics/analytics.dart';
import '../../../core/design/design.dart';
import '../../../core/router/app_router.dart';
import '../../../core/util/context_x.dart';
import '../../home/application/streak.dart';
import '../../monetization/application/monetization_providers.dart';
import '../../monetization/domain/paywall_offer.dart';
import '../../monetization/domain/purchase_outcome.dart';

final _winbackOfferProvider = FutureProvider.autoDispose<PromoOffer?>(
  (ref) => ref.watch(purchasesRepositoryProvider).getWinback(),
);

/// Win-back (M7 / spec S11): shown once, 7–14 days after Premium lapsed (the
/// server decides and records it). Leads with what they kept; one honest
/// offer (App Store promotional offer, StoreKit prices); one clear "no".
class WinbackScreen extends ConsumerStatefulWidget {
  const WinbackScreen({super.key});

  @override
  ConsumerState<WinbackScreen> createState() => _WinbackScreenState();
}

class _WinbackScreenState extends ConsumerState<WinbackScreen> {
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => ref.read(analyticsProvider).winbackShown(),
    );
  }

  Future<void> _claim(PromoOffer? offer) async {
    if (_busy) return;
    // No offer (not eligible / no key): normal paywall, no discount mentioned.
    if (offer == null || offer.plan.handle == null) {
      unawaited(context.push(Routes.paywallFor(PaywallTrigger.winback)));
      return;
    }
    setState(() => _busy = true);
    final outcome = await ref
        .read(purchasesRepositoryProvider)
        .buyWithPromo(offer.plan.handle!, offer.offerId);
    if (!mounted) return;
    setState(() => _busy = false);
    final l = context.l10n;
    switch (outcome) {
      case PurchaseSuccess():
        ref.read(analyticsProvider).winbackClaimed();
        unawaited(MyExHaptics.success());
        invalidateMonetization(ref);
        context.go(Routes.welcomeFor(trial: false));
      case PurchaseCancelled():
        break;
      case PurchasePending():
        showMyExToast(context, l.paywallPending);
      case PurchaseFailed() || PurchaseAlreadyOwned():
        unawaited(context.push(Routes.paywallFor(PaywallTrigger.winback)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final offerAsync = ref.watch(_winbackOfferProvider);
    final offer = offerAsync.value;
    final since = ref.watch(noContactSinceProvider).value;
    final streak = since == null ? 0 : streakDays(since, DateTime.now());
    final months = offer?.months;

    return Scaffold(
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
                    DisplayText(l.winbackTitle),
                    const Gap(MyExSpacing.s2),
                    Text(
                      streak > 0 ? l.winbackSubStreak(streak) : l.winbackSub,
                      textAlign: TextAlign.center,
                      style: MyExType.body.copyWith(color: MyExColors.ink2),
                    ),
                    const Gap(MyExSpacing.section),
                    if (offerAsync.isLoading)
                      const SkeletonBox(height: MyExSizes.skeletonList / 1.5)
                    else if (offer != null && months != null)
                      SolidCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l.winbackOfferLabel,
                              style: MyExType.footnote.copyWith(
                                color: MyExColors.accentInk,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              offer.priceString,
                              style: MyExType.largeTitle.copyWith(
                                fontFeatures: MyExType.tabular,
                              ),
                            ),
                            Text(
                              l.winbackFor(months, offer.plan.priceString),
                              style: MyExType.subheadline,
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: kScreenPadding.copyWith(
                  top: MyExSpacing.s3,
                  bottom: MyExSpacing.s2,
                ),
                child: Column(
                  children: [
                    PrimaryButton(
                      label: l.winbackCta,
                      busy: _busy,
                      onPressed: offerAsync.isLoading
                          ? null
                          : () => _claim(offer),
                    ),
                    if (offer != null && months != null) ...[
                      const Gap(MyExSpacing.s2),
                      Footnote(
                        l.winbackFine(
                          offer.priceString,
                          months,
                          offer.plan.priceString,
                        ),
                      ),
                    ],
                    TextLinkButton(
                      label: l.winbackNo,
                      onPressed: () {
                        ref.read(analyticsProvider).winbackDismissed();
                        context.go(Routes.home);
                      },
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

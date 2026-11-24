import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/analytics/analytics.dart';
import '../../../core/config/env.dart';
import '../../../core/design/design.dart';
import '../../../core/router/app_router.dart';
import '../../../core/util/context_x.dart';
import '../../checkins/nightly_checkin_service.dart';
import '../../monetization/application/monetization_providers.dart';
import '../../monetization/domain/monetization_ids.dart';
import '../../monetization/domain/paywall_offer.dart';
import '../../monetization/domain/premium_state.dart';
import '../../monetization/domain/purchase_outcome.dart';
import '../../monetization/presentation/paywall_copy.dart';
import '../../onboarding/application/onboarding_controller.dart';
import '../../plan/application/plan_progress.dart';
import '../../subscription/data/subscription_repository.dart';
import '../../subscription/domain/cancel_survey.dart';
import '../../subscription/presentation/cancel_survey_sheet.dart';

/// "Me" = the subscription hub (M8 / spec S6). Free: a calm upgrade card.
/// Subscribers: plan, renewal date, switch, manage, and an easy cancel that
/// opens an optional one-question survey and never blocks the exit.
class MeScreen extends ConsumerStatefulWidget {
  const MeScreen({super.key});

  @override
  ConsumerState<MeScreen> createState() => _MeScreenState();
}

class _MeScreenState extends ConsumerState<MeScreen> {
  bool _restoring = false;
  bool _returningFromSettings = false;
  AppLifecycleListener? _life;

  @override
  void initState() {
    super.initState();
    // Coming back from App Store management: refresh status, don't nag.
    _life = AppLifecycleListener(
      onResume: () {
        if (!_returningFromSettings) return;
        _returningFromSettings = false;
        unawaited(
          ref
              .read(walletRepositoryProvider)
              .syncPurchases()
              .catchError((Object _) {}),
        );
        invalidateMonetization(ref);
      },
    );
  }

  @override
  void dispose() {
    _life?.dispose();
    super.dispose();
  }

  Future<void> _openManage(PremiumState? p, {String source = 'me'}) async {
    ref.read(analyticsProvider).manageSubscriptionOpened(source: source);
    _returningFromSettings = true;
    await Links.openManageSubscriptions(p?.managementUrl);
  }

  Future<void> _restore() async {
    setState(() => _restoring = true);
    final outcome = await ref.read(purchasesRepositoryProvider).restore();
    if (!mounted) return;
    setState(() => _restoring = false);
    invalidateMonetization(ref);
    final l = context.l10n;
    final (msg, ok) = switch (outcome) {
      PurchaseSuccess(premiumActive: true) => (l.paywallRestoreDone, true),
      PurchaseSuccess() => (l.paywallRestoreNone, false),
      PurchaseCancelled() => (null, false),
      PurchasePending() => (l.paywallPending, false),
      _ => (l.paywallFailed, false),
    };
    if (msg != null) showMyExToast(context, msg, success: ok);
  }

  Future<bool> _buy(Object? handle) async {
    if (handle == null) return false;
    final o = await ref.read(purchasesRepositoryProvider).buy(handle);
    invalidateMonetization(ref);
    return o is PurchaseSuccess;
  }

  Future<void> _cancel(PremiumState p, PaywallCopy? copy) async {
    final repo = ref.read(purchasesRepositoryProvider);
    final save50 = await repo.getSave50Annual().catchError((Object _) => null);
    if (!mounted) return;
    ref.read(analyticsProvider).cancelSurveyShown();
    await showCancelSurvey(
      context,
      CancelSurveyDeps(
        productId: p.productId,
        log: _AnalyticsCancelLog(
          ref.read(cancelSurveyLogProvider),
          ref.read(analyticsProvider),
        ),
        openManage: () => _openManage(p, source: 'cancel_survey'),
        save50PriceString: save50?.priceString,
        keepWithSave50: save50?.plan.handle == null
            ? null
            : () async {
                final o = await repo.buyWithPromo(
                  save50!.plan.handle!,
                  save50.offerId,
                );
                invalidateMonetization(ref);
                return o is PurchaseSuccess;
              },
        yearlySavingsPct: copy?.savingsPct,
        yearlyPriceString: copy?.yearlyPrice,
        switchToYearly: copy?.offer.annual.handle == null
            ? null
            : () => _buy(copy!.offer.annual.handle),
        enableCheckin: () => ref.read(nightlyCheckinProvider).enable(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final premium = ref.watch(premiumProvider).value;
    final active = premium?.isActive ?? false;
    final balance = ref.watch(coinBalanceProvider).value;
    final offer = ref.watch(paywallOfferProvider).value;
    final copy = offer == null ? null : PaywallCopy(offer: offer, l10n: l);
    final trialDays = active ? null : copy?.trialDays;
    final name = ref.watch(onboardingProvider).name;
    final day = ref.watch(currentPlanDayProvider);

    final String status = !active
        ? l.meStatusFree
        : (premium!.isTrial ? l.meStatusTrial : l.meStatusPremium);
    final isMonthly = premium?.productId == MonetizationIds.monthly;

    String planName() => switch (premium?.productId) {
      MonetizationIds.monthly => l.mePlanMonthly,
      MonetizationIds.annual || MonetizationIds.annualIntroExit =>
        premium!.isTrial ? l.mePlanYearlyTrial : l.mePlanYearly,
      _ => l.mePlanPremium,
    };

    final expires = premium?.expiresAt;

    return ScreenBackground(
      child: LargeTitleScrollView(
        title: l.meTitle,
        children: [
          // Profile row
          MergeSemantics(
            child: Row(
              children: [
                Container(
                  width: MyExSizes.avatar,
                  height: MyExSizes.avatar,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: MyExColors.accent,
                  ),
                  child: Text(
                    (name ?? l.meNameFallback).characters.first.toUpperCase(),
                    style: MyExType.title2.copyWith(color: MyExColors.onAccent),
                  ),
                ),
                const Gap(MyExSpacing.s3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name ?? l.meNameFallback, style: MyExType.title3),
                      Text(
                        l.meDayStatus(day, status),
                        style: MyExType.footnote,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (premium?.billingIssue ?? false)
            BillingIssueBanner(
              title: l.billingIssueTitle,
              message: l.meBillingIssue,
              actionLabel: l.billingIssueCta,
              onAction: () => _openManage(premium),
            ),
          if (!active)
            SolidCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    trialDays != null
                        ? l.meFreeCardTitleTrial(trialDays)
                        : l.meFreeCardTitle,
                    style: MyExType.title3,
                  ),
                  const Gap(MyExSpacing.s1),
                  Text(l.meFreeCardBody, style: MyExType.subheadline),
                  const Gap(MyExSpacing.s3),
                  PrimaryButton(
                    expand: false,
                    label: trialDays != null ? l.meTryFree : l.meSeePlans,
                    onPressed: () =>
                        context.push(Routes.paywallFor(PaywallTrigger.me)),
                  ),
                ],
              ),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SectionHeader(l.meSubscriptionHeader),
                InsetGroup(
                  children: [
                    ListRow(title: l.mePlan, value: planName(), chevron: false),
                    if (expires != null)
                      ListRow(
                        title: !premium!.willRenew
                            ? l.meEnds
                            : premium.isTrial
                            ? l.meTrialEnds
                            : l.meRenews,
                        value: context.shortDate(expires),
                        chevron: false,
                      ),
                    if (isMonthly &&
                        copy?.saveLabel != null &&
                        copy?.offer.annual.handle != null)
                      ListRow(
                        title: l.meSwitchYearly,
                        titleColor: MyExColors.accentInk,
                        trailing: Text(copy!.saveLabel!, style: MyExType.save),
                        chevron: false,
                        onTap: () => _buy(copy.offer.annual.handle),
                      ),
                    ListRow(
                      title: l.meManage,
                      onTap: () => _openManage(premium),
                    ),
                    if (premium!.willRenew)
                      ListRow(
                        key: const Key('me-cancel'),
                        title: l.meCancel,
                        titleColor: MyExColors.danger,
                        chevron: false,
                        onTap: () => _cancel(premium, copy),
                      ),
                  ],
                ),
                if (!premium.willRenew && expires != null)
                  SectionFooter(l.meCancelledNote(context.shortDate(expires))),
              ],
            ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SectionHeader(l.meAccountHeader),
              InsetGroup(
                children: [
                  ListRow(
                    leading: const CoinIcon(size: MyExSizes.iconSquare),
                    title: l.meCoins,
                    value: balance?.toString(),
                    onTap: () => context.push(Routes.coins),
                  ),
                  ListRow(
                    leading: const IconSquare(
                      icon: Icons.restore_rounded,
                      tone: IconTone.neutral,
                    ),
                    title: l.meRestore,
                    chevron: false,
                    onTap: _restoring ? null : _restore,
                  ),
                  if (active && premium!.isTrial)
                    ListRow(
                      leading: const IconSquare(icon: Icons.schedule_rounded),
                      title: l.meTrialProgress,
                      onTap: () => context.push(Routes.trial),
                    ),
                  ListRow(
                    leading: const IconSquare(
                      icon: Icons.edit_outlined,
                      tone: IconTone.neutral,
                    ),
                    title: l.homeDraftTitle,
                    onTap: () => context.push(Routes.drafts),
                  ),
                ],
              ),
            ],
          ),
          InsetGroup(
            children: [
              if (Env.supportEmail.isNotEmpty)
                ListRow(
                  title: l.meSupport,
                  onTap: () => Links.openInApp('mailto:${Env.supportEmail}'),
                ),
              ListRow(
                title: l.commonTermsOfUse,
                onTap: () => Links.openInApp(Env.termsUrl),
              ),
              ListRow(
                title: l.commonPrivacyPolicy,
                onTap: () => Links.openInApp(Env.privacyUrl),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Mirrors survey answers to analytics (reason + offer only, never the note).
class _AnalyticsCancelLog implements CancelSurveyLog {
  _AnalyticsCancelLog(this._inner, this._a);
  final CancelSurveyLog _inner;
  final Analytics _a;

  @override
  Future<void> record({
    required CancelReason reason,
    String? offerShown,
    bool offerAccepted = false,
    String? note,
  }) {
    _a.cancelReason(reason: reason.name, offerShown: offerShown);
    if (offerAccepted) _a.cancelOfferAccepted(reason: reason.name);
    return _inner.record(
      reason: reason,
      offerShown: offerShown,
      offerAccepted: offerAccepted,
      note: note,
    );
  }
}

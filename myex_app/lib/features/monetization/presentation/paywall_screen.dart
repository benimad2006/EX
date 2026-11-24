import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/analytics/analytics.dart';
import '../../../core/design/design.dart';
import '../../../core/notifications/notification_service.dart';
import '../../../core/router/app_router.dart';
import '../../../core/supabase/supabase_providers.dart';
import '../../../core/util/context_x.dart';
import '../../onboarding/application/onboarding_controller.dart';
import '../../onboarding/presentation/onboarding_labels.dart';
import '../../onboarding/presentation/onboarding_quiz_screen.dart'
    show notifPrePromptedKey;
import '../application/monetization_providers.dart';
import '../domain/monetization_ids.dart';
import '../domain/paywall_offer.dart';
import '../domain/purchase_outcome.dart';
import 'exit_offer_sheet.dart';
import 'paywall_copy.dart';
import 'widgets/compare_table.dart';
import 'widgets/paywall_fine_print.dart';
import 'widgets/plan_card.dart';
import 'widgets/trial_timeline.dart';

/// Paywall (A/B: Timeline | Compare from offering metadata).
///
/// Layout (design spec P1-P3): serif headline, 30-day strip, 3 benefits, plan
/// picker with a sliding highlight (billed price is the main price; the yearly
/// monthly equivalent is small text; no per-week price), a trial timeline with
/// the reminder switch inside that collapses for Monthly, and a solid dock.
///
/// Compliance (M0): prices ONLY from StoreKit; close + restore visible at
/// first frame; no "free" wording unless trial-eligible; legal text + links.
class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key, required this.trigger});
  final PaywallTrigger trigger;

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  PlanPeriod _selected = PlanPeriod.annual;
  bool _busy = false;
  bool _closing = false;
  Future<ExitOffer?>? _exitOffer;
  final _openedAt = DateTime.now();
  bool _viewTracked = false;

  /// R5: reminder on, but notifications were refused → say so honestly.
  bool _notifBlocked = false;
  AppLifecycleListener? _life;

  Future<void> _checkNotifications() async {
    final n = ref.read(notificationServiceProvider);
    final granted = await n.hasPermission().catchError((Object _) => false);
    final asked =
        ref.read(sharedPreferencesProvider).getBool(notifPrePromptedKey) ??
        false;
    if (mounted) setState(() => _notifBlocked = asked && !granted);
  }

  /// Turning the reminder on asks the system directly if never asked (the
  /// onboarding pre-prompt already explained it); otherwise shows R5's row.
  Future<void> _onRemindChanged(bool v) async {
    _a.remindToggle(on: v);
    await ref.read(remindTrialProvider.notifier).set(v);
    if (!v) return;
    final prefs = ref.read(sharedPreferencesProvider);
    final n = ref.read(notificationServiceProvider);
    final granted = await n.hasPermission().catchError((Object _) => false);
    if (!granted && !(prefs.getBool(notifPrePromptedKey) ?? false)) {
      await prefs.setBool(notifPrePromptedKey, true);
      await n.requestPermission().catchError((Object _) => false);
    }
    await _checkNotifications();
  }

  @override
  void dispose() {
    _life?.dispose();
    super.dispose();
  }

  Analytics get _a => ref.read(analyticsProvider);
  String? get _variant => ref.read(paywallOfferProvider).value?.variant.name;
  String? get _offeringId => ref.read(paywallOfferProvider).value?.offeringId;

  @override
  void initState() {
    super.initState();
    _life = AppLifecycleListener(onResume: _checkNotifications);
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkNotifications());
    // Prefetch so the close (X) never waits on StoreKit.
    if (!ref.read(isPremiumProvider)) {
      _exitOffer = ref
          .read(purchasesRepositoryProvider)
          .getExitOffer()
          .catchError((Object _) => null);
    }
  }

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  Future<void> _buy(PaywallOffer offer) async {
    if (_busy) return;
    final plan = _selected == PlanPeriod.annual ? offer.annual : offer.monthly;
    final handle = plan.handle;
    if (handle == null) return;
    setState(() => _busy = true);
    _a.purchaseStarted(
      productId: plan.productId,
      offeringId: offer.offeringId,
      trigger: widget.trigger.name,
      variant: offer.variant.name,
    );
    final outcome = await ref.read(purchasesRepositoryProvider).buy(handle);
    if (!mounted) return;
    setState(() => _busy = false);
    await _handleOutcome(outcome, productId: plan.productId);
  }

  Future<void> _handleOutcome(
    PurchaseOutcome outcome, {
    required String productId,
  }) async {
    final l = context.l10n;
    switch (outcome) {
      case PurchaseSuccess(:final isTrial):
        _a.purchaseCompleted(
          productId: productId,
          offeringId: _offeringId,
          trigger: widget.trigger.name,
          variant: _variant,
          isTrial: isTrial,
        );
        await _onPremium(isTrial: isTrial);
      case PurchaseAlreadyOwned():
        await _restore();
      case PurchaseCancelled():
        _a.purchaseCancelled(
          productId: productId,
          trigger: widget.trigger.name,
        );
      case PurchasePending():
        _a.purchasePending(productId: productId);
        showMyExToast(context, l.paywallPending);
      case PurchaseFailed(:final code):
        _a.purchaseFailed(productId: productId, errorCode: code);
        showMyExToast(context, l.paywallFailed);
    }
  }

  Future<void> _onPremium({required bool isTrial}) async {
    unawaited(MyExHaptics.success());
    invalidateMonetization(ref);
    if (isTrial) {
      final remind = ref.read(remindTrialProvider);
      unawaited(
        ref
            .read(walletRepositoryProvider)
            .setRemindTrial(remind)
            .catchError((Object _) {}),
      );
    }
    await ref.read(onboardingProvider.notifier).markCompleted();
    if (!mounted) return;
    context.go(Routes.welcomeFor(trial: isTrial));
  }

  Future<void> _restore() async {
    if (_busy) return;
    setState(() => _busy = true);
    _a.restoreTapped(source: 'paywall');
    final outcome = await ref.read(purchasesRepositoryProvider).restore();
    if (!mounted) return;
    setState(() => _busy = false);
    final l = context.l10n;
    switch (outcome) {
      case PurchaseSuccess(:final premiumActive, :final isTrial):
        _a.restoreCompleted(found: premiumActive);
        invalidateMonetization(ref);
        if (premiumActive) {
          showMyExToast(context, l.paywallRestoreDone);
          await _onPremium(isTrial: isTrial);
        } else {
          showMyExToast(context, l.paywallRestoreNone);
        }
      case PurchaseCancelled():
        break;
      case PurchasePending():
        showMyExToast(context, l.paywallPending);
      case PurchaseAlreadyOwned() || PurchaseFailed():
        showMyExToast(context, l.paywallFailed);
    }
  }

  /// First close of any paywall may show the one-time exit offer, only if the
  /// server flag "wins" AND the user is eligible for the intro price.
  Future<void> _close() async {
    if (_closing) return;
    _closing = true;
    try {
      final exit = await _exitOffer;
      if (exit != null &&
          exitOfferDiscountPct(exit) != null &&
          mounted &&
          !ref.read(isPremiumProvider)) {
        final won = await ref
            .read(walletRepositoryProvider)
            .markExitOfferShown()
            .catchError((Object _) => false);
        if (won && mounted) {
          _a.exitOfferShown();
          final outcome = await showExitOfferSheet(
            context: context,
            offer: exit,
            onClaim: () =>
                ref.read(purchasesRepositoryProvider).buy(exit.plan.handle!),
          );
          if (!mounted) return;
          if (outcome is PurchaseSuccess) {
            _a.exitOfferClaimed();
            _a.purchaseCompleted(
              productId: exit.plan.productId,
              offeringId: 'exit_offer',
              trigger: widget.trigger.name,
              variant: _variant,
              isTrial: false,
            );
            await _onPremium(isTrial: false);
            return;
          }
          if (outcome == null) _a.exitOfferDismissed();
          if (outcome != null) {
            await _handleOutcome(outcome, productId: exit.plan.productId);
          }
          if (!mounted) return;
        }
      }
      await _leave();
    } finally {
      _closing = false;
    }
  }

  Future<void> _leave() async {
    _a.paywallClosed(
      variant: _variant,
      trigger: widget.trigger.name,
      timeOnScreenMs: DateTime.now().difference(_openedAt).inMilliseconds,
    );
    if (widget.trigger == PaywallTrigger.onboarding) {
      await ref.read(onboardingProvider.notifier).markCompleted();
      if (mounted) context.go(Routes.home);
      return;
    }
    if (!mounted) return;
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(Routes.home);
    }
  }

  // ---------------------------------------------------------------------------
  // UI
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final offerAsync = ref.watch(paywallOfferProvider);
    final offer = offerAsync.value;
    final copy = offer == null ? null : PaywallCopy(offer: offer, l10n: l);
    final top = MediaQuery.paddingOf(context).top;
    final answers = ref.watch(onboardingProvider);
    if (offer != null && copy != null && !_viewTracked) {
      _viewTracked = true;
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _a.paywallView(
          variant: offer.variant.name,
          trigger: widget.trigger.name,
          offeringId: offer.offeringId,
          trialEligible: copy.showsTrial,
        ),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) unawaited(_close());
      },
      child: Scaffold(
        body: ScreenBackground(
          child: Column(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    ListView(
                      padding: EdgeInsets.fromLTRB(
                        MyExSpacing.margin,
                        top + MyExSpacing.s2,
                        MyExSpacing.margin,
                        MyExSpacing.s6,
                      ),
                      children: [
                        _PosterHeader(title: l.paywallTitle),
                        const Gap(MyExSpacing.s3),
                        // R14: the billed price, in body size, above the fold.
                        Align(
                          alignment: Alignment.centerLeft,
                          child: SwapText(
                            copy?.subtitle(_selected) ?? l.paywallSub,
                            key: const Key('paywall-sub'),
                            textAlign: TextAlign.start,
                            style: MyExType.body.copyWith(
                              color: MyExColors.ink2,
                            ),
                          ),
                        ),
                        const Gap(MyExSpacing.section),
                        _Includes(
                          focus: answers.focus == null
                              ? null
                              : l.focusLabel(answers.focus!),
                        ),
                        const Gap(MyExSpacing.section),
                        ...switch (offerAsync) {
                          AsyncError() when offer == null => [
                            _ErrorCard(
                              onRetry: () =>
                                  ref.invalidate(paywallOfferProvider),
                              onContinueFree: _leave,
                            ),
                          ],
                          _ when copy == null => [const PlanCardSkeleton()],
                          _ => _plans(copy),
                        },
                        const Gap(MyExSpacing.section),
                        Footnote(l.paywallPrivacyNote, icon: MyExIcons.lock),
                        const Gap(MyExSpacing.s4),
                        if (copy != null) ...[
                          Footnote(
                            l.paywallFineCoins(
                              MonetizationDisplay.premiumMonthlyBonusCoins,
                            ),
                          ),
                          const Gap(MyExSpacing.s2),
                        ],
                        const PaywallLegalText(),
                      ],
                    ),
                    // Close + Restore: visible at first frame, no delay/fade.
                    NavBar(
                      leading: GlassIconButton(
                        key: const Key('paywall-close'),
                        icon: MyExIcons.close,
                        semanticLabel: l.commonClose,
                        onPressed: _close,
                      ),
                      trailing: TextLinkButton(
                        key: const Key('paywall-restore'),
                        label: l.commonRestore,
                        onPressed: _busy ? null : _restore,
                      ),
                    ),
                  ],
                ),
              ),
              _Dock(
                copy: copy,
                selected: _selected,
                busy: _busy,
                onBuy: copy == null ? null : () => _buy(copy.offer),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _plans(PaywallCopy copy) {
    final l = context.l10n;
    final timeline = copy.timeline;
    return [
      PlanPicker(
        semanticLabel: l.paywallPickerLabel,
        selected: _selected == PlanPeriod.annual ? 0 : 1,
        onSelect: (i) {
          setState(
            () => _selected = i == 0 ? PlanPeriod.annual : PlanPeriod.monthly,
          );
          _a.planSelected(
            productId: i == 0
                ? copy.offer.annual.productId
                : copy.offer.monthly.productId,
            variant: copy.offer.variant.name,
          );
        },
        options: [
          PlanOptionData(
            title: l.paywallYearly,
            saveLabel: copy.saveLabel,
            detail: copy.yearlyDetail,
            price: copy.yearlyPrice,
            period: l.paywallPerYear,
            semanticLabel: copy.yearlySemantics(),
          ),
          PlanOptionData(
            title: l.paywallMonthly,
            detail: l.paywallNoTrial,
            price: copy.monthlyPrice,
            period: l.paywallPerMonth,
            semanticLabel: copy.monthlySemantics(),
          ),
        ],
      ),
      if (copy.offer.variant == PaywallVariant.timeline &&
          timeline != null) ...[
        const Gap(MyExSpacing.s4),
        TrialTimeline(
          open: _selected == PlanPeriod.annual,
          remindDate: timeline.remind,
          endDate: timeline.end,
          annualPrice: copy.yearlyPrice,
          remind: ref.watch(remindTrialProvider),
          onRemindChanged: _onRemindChanged,
          notificationsBlocked: _notifBlocked,
          onOpenSettings: Links.canOpenAppSettings
              ? Links.openAppSettings
              : null,
        ),
      ],
      if (copy.offer.variant == PaywallVariant.compare) ...[
        const Gap(MyExSpacing.section),
        const CompareTable(),
      ],
      const Gap(MyExSpacing.s4),
      // R13: the real cancel steps, one tap away.
      HowToCancelRow(
        steps: defaultTargetPlatform == TargetPlatform.android
            ? l.paywallHowCancelAndroid
            : l.paywallHowCancelIos,
      ),
    ];
  }
}

/// Poster header: night scene (moon, stars, the dreamer) with the wordmark
/// and a bold stacked headline over its lower-left corner.
class _PosterHeader extends StatelessWidget {
  const _PosterHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final h = (w * 0.92).clamp(300.0, 420.0);
    return SizedBox(
      height: h,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: -MyExSpacing.margin,
            right: -MyExSpacing.margin,
            top: 0,
            child: DreamScene(height: h),
          ),
          Positioned(
            left: 0,
            bottom: 0,
            width: w * 0.64,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'MyEx',
                      style: MyExType.display.copyWith(fontSize: 26),
                    ),
                    const Gap(MyExSpacing.s2),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: MyExSpacing.s2,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: MyExColors.blush,
                        borderRadius: BorderRadius.circular(MyExRadii.capsule),
                      ),
                      child: Text(
                        context.l10n.paywallBrandBadge,
                        style: MyExType.caption1.copyWith(
                          color: MyExColors.onBlush,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const Gap(MyExSpacing.s3),
                PosterHeadline(title, accentWords: 2),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// "Everything in Premium": painted medallions (the user's focus, when known,
/// personalizes the line under them).
class _Includes extends StatelessWidget {
  const _Includes({this.focus});
  final String? focus;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final items = [
      (ArtKind.orb, l.paywallMedalMira),
      (ArtKind.sunrise, l.paywallMedalPlan),
      (ArtKind.rose, l.paywallMedalAnalysis),
      (ArtKind.lock, l.paywallMedalDrafts),
      (
        ArtKind.moon,
        l.paywallMedalCoins(MonetizationDisplay.premiumMonthlyBonusCoins),
      ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l.paywallIncludes, style: MyExType.headline),
        const Gap(MyExSpacing.s3),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final (k, label) in items) ...[
                LabeledMedallion(kind: k, label: label),
                const Gap(MyExSpacing.s1),
              ],
            ],
          ),
        ),
        const Gap(MyExSpacing.s2),
        Text(
          focus == null
              ? l.paywallBenefitPlanSub(MonetizationDisplay.freePlanDays)
              : l.paywallBenefitPlanSubFocus(
                  focus!,
                  MonetizationDisplay.freePlanDays,
                ),
          style: MyExType.footnote,
        ),
      ],
    );
  }
}

/// Solid dock (gradient only on its top edge so content never shows through
/// the fine print): CTA, fine print with the billed price, legal links.
class _Dock extends StatelessWidget {
  const _Dock({
    required this.copy,
    required this.selected,
    required this.busy,
    required this.onBuy,
  });

  final PaywallCopy? copy;
  final PlanPeriod selected;
  final bool busy;
  final VoidCallback? onBuy;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    final c = copy;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [MyExColors.bg, MyExColors.bg, MyExColors.bgClear],
          stops: [0, 0.7, 1],
        ),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          MyExSpacing.margin,
          MyExSpacing.s6,
          MyExSpacing.margin,
          bottom > 0 ? bottom : MyExSpacing.dockBottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (c != null) ...[
              PrimaryButton(
                key: const Key('paywall-cta'),
                label: c.cta(selected),
                busy: busy,
                onPressed: onBuy,
              ),
              // R4: removes the moment-of-tap fear (annual with trial only).
              if (selected == PlanPeriod.annual && c.showsTrial) ...[
                const Gap(MyExSpacing.s2),
                Footnote(
                  context.l10n.paywallNoPaymentToday,
                  key: const Key('no-payment-today'),
                  icon: MyExIcons.check,
                  color: MyExColors.success,
                ),
              ],
              const Gap(MyExSpacing.s1),
              SwapText(
                c.fine(selected),
                key: const Key('paywall-fine'),
                style: MyExType.footnote,
                textAlign: TextAlign.center,
              ),
            ],
            const PaywallLinks(),
          ],
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.onRetry, required this.onContinueFree});
  final VoidCallback onRetry;
  final VoidCallback onContinueFree;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return SolidCard(
      child: Column(
        children: [
          Text(
            l.paywallError,
            style: MyExType.headline,
            textAlign: TextAlign.center,
          ),
          const Gap(MyExSpacing.s4),
          PrimaryButton(label: l.commonRetry, onPressed: onRetry),
          TextLinkButton(
            label: l.commonContinueFree,
            onPressed: onContinueFree,
          ),
        ],
      ),
    );
  }
}

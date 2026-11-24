import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/analytics/analytics.dart';
import '../../../core/design/design.dart';
import '../../../core/router/app_router.dart';
import '../../../core/util/context_x.dart';
import '../application/monetization_providers.dart';
import '../domain/coin_pack.dart';
import '../domain/monetization_ids.dart';
import '../domain/paywall_offer.dart';
import '../domain/purchase_outcome.dart';

/// Coins (spec S5): packs from offering "coins" (priceString only), "Best
/// value" from offering metadata (once), "What you can unlock" from
/// coin_catalog (server prices).
class CoinsStoreScreen extends ConsumerStatefulWidget {
  const CoinsStoreScreen({super.key});

  @override
  ConsumerState<CoinsStoreScreen> createState() => _CoinsStoreScreenState();
}

class _CoinsStoreScreenState extends ConsumerState<CoinsStoreScreen> {
  String? _buying;
  bool _awaitingCredit = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => ref.read(analyticsProvider).coinsStoreView(source: 'app'),
    );
  }

  Future<void> _buy(CoinPack pack) async {
    if (_buying != null || pack.handle == null) return;
    final l = context.l10n;
    final before = ref.read(coinBalanceProvider).value ?? 0;
    setState(() => _buying = pack.productId);
    final outcome = await ref
        .read(purchasesRepositoryProvider)
        .buy(pack.handle!);
    if (!mounted) return;
    setState(() => _buying = null);
    switch (outcome) {
      case PurchaseSuccess():
        ref
            .read(analyticsProvider)
            .coinsPurchased(productId: pack.productId, coins: pack.total);
        unawaited(MyExHaptics.success());
        await _awaitCredit(before, pack.total);
      case PurchasePending():
        showMyExToast(context, l.paywallPending);
      case PurchaseFailed() || PurchaseAlreadyOwned():
        showMyExToast(context, l.paywallFailed);
      case PurchaseCancelled():
        break;
    }
  }

  /// "Adding coins…" until the wallet confirms (realtime/poll), max 20s.
  Future<void> _awaitCredit(int before, int amount) async {
    final l = context.l10n;
    setState(() => _awaitingCredit = true);
    final wallet = ref.read(walletRepositoryProvider);
    final deadline = DateTime.now().add(const Duration(seconds: 20));
    var credited = false;
    while (DateTime.now().isBefore(deadline)) {
      try {
        if (await wallet.fetchBalance() >= before + amount) {
          credited = true;
          break;
        }
      } catch (_) {}
      await Future<void>.delayed(const Duration(seconds: 2));
      if (!mounted) return;
    }
    if (!mounted) return;
    setState(() => _awaitingCredit = false);
    ref.invalidate(coinBalanceProvider);
    if (credited) {
      showMyExToast(context, l.coinsAdded(amount), success: true);
    } else {
      unawaited(wallet.syncPurchases().catchError((Object _) {}));
      showMyExToast(context, l.coinsOnTheWay);
    }
  }

  Future<void> _refresh() async {
    ref
      ..invalidate(coinPacksProvider)
      ..invalidate(coinBalanceProvider);
    await ref
        .read(coinPacksProvider.future)
        .catchError((Object _) => <CoinPack>[]);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final balance = ref.watch(coinBalanceProvider).value;
    final packs = ref.watch(coinPacksProvider);
    final catalog = ref.watch(coinCatalogProvider).value;
    final premium = ref.watch(isPremiumProvider);

    return Scaffold(
      body: ScreenBackground(
        child: LargeTitleScrollView(
          title: l.coinsTitle,
          largeTitle: false,
          bottomPadding: MyExSpacing.s8,
          onRefresh: _refresh,
          leading: GlassIconButton(
            icon: Icons.chevron_left_rounded,
            semanticLabel: l.commonBack,
            onPressed: () =>
                context.canPop() ? context.pop() : context.go(Routes.home),
          ),
          children: [
            // Balance block: left-aligned, no card.
            MergeSemantics(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const CoinIcon(size: MyExSizes.coinBalance),
                  const Gap(MyExSpacing.s3),
                  AnimatedSwitcher(
                    duration: MyExMotion.of(context).reduced
                        ? Duration.zero
                        : MyExDurations.digitRoll,
                    switchInCurve: MyExCurves.snappy,
                    child: Text(
                      balance?.toString() ?? '–',
                      key: ValueKey(balance),
                      style: MyExType.numeral(MyExType.numeralBalance),
                    ),
                  ),
                  const Gap(MyExSpacing.s2),
                  Text(l.coinsUnit(balance ?? 0), style: MyExType.footnote),
                ],
              ),
            ),
            if (_awaitingCredit)
              Footnote(
                l.coinsAdding,
                icon: Icons.hourglass_top_rounded,
                textAlign: TextAlign.start,
              ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SectionHeader(l.coinsGetHeader),
                switch (packs) {
                  AsyncData(:final value) when value.isNotEmpty => InsetGroup(
                    children: [
                      for (final p in value)
                        _packRow(context, p, busy: _buying == p.productId),
                    ],
                  ),
                  AsyncError() || AsyncData() => SolidCard(
                    child: Column(
                      children: [
                        Text(
                          l.coinsError,
                          style: MyExType.headline,
                          textAlign: TextAlign.center,
                        ),
                        const Gap(MyExSpacing.s3),
                        PrimaryButton(
                          label: l.commonRetry,
                          onPressed: _refresh,
                        ),
                      ],
                    ),
                  ),
                  _ => const SkeletonBox(height: MyExSizes.skeletonList),
                },
              ],
            ),
            if (catalog != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SectionHeader(l.coinsUnlockHeader),
                  InsetGroup(
                    children: [
                      if (catalog[MonetizationIds.itemMsgs20] case final i?)
                        _catalogRow(l.coinsItemMsgs(i.grantQty), i.cost),
                      if (catalog[MonetizationIds.itemPlanDay] case final i?)
                        _catalogRow(l.coinsItemPlanDay, i.cost),
                      if (catalog[MonetizationIds.itemAnalysis] case final i?)
                        _catalogRow(l.coinsItemAnalysis, i.cost),
                    ],
                  ),
                ],
              ),
            if (!premium)
              InsetGroup(
                children: [
                  ListRow(
                    leading: const IconSquare(
                      icon: Icons.card_giftcard_rounded,
                    ),
                    title: l.coinsCrossSell(
                      MonetizationDisplay.premiumMonthlyBonusCoins,
                    ),
                    onTap: () =>
                        context.push(Routes.paywallFor(PaywallTrigger.coins)),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  ListRow _packRow(BuildContext context, CoinPack p, {required bool busy}) {
    final l = context.l10n;
    final best = p.tag == CoinPackTag.bestValue;
    final String? sub = best
        ? (p.bonus > 0 ? l.coinsBestValueBonus(p.bonus) : l.coinsBestValue)
        : (p.bonus > 0 ? l.coinsPackBonus(p.bonus) : null);
    return ListRow(
      leading: const CoinIcon(size: MyExSizes.coinRow),
      title: l.coinsPackTitle(p.coins),
      subtitle: sub,
      subtitleColor: best ? MyExColors.accentInk : MyExColors.success,
      chevron: false,
      semanticLabel: [
        l.coinsPackTitle(p.coins),
        ?sub,
        p.priceString,
      ].join('. '),
      onTap: busy ? null : () => _buy(p),
      trailing: _GetCapsule(price: p.priceString, busy: busy),
    );
  }

  ListRow _catalogRow(String label, int cost) => ListRow(
    title: label,
    chevron: false,
    trailing: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CoinIcon(size: MyExSizes.iconSm + 2),
        const Gap(MyExSpacing.s1),
        Text(
          '$cost',
          style: MyExType.body.copyWith(
            color: MyExColors.ink2,
            fontFeatures: MyExType.tabular,
          ),
        ),
      ],
    ),
  );
}

/// App Store style "Get" capsule carrying the StoreKit price.
class _GetCapsule extends StatelessWidget {
  const _GetCapsule({required this.price, required this.busy});
  final String price;
  final bool busy;

  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(
      minWidth: MyExSizes.getCapsuleMinWidth,
      minHeight: MyExSizes.getCapsuleHeight,
    ),
    padding: const EdgeInsets.symmetric(
      horizontal: MyExSizes.getCapsulePadding,
    ),
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: MyExColors.accentSoft,
      borderRadius: BorderRadius.circular(MyExRadii.capsule),
    ),
    child: busy
        ? SizedBox.square(
            dimension: MyExSizes.iconSm,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: MyExColors.accentInk,
            ),
          )
        : Text(
            price,
            style: MyExType.subheadline.copyWith(
              color: MyExColors.accentInk,
              fontWeight: FontWeight.w600,
              fontFeatures: MyExType.tabular,
            ),
          ),
  );
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/analytics/analytics.dart';
import '../../../core/design/design.dart';
import '../../../core/util/context_x.dart';
import '../application/monetization_providers.dart';
import '../domain/coin_pack.dart';
import '../domain/limits.dart';
import '../domain/monetization_ids.dart';
import 'paywall_copy.dart';

enum LockDayResult { premium, unlocked, getCoins }

/// Locked plan day (spec S10): Premium (best value) or one day for coins.
/// The server (spend_coins + can_access_plan_day) decides; this only asks.
Future<LockDayResult?> showLockDaySheet({
  required BuildContext context,
  required int day,
  required String title,
  required int minutes,
}) {
  return showGlassSheet<LockDayResult>(
    context: context,
    semanticLabel: context.l10n.lockDaySheetLabel,
    builder: (_) => _LockDayBody(day: day, title: title, minutes: minutes),
  );
}

class _LockDayBody extends ConsumerStatefulWidget {
  const _LockDayBody({
    required this.day,
    required this.title,
    required this.minutes,
  });

  final int day;
  final String title;
  final int minutes;

  @override
  ConsumerState<_LockDayBody> createState() => _LockDayBodyState();
}

class _LockDayBodyState extends ConsumerState<_LockDayBody> {
  /// One idempotency key per user intent: double taps spend once.
  final _key = const Uuid().v4();
  bool _busy = false;

  Future<void> _spend() async {
    if (_busy) return;
    setState(() => _busy = true);
    final l = context.l10n;
    try {
      final res = await ref
          .read(walletRepositoryProvider)
          .spend(
            item: MonetizationIds.itemPlanDay,
            ref: '${widget.day}',
            idempotencyKey: _key,
          );
      if (!mounted) return;
      invalidateMonetization(ref);
      switch (res) {
        case SpendOk(:final balance):
          ref
              .read(analyticsProvider)
              .coinsSpent(
                item: MonetizationIds.itemPlanDay,
                balanceAfter: balance,
              );
          Navigator.of(context).pop(LockDayResult.unlocked);
        case SpendAlreadyUnlocked() || SpendPremiumHasAccess():
          Navigator.of(context).pop(LockDayResult.unlocked);
        case SpendInsufficient():
          Navigator.of(context).pop(LockDayResult.getCoins);
        case SpendRejected():
          showMyExToast(context, l.paywallFailed);
      }
    } catch (_) {
      if (mounted) showMyExToast(context, l.paywallFailed);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final balance = ref.watch(coinBalanceProvider).value ?? 0;
    final item = ref
        .watch(coinCatalogProvider)
        .value?[MonetizationIds.itemPlanDay];
    final offer = ref.watch(paywallOfferProvider).value;
    final trialDays = offer == null
        ? null
        : PaywallCopy(offer: offer, l10n: l).trialDays;
    final affordable =
        item != null && canAfford(balance: balance, cost: item.cost);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Footnote(
          l.lockDayFoot(widget.day, widget.minutes),
          textAlign: TextAlign.start,
        ),
        const Gap(MyExSpacing.s1),
        Text(
          widget.title,
          style: MyExType.sheetTitle,
          textAlign: TextAlign.center,
        ),
        const Gap(MyExSpacing.s1),
        Text(
          l.lockDayBody(MonetizationDisplay.freePlanDays),
          style: MyExType.subheadline,
        ),
        const Gap(MyExSpacing.s6),
        PrimaryButton(
          label: l.lockDayPremium,
          onPressed: () => Navigator.of(context).pop(LockDayResult.premium),
        ),
        if (trialDays != null) ...[
          const Gap(MyExSpacing.s1),
          Footnote(l.lockDayTrialNote(trialDays)),
        ],
        const Gap(MyExSpacing.s3),
        if (affordable)
          GlassButton(
            key: const Key('lock-day-coins'),
            label: l.lockDayCoins(widget.day, item.cost),
            leading: const CoinIcon(),
            busy: _busy,
            onPressed: _spend,
          )
        else
          GlassButton(
            label: l.lockDayGetCoins(widget.day),
            leading: const CoinIcon(),
            onPressed: () => Navigator.of(context).pop(LockDayResult.getCoins),
          ),
      ],
    );
  }
}

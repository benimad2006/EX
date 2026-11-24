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

enum LimitSheetResult { premium, coinsSpent, getCoins, wait, sos }

/// Soft limit for Mira (normal chats only — NEVER shown for SOS chats).
/// Three honest options: Premium / coins / wait, plus an always-free SOS link.
Future<LimitSheetResult?> showLimitSheet({
  required BuildContext context,
  DateTime? resetsAt,
}) {
  return showGlassSheet<LimitSheetResult>(
    context: context,
    semanticLabel: context.l10n.limitSheetLabel,
    builder: (_) => _LimitSheetBody(resetsAt: resetsAt),
  );
}

class _LimitSheetBody extends ConsumerStatefulWidget {
  const _LimitSheetBody({this.resetsAt});
  final DateTime? resetsAt;

  @override
  ConsumerState<_LimitSheetBody> createState() => _LimitSheetBodyState();
}

class _LimitSheetBodyState extends ConsumerState<_LimitSheetBody> {
  /// One idempotency key per user intent: retries/double taps spend once.
  final _spendKey = const Uuid().v4();
  bool _busy = false;

  Future<void> _spend() async {
    if (_busy) return;
    setState(() => _busy = true);
    final l = context.l10n;
    try {
      final res = await ref
          .read(walletRepositoryProvider)
          .spend(
            item: MonetizationIds.itemMsgs20,
            ref: 'coach',
            idempotencyKey: _spendKey,
          );
      if (!mounted) return;
      invalidateMonetization(ref);
      switch (res) {
        case SpendOk(:final balance):
          ref
              .read(analyticsProvider)
              .coinsSpent(
                item: MonetizationIds.itemMsgs20,
                balanceAfter: balance,
              );
          Navigator.of(context).pop(LimitSheetResult.coinsSpent);
        case SpendInsufficient():
          Navigator.of(context).pop(LimitSheetResult.getCoins);
        case SpendPremiumHasAccess() || SpendAlreadyUnlocked():
          Navigator.of(context).pop(LimitSheetResult.coinsSpent);
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
    final msgsItem = ref
        .watch(coinCatalogProvider)
        .value?[MonetizationIds.itemMsgs20];
    final offer = ref.watch(paywallOfferProvider).value;
    final trialDays = offer == null
        ? null
        : PaywallCopy(offer: offer, l10n: l).trialDays;
    final affordable =
        msgsItem != null && canAfford(balance: balance, cost: msgsItem.cost);
    final resetsAt = widget.resetsAt;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const MiraOrb(size: MyExSizes.miraSheet),
            const Gap(MyExSpacing.s3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.limitTitle, style: MyExType.sheetTitle),
                  Text(
                    l.limitBody(MonetizationDisplay.freeMessagesPerDay),
                    style: MyExType.subheadline,
                  ),
                ],
              ),
            ),
          ],
        ),
        const Gap(MyExSpacing.s6),
        PrimaryButton(
          label: l.limitPremium,
          onPressed: () => Navigator.of(context).pop(LimitSheetResult.premium),
        ),
        if (trialDays != null) ...[
          const Gap(MyExSpacing.s1),
          Footnote(l.limitPremiumTrialNote(trialDays)),
        ],
        const Gap(MyExSpacing.s3),
        if (affordable)
          GlassButton(
            label: l.limitCoins(msgsItem.grantQty, msgsItem.cost),
            leading: const CoinIcon(),
            busy: _busy,
            onPressed: _spend,
          )
        else
          GlassButton(
            label: l.limitGetCoins,
            leading: const CoinIcon(),
            onPressed: () =>
                Navigator.of(context).pop(LimitSheetResult.getCoins),
          ),
        if (resetsAt != null)
          TextLinkButton(
            label: l.limitWait(context.timeOfDay(resetsAt)),
            onPressed: () => Navigator.of(context).pop(LimitSheetResult.wait),
          ),
        TextLinkButton(
          label: l.limitSos,
          small: true,
          onPressed: () => Navigator.of(context).pop(LimitSheetResult.sos),
        ),
      ],
    );
  }
}

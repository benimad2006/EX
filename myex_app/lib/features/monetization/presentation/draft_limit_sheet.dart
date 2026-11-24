import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/design.dart';
import '../../../core/util/context_x.dart';
import '../application/monetization_providers.dart';
import 'paywall_copy.dart';

enum DraftLimitResult { premium, wait, sos }

/// Free Draft Jail limit (1/day). NEVER shown for drafts started from SOS:
/// the server doesn't limit them and the screen never calls this for SOS.
Future<DraftLimitResult?> showDraftLimitSheet({
  required BuildContext context,
  DateTime? resetsAt,
}) {
  return showGlassSheet<DraftLimitResult>(
    context: context,
    semanticLabel: context.l10n.draftLimitSheetLabel,
    builder: (_) => _Body(resetsAt: resetsAt),
  );
}

class _Body extends ConsumerWidget {
  const _Body({this.resetsAt});
  final DateTime? resetsAt;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final offer = ref.watch(paywallOfferProvider).value;
    final trialDays = offer == null
        ? null
        : PaywallCopy(offer: offer, l10n: l).trialDays;
    return Column(
      key: const Key('draft-limit-sheet'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l.draftLimitTitle,
          style: MyExType.sheetTitle,
          textAlign: TextAlign.center,
        ),
        const Gap(MyExSpacing.s1),
        Text(l.draftLimitBody, style: MyExType.subheadline),
        const Gap(MyExSpacing.s6),
        PrimaryButton(
          label: l.draftLimitPremium,
          onPressed: () => Navigator.of(context).pop(DraftLimitResult.premium),
        ),
        if (trialDays != null) ...[
          const Gap(MyExSpacing.s1),
          Footnote(l.limitPremiumTrialNote(trialDays)),
        ],
        if (resetsAt != null)
          TextLinkButton(
            label: l.limitWait(context.timeOfDay(resetsAt!)),
            onPressed: () => Navigator.of(context).pop(DraftLimitResult.wait),
          ),
        TextLinkButton(
          label: l.limitSos,
          small: true,
          onPressed: () => Navigator.of(context).pop(DraftLimitResult.sos),
        ),
      ],
    );
  }
}

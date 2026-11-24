import 'package:flutter/material.dart';

import '../../../../core/design/design.dart';
import '../../../../core/util/context_x.dart';
import '../../domain/monetization_ids.dart';

/// Free vs Premium table (paywall variant "compare"). Sentence-case headers,
/// one soft-accent column highlight for Premium.
class CompareTable extends StatelessWidget {
  const CompareTable({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    // null free/premium value = icon cell (✓ for premium, — for free).
    final rows = <(String, String?, String?)>[
      (
        l.compareRowPlan,
        l.compareRowPlanFree(MonetizationDisplay.freePlanDays),
        l.compareRowPlanPremium,
      ),
      (
        l.compareRowMira,
        l.compareRowMiraFree(MonetizationDisplay.freeMessagesPerDay),
        l.compareUnlimited,
      ),
      (l.compareRowSos, l.compareIncluded, null), // free for everyone
      (
        l.compareRowDraft,
        l.compareRowDraftFree(MonetizationDisplay.freeDraftsPerDay),
        l.compareUnlimited,
      ),
      (
        l.compareRowAnalysis,
        l.compareRowAnalysisFree,
        l.compareRowAnalysisPremium,
      ),
      (
        l.compareRowCoins,
        null,
        l.compareRowCoinsPremium(MonetizationDisplay.premiumMonthlyBonusCoins),
      ),
    ];
    final header = MyExType.footnote.copyWith(fontWeight: FontWeight.w600);
    final cell = MyExType.subheadline.copyWith(color: MyExColors.ink);
    return SolidCard(
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(1.5),
          1: FlexColumnWidth(),
          2: FlexColumnWidth(),
        },
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: [
          TableRow(
            children: [
              _cell(Text(l.compareHeader, style: header)),
              _cell(
                Text(l.compareFree, style: header, textAlign: TextAlign.center),
              ),
              _premium(
                Text(
                  l.comparePremium,
                  style: header.copyWith(color: MyExColors.accentInk),
                  textAlign: TextAlign.center,
                ),
                top: true,
              ),
            ],
          ),
          for (var i = 0; i < rows.length; i++)
            TableRow(
              children: [
                _cell(Text(rows[i].$1, style: cell)),
                _cell(
                  rows[i].$2 == null
                      ? Semantics(
                          label: l.compareNotIncluded,
                          child: Text(
                            '—',
                            textAlign: TextAlign.center,
                            style: cell.copyWith(color: MyExColors.ink3),
                          ),
                        )
                      : Text(
                          rows[i].$2!,
                          style: cell.copyWith(color: MyExColors.ink2),
                          textAlign: TextAlign.center,
                        ),
                ),
                _premium(
                  rows[i].$3 == null
                      ? Semantics(
                          label: l.compareIncluded,
                          child: Icon(
                            MyExIcons.check,
                            color: MyExColors.accent,
                            size: MyExSizes.icon,
                          ),
                        )
                      : Text(
                          rows[i].$3!,
                          style: cell,
                          textAlign: TextAlign.center,
                        ),
                  bottom: i == rows.length - 1,
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _cell(Widget child) => Padding(
    padding: const EdgeInsets.symmetric(
      vertical: MyExSpacing.s2 + 2,
      horizontal: MyExSpacing.s1,
    ),
    child: child,
  );

  Widget _premium(Widget child, {bool top = false, bool bottom = false}) =>
      DecoratedBox(
        decoration: BoxDecoration(
          color: MyExColors.accentSoft,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(top ? MyExRadii.s : 0),
            bottom: Radius.circular(bottom ? MyExRadii.s : 0),
          ),
        ),
        child: _cell(Center(child: child)),
      );
}

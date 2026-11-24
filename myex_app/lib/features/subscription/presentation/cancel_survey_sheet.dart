import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/design/design.dart';
import '../../../core/util/context_x.dart';
import '../../monetization/domain/price_format.dart';
import '../data/subscription_repository.dart';
import '../domain/cancel_survey.dart';

/// Everything the survey needs, injected so it is testable without stores.
class CancelSurveyDeps {
  const CancelSurveyDeps({
    required this.productId,
    required this.log,
    required this.openManage,
    this.save50PriceString,
    this.yearlySavingsPct,
    this.yearlyPriceString,
    this.keepWithSave50,
    this.switchToYearly,
    this.enableCheckin,
  });

  final String? productId;
  final CancelSurveyLog log;

  /// Always available: App Store subscription management.
  final Future<void> Function() openManage;

  /// StoreKit price of "save50_annual" (null = promo not available).
  final String? save50PriceString;
  final int? yearlySavingsPct;
  final String? yearlyPriceString;

  /// Return true when the purchase succeeded.
  final Future<bool> Function()? keepWithSave50;
  final Future<bool> Function()? switchToYearly;

  /// Return true when the nightly check-in was scheduled.
  final Future<bool> Function()? enableCheckin;
}

/// M8 cancel survey: one optional question. "Continue to Cancel" is visible
/// from the first frame and ALWAYS opens App Store management, with or
/// without a reason. Never asks for a reason before showing the exit.
Future<void> showCancelSurvey(BuildContext context, CancelSurveyDeps deps) {
  return showGlassSheet<void>(
    context: context,
    semanticLabel: context.l10n.cancelSheetLabel,
    builder: (_) => CancelSurveyBody(deps: deps),
  );
}

class CancelSurveyBody extends StatefulWidget {
  const CancelSurveyBody({super.key, required this.deps});
  final CancelSurveyDeps deps;

  @override
  State<CancelSurveyBody> createState() => _CancelSurveyBodyState();
}

class _CancelSurveyBodyState extends State<CancelSurveyBody> {
  CancelReason? _reason;
  bool _busy = false;
  final _note = TextEditingController();

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  CancelOffer? get _offer => _reason == null
      ? null
      : CancelSurvey.offerFor(
          _reason!,
          productId: widget.deps.productId,
          save50Available:
              widget.deps.save50PriceString != null &&
              widget.deps.keepWithSave50 != null,
          yearlySavingsPct: widget.deps.switchToYearly == null
              ? null
              : widget.deps.yearlySavingsPct,
        );

  Future<void> _continueToCancel() async {
    final r = _reason;
    if (r != null) {
      // Fire and forget: logging never delays or blocks the exit.
      unawaited(
        widget.deps.log.record(
          reason: r,
          offerShown: _offer?.wire,
          note: r == CancelReason.other ? _note.text : null,
        ),
      );
    }
    await widget.deps.openManage();
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _accept(Future<bool> Function() action) async {
    if (_busy) return;
    setState(() => _busy = true);
    final ok = await action();
    if (!mounted) return;
    setState(() => _busy = false);
    if (ok) {
      await widget.deps.log.record(
        reason: _reason!,
        offerShown: _offer?.wire,
        offerAccepted: true,
      );
      if (!mounted) return;
      showMyExToast(context, context.l10n.cancelKept, success: true);
      Navigator.of(context).pop();
    }
  }

  Future<void> _checkin() async {
    final l = context.l10n;
    final enable = widget.deps.enableCheckin;
    if (enable == null || _busy) return;
    setState(() => _busy = true);
    final ok = await enable();
    if (!mounted) return;
    setState(() => _busy = false);
    await widget.deps.log.record(
      reason: CancelReason.unused,
      offerShown: const CheckinOffer().wire,
      offerAccepted: ok,
    );
    if (!mounted) return;
    showMyExToast(context, ok ? l.cancelCheckinOn : l.cancelCheckinDenied);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final reasons = {
      CancelReason.price: l.cancelReasonPrice,
      CancelReason.better: l.cancelReasonBetter,
      CancelReason.unused: l.cancelReasonUnused,
      CancelReason.other: l.cancelReasonOther,
    };
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l.cancelTitle,
          style: MyExType.sheetTitle,
          textAlign: TextAlign.center,
        ),
        Text(l.cancelSub, style: MyExType.subheadline),
        const Gap(MyExSpacing.s4),
        InsetGroup(
          children: [
            for (final e in reasons.entries)
              SelectRow(
                key: Key('cancel-${e.key.name}'),
                title: e.value,
                selected: _reason == e.key,
                onTap: () => setState(() => _reason = e.key),
              ),
          ],
        ),
        if (_offer != null) ...[
          const Gap(MyExSpacing.s4),
          _answer(context, _offer!),
        ],
        const Gap(MyExSpacing.s2),
        TextLinkButton(
          key: const Key('cancel-continue'),
          label: l.cancelContinue,
          tone: TextLinkTone.danger,
          onPressed: _continueToCancel,
        ),
      ],
    );
  }

  Widget _answer(BuildContext context, CancelOffer offer) {
    final l = context.l10n;
    final d = widget.deps;
    return switch (offer) {
      Save50Offer() => SolidCard(
        key: const Key('cancel-offer-save50'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l.cancelPriceTitle(d.save50PriceString!),
              style: MyExType.headline,
            ),
            Text(l.cancelPriceBody, style: MyExType.subheadline),
            const Gap(MyExSpacing.s3),
            PrimaryButton(
              label: l.cancelPriceCta,
              busy: _busy,
              onPressed: () => _accept(d.keepWithSave50!),
            ),
          ],
        ),
      ),
      SwitchToYearlyOffer(:final savingsPct) => SolidCard(
        key: const Key('cancel-offer-yearly'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l.cancelSwitchTitle(
                PriceFormat(l.localeName).percent(savingsPct),
              ),
              style: MyExType.headline,
            ),
            if (d.yearlyPriceString != null)
              Text(
                l.cancelSwitchBody(d.yearlyPriceString!),
                style: MyExType.subheadline,
              ),
            const Gap(MyExSpacing.s3),
            PrimaryButton(
              label: l.cancelSwitchCta,
              busy: _busy,
              onPressed: () => _accept(d.switchToYearly!),
            ),
          ],
        ),
      ),
      CheckinOffer() => SolidCard(
        key: const Key('cancel-offer-checkin'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l.cancelUnusedTitle, style: MyExType.headline),
            Text(l.cancelUnusedBody, style: MyExType.subheadline),
            const Gap(MyExSpacing.s3),
            GlassButton(
              label: l.cancelUnusedCta,
              busy: _busy,
              onPressed: d.enableCheckin == null ? null : _checkin,
            ),
          ],
        ),
      ),
      CelebrateNoOffer() => SolidCard(
        key: const Key('cancel-better'),
        child: Text(l.cancelBetter, style: MyExType.body),
      ),
      ThanksNoOffer() => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l.cancelOther, style: MyExType.subheadline),
          if (_reason == CancelReason.other) ...[
            const Gap(MyExSpacing.s3),
            InsetTextField(
              label: l.cancelNoteLabel,
              controller: _note,
              maxLength: 500,
              maxLines: 4,
            ),
          ],
        ],
      ),
    };
  }
}

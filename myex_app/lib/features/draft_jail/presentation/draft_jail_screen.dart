import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/analytics/analytics.dart';
import '../../../core/design/design.dart';
import '../../../core/router/app_router.dart';
import '../../../core/util/context_x.dart';
import '../../coach/domain/chat_origin.dart';
import '../../monetization/domain/paywall_offer.dart';
import '../../monetization/presentation/draft_limit_sheet.dart';
import '../data/draft_repository.dart';
import '../domain/draft.dart';

/// Draft Jail: write it here instead of sending it; it stays locked for 24h.
/// From SOS ([ChatOrigin.sos]) it is never limited and never shows an upsell
/// (HARD RULE 1): the server bypasses the quota and this screen never opens the
/// limit sheet for SOS (see [draftUiAction]).
class DraftJailScreen extends ConsumerStatefulWidget {
  const DraftJailScreen({super.key, required this.origin});
  final ChatOrigin origin;

  @override
  ConsumerState<DraftJailScreen> createState() => _DraftJailScreenState();
}

class _DraftJailScreenState extends ConsumerState<DraftJailScreen> {
  static const _maxChars = 4000;
  final _text = TextEditingController();
  bool _busy = false;
  late DateTime _now = DateTime.now();
  Timer? _tick;

  @override
  void initState() {
    super.initState();
    // Live countdown, one rebuild per second.
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    _text.dispose();
    super.dispose();
  }

  Future<void> _lock() async {
    final body = _text.text.trim();
    if (_busy || body.isEmpty) return;
    setState(() => _busy = true);
    final l = context.l10n;
    LockOutcome outcome;
    try {
      outcome = await ref
          .read(draftRepositoryProvider)
          .lock(body, widget.origin);
    } catch (_) {
      outcome = const DraftLockFailed('network');
    }
    if (!mounted) return;
    setState(() => _busy = false);
    switch (draftUiAction(outcome, widget.origin)) {
      case DraftUiAction.locked:
        ref.read(analyticsProvider).draftLocked(origin: widget.origin.wire);
        _text.clear();
        unawaited(MyExHaptics.success());
        ref.invalidate(draftsProvider);
        showMyExToast(context, l.draftLockedToast, success: true);
      case DraftUiAction.showLimitSheet:
        final resets = outcome is DraftLimitReached ? outcome.resetsAt : null;
        final r = await showDraftLimitSheet(context: context, resetsAt: resets);
        if (!mounted || r == null) return;
        switch (r) {
          case DraftLimitResult.premium:
            unawaited(context.push(Routes.paywallFor(PaywallTrigger.deepLink)));
          case DraftLimitResult.sos:
            unawaited(context.push(Routes.sosFrom('draft_limit')));
          case DraftLimitResult.wait:
            break;
        }
      case DraftUiAction.showError:
        showMyExToast(context, l.draftError);
    }
  }

  Future<void> _openDraft(LockedDraft d) async {
    final l = context.l10n;
    final locked = d.isLocked(DateTime.now());
    var revealed = !locked && d.releasedAt != null;
    await showGlassSheet<void>(
      context: context,
      semanticLabel: l.draftSheetLabel,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              locked ? l.draftLockedRow : l.draftReadyRow,
              style: MyExType.title2,
            ),
            const Gap(MyExSpacing.s1),
            Text(
              locked
                  ? l.draftUnlocksIn(
                      formatCountdown(d.remaining(DateTime.now())),
                    )
                  : l.draftWords(d.wordCount),
              style: MyExType.subheadline,
            ),
            const Gap(MyExSpacing.s4),
            if (revealed) ...[
              SolidCard(child: SelectableText(d.body, style: MyExType.body)),
              const Gap(MyExSpacing.s3),
              GlassButton(
                label: l.draftCopy,
                icon: Icons.copy_rounded,
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: d.body));
                  if (ctx.mounted) showMyExToast(ctx, l.draftCopied);
                },
              ),
            ] else if (!locked)
              PrimaryButton(
                key: const Key('draft-unlock'),
                label: l.draftUnlock,
                onPressed: () async {
                  final ok = await ref
                      .read(draftRepositoryProvider)
                      .release(d.id);
                  if (!ctx.mounted) return;
                  if (ok) {
                    setSheet(() => revealed = true);
                    ref.invalidate(draftsProvider);
                  } else {
                    showMyExToast(ctx, l.draftStillLocked);
                  }
                },
              ),
            TextLinkButton(
              key: const Key('draft-delete'),
              label: l.draftDelete,
              tone: TextLinkTone.danger,
              onPressed: () async {
                final yes = await showConfirmDialog(
                  context: ctx,
                  title: l.draftDeleteTitle,
                  message: l.draftDeleteBody,
                  confirmLabel: l.draftDelete,
                  cancelLabel: l.commonCancel,
                );
                if (!yes) return;
                await ref.read(draftRepositoryProvider).delete(d.id);
                ref.invalidate(draftsProvider);
                if (ctx.mounted) Navigator.of(ctx).pop();
                if (mounted) showMyExToast(context, l.draftDeleted);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final drafts = ref.watch(draftsProvider);
    final list = drafts.value ?? const <LockedDraft>[];
    final locked = [
      for (final d in list)
        if (d.isLocked(_now)) d,
    ];
    final ready = [
      for (final d in list)
        if (!d.isLocked(_now)) d,
    ];

    return Scaffold(
      body: ScreenBackground(
        child: LargeTitleScrollView(
          title: l.draftTitle,
          largeTitle: false,
          bottomPadding: MyExSpacing.s8,
          leading: GlassIconButton(
            icon: Icons.chevron_left_rounded,
            semanticLabel: l.commonBack,
            onPressed: () => context.canPop()
                ? context.pop()
                : context.go(
                    widget.origin == ChatOrigin.sos ? Routes.sos : Routes.home,
                  ),
          ),
          children: [
            Text(l.draftSub, style: MyExType.subheadline),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                InsetTextField(
                  key: const Key('draft-input'),
                  label: l.draftFieldLabel,
                  hint: l.draftHint,
                  controller: _text,
                  maxLength: _maxChars,
                  minLines: 4,
                  maxLines: 10,
                ),
                const Gap(MyExSpacing.s3),
                ListenableBuilder(
                  listenable: _text,
                  builder: (context, _) => PrimaryButton(
                    key: const Key('draft-lock'),
                    label: l.draftLock,
                    icon: Icons.lock_outline_rounded,
                    busy: _busy,
                    onPressed: _text.text.trim().isEmpty ? null : _lock,
                  ),
                ),
              ],
            ),
            if (drafts.hasError && list.isEmpty)
              Footnote(l.draftListError)
            else if (list.isEmpty && drafts.hasValue)
              Padding(
                padding: const EdgeInsets.only(top: MyExSpacing.s6),
                child: Column(
                  children: [
                    const PetalMark(size: 44),
                    const Gap(MyExSpacing.s3),
                    Text(
                      l.draftJailEmptyTitle,
                      textAlign: TextAlign.center,
                      style: MyExType.headline,
                    ),
                    const Gap(MyExSpacing.s1),
                    Text(
                      l.draftJailEmptyBody,
                      textAlign: TextAlign.center,
                      style: MyExType.subheadline,
                    ),
                  ],
                ),
              ),
            if (locked.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SectionHeader(l.draftLockedHeader),
                  InsetGroup(
                    children: [
                      for (final d in locked)
                        ListRow(
                          key: Key('draft-${d.id}'),
                          leading: const IconSquare(
                            icon: Icons.lock_outline_rounded,
                            tone: IconTone.neutral,
                          ),
                          title: l.draftLockedRow,
                          subtitle: l.draftUnlocksIn(
                            formatCountdown(d.remaining(_now)),
                          ),
                          value: l.draftWords(d.wordCount),
                          onTap: () => _openDraft(d),
                        ),
                    ],
                  ),
                ],
              ),
            if (ready.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SectionHeader(l.draftReadyHeader),
                  InsetGroup(
                    children: [
                      for (final d in ready)
                        ListRow(
                          key: Key('draft-${d.id}'),
                          leading: const IconSquare(
                            icon: Icons.lock_open_rounded,
                          ),
                          title: l.draftReadyRow,
                          subtitle: context.shortDate(d.createdAt),
                          value: l.draftWords(d.wordCount),
                          onTap: () => _openDraft(d),
                        ),
                    ],
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

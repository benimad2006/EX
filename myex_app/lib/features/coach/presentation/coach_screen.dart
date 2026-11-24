import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/analytics/analytics.dart';
import '../../../core/design/design.dart';
import '../../../core/router/app_router.dart';
import '../../../core/util/context_x.dart';
import '../../monetization/application/monetization_providers.dart';
import '../../monetization/domain/limits.dart';
import '../../monetization/domain/monetization_ids.dart';
import '../../monetization/domain/paywall_offer.dart';
import '../../monetization/presentation/limit_sheet.dart';
import '../application/coach_controller.dart';
import '../domain/chat_message.dart';
import '../domain/chat_origin.dart';

/// Mira chat. For [ChatOrigin.sos] this screen shows NO meter, NO limit sheet,
/// NO paywall/coin/premium element (M0 hard rule 1); the server never counts
/// SOS messages either.
class CoachScreen extends ConsumerStatefulWidget {
  const CoachScreen({super.key, required this.origin});
  final ChatOrigin origin;

  @override
  ConsumerState<CoachScreen> createState() => _CoachScreenState();
}

class _CoachScreenState extends ConsumerState<CoachScreen> {
  final _composer = TextEditingController();

  bool get _isSos => widget.origin == ChatOrigin.sos;

  @override
  void dispose() {
    _composer.dispose();
    super.dispose();
  }

  Future<void> _newConversation() async {
    final l = context.l10n;
    final ok = await showConfirmDialog(
      context: context,
      title: l.coachNewTitle,
      message: l.coachNewBody,
      confirmLabel: l.coachNewConfirm,
      cancelLabel: l.commonCancel,
      destructive: false,
    );
    if (!ok || !mounted) return;
    await ref.read(coachControllerProvider(widget.origin).notifier).startNew();
  }

  Future<void> _sendSuggestion(String text) async {
    _composer.text = text;
    await _send();
  }

  Future<void> _send() async {
    final provider = coachControllerProvider(widget.origin);
    final result = await ref.read(provider.notifier).send(_composer.text);
    if (!mounted) return;
    switch (result) {
      case CoachSendResult.sent:
        _composer.clear();
        if (!_isSos) ref.invalidate(limitsProvider);
      case CoachSendResult.limitReached when !_isSos:
        ref
            .read(analyticsProvider)
            .limitHit(
              kind: 'message',
              freeUsed: MonetizationDisplay.freeMessagesPerDay,
            );
        await _openLimitSheet(ref.read(provider).limitResetsAt);
      case CoachSendResult.limitReached || CoachSendResult.failed:
        // Text stays in the composer; never lost.
        showMyExToast(context, context.l10n.coachError);
    }
  }

  Future<void> _openLimitSheet(DateTime? resetsAt) async {
    ref.invalidate(limitsProvider);
    final r = await showLimitSheet(context: context, resetsAt: resetsAt);
    if (!mounted || r == null) return;
    ref
        .read(analyticsProvider)
        .limitSheetAction(kind: 'message', action: r.name);
    switch (r) {
      case LimitSheetResult.premium:
        unawaited(context.push(Routes.paywallFor(PaywallTrigger.coachLimit)));
      case LimitSheetResult.coinsSpent:
        final qty = ref
            .read(coinCatalogProvider)
            .value?[MonetizationIds.itemMsgs20]
            ?.grantQty;
        if (qty != null) {
          showMyExToast(context, context.l10n.limitCreditsAdded(qty));
        }
        await _send(); // the kept message goes out now
      case LimitSheetResult.getCoins:
        unawaited(context.push(Routes.coins));
      case LimitSheetResult.sos:
        unawaited(context.push(Routes.sosFrom('limit_sheet')));
      case LimitSheetResult.wait:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final state = ref.watch(coachControllerProvider(widget.origin));
    final meter = MeterState.derive(
      origin: widget.origin,
      limits: _isSos ? null : ref.watch(limitsProvider).value,
    );
    final messages = [
      ChatMessage(role: ChatRole.assistant, content: l.coachGreeting),
      ...state.messages,
    ];
    final top = MediaQuery.paddingOf(context).top;
    // Tab screens leave room for the floating tab bar; SOS chat has none.
    final bottomInset = _isSos
        ? MediaQuery.paddingOf(context).bottom + MyExSpacing.s2
        : MyExSizes.tabBarHeight +
              MyExSpacing.tabBarInset +
              MediaQuery.paddingOf(context).bottom +
              MyExSpacing.s2;

    return Scaffold(
      backgroundColor: MyExColors.bg,
      body: ScreenBackground(
        child: Stack(
          children: [
            // Empty conversation: a quiet night scene behind the greeting.
            if (state.messages.isEmpty)
              Positioned(
                left: 0,
                right: 0,
                top: top + MyExSizes.navBarHeight + MyExSpacing.s6,
                height: 260,
                child: const ExcludeSemantics(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned.fill(
                        child: StarField(count: 30, seed: 13, twinkle: true),
                      ),
                      CrescentMoon(size: 150),
                    ],
                  ),
                ),
              ),
            Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    reverse: true,
                    padding: EdgeInsets.fromLTRB(
                      MyExSpacing.margin,
                      MyExSpacing.s4,
                      MyExSpacing.margin,
                      top + MyExSizes.navBarHeight + MyExSpacing.s4,
                    ),
                    itemCount: messages.length + (state.sending ? 1 : 0),
                    separatorBuilder: (_, _) => const Gap(MyExSpacing.s2 + 2),
                    itemBuilder: (context, i) {
                      if (state.sending && i == 0) {
                        return Semantics(
                          label: l.coachTyping,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: SizedBox(
                              width: MyExSizes.iconLg,
                              height: MyExSizes.iconLg,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: MyExColors.ink3,
                              ),
                            ),
                          ),
                        );
                      }
                      final m =
                          messages[messages.length -
                              1 -
                              (i - (state.sending ? 1 : 0))];
                      return ChatBubble(
                        text: m.content,
                        fromUser: m.role == ChatRole.user,
                      );
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    MyExSpacing.margin,
                    0,
                    MyExSpacing.margin,
                    bottomInset,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (state.messages.isEmpty && !state.sending)
                        _Suggestions(
                          onPick: _sendSuggestion,
                          prompts: [
                            l.coachSuggest1,
                            l.coachSuggest2,
                            l.coachSuggest3,
                            l.coachSuggest4,
                          ],
                        ),
                      if (meter.sosMode)
                        GlassChip(
                          key: const Key('sos-mode-banner'),
                          label: l.coachSosMode,
                          foreground: MyExColors.success,
                          leading: const Icon(Icons.shield_outlined),
                        )
                      else if (meter.visible)
                        _Meter(meter: meter),
                      const Gap(MyExSpacing.s2),
                      _Composer(
                        controller: _composer,
                        sending: state.sending,
                        onSend: _send,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // iMessage-style header: centered orb + name, edge effect always on.
            NavBar(
              showEdge: true,
              leading: _isSos
                  ? GlassIconButton(
                      icon: Icons.chevron_left_rounded,
                      semanticLabel: l.commonBack,
                      onPressed: () => context.canPop()
                          ? context.pop()
                          : context.go(Routes.sos),
                    )
                  : null,
              center: Semantics(
                header: true,
                label: '${l.coachTitle}, ${l.coachAiLabel}',
                excludeSemantics: true,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    MiraOrb(thinking: state.sending),
                    const SizedBox(height: MyExSpacing.tight),
                    Text.rich(
                      TextSpan(
                        text: l.coachTitle,
                        children: [
                          TextSpan(
                            text: ' · ${l.coachAiLabel}',
                            style: MyExType.caption2.copyWith(
                              color: MyExColors.ink2,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                      style: MyExType.caption2,
                    ),
                  ],
                ),
              ),
              trailing: !_isSos && state.messages.isNotEmpty
                  ? GlassIconButton(
                      key: const Key('coach-new'),
                      icon: Icons.add_comment_outlined,
                      semanticLabel: l.coachNew,
                      onPressed: _newConversation,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

/// Starter prompts while the conversation is empty (one tap sends).
class _Suggestions extends StatelessWidget {
  const _Suggestions({required this.prompts, required this.onPick});
  final List<String> prompts;
  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: MyExSpacing.s3),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: MyExSpacing.s1),
          child: Text(context.l10n.coachSuggestTitle, style: MyExType.footnote),
        ),
        Wrap(
          spacing: MyExSpacing.s2,
          children: [
            for (final p in prompts)
              WordChip(label: p, selected: false, onTap: () => onPick(p)),
          ],
        ),
      ],
    ),
  );
}

class _Meter extends StatelessWidget {
  const _Meter({required this.meter});
  final MeterState meter;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return GlassSurface(
      key: const Key('coach-meter'),
      radius: MyExRadii.capsule,
      padding: const EdgeInsets.only(left: MyExSpacing.s4),
      child: Row(
        children: [
          MeterDots(total: meter.total, filled: meter.filled),
          const Gap(MyExSpacing.s2),
          Expanded(
            child: Text(
              l.coachMeter(meter.filled),
              style: MyExType.footnote.copyWith(
                color: MyExColors.ink,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextLinkButton(
            label: l.coachGetMore,
            small: true,
            semibold: true,
            onPressed: () =>
                context.push(Routes.paywallFor(PaywallTrigger.coachLimit)),
          ),
        ],
      ),
    );
  }
}

/// iOS 26 Messages composer: the send button appears only with text.
class _Composer extends StatelessWidget {
  const _Composer({
    required this.controller,
    required this.sending,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool sending;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final m = MyExMotion.of(context);
    return GlassSurface(
      padding: const EdgeInsets.fromLTRB(
        MyExSpacing.s4,
        MyExSpacing.s1,
        MyExSpacing.s1,
        MyExSpacing.s1,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: MyExSizes.minTap - 8),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
                style: MyExType.body,
                decoration: InputDecoration(
                  hintText: l.coachHint,
                  isDense: true,
                ),
              ),
            ),
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: controller,
              builder: (context, v, _) {
                final has = v.text.trim().isNotEmpty;
                return AnimatedScale(
                  scale: has ? 1 : 0,
                  duration: m.snappy,
                  curve: m.snappyCurve,
                  child: Semantics(
                    button: true,
                    label: l.coachSend,
                    excludeSemantics: true,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: sending || !has ? null : onSend,
                      // 44pt hit area around the 32pt button.
                      child: SizedBox(
                        width: MyExSizes.minTap,
                        height: MyExSizes.minTap,
                        child: Center(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: MyExColors.accent,
                            ),
                            child: const SizedBox.square(
                              dimension: MyExSizes.sendButton,
                              child: Icon(
                                Icons.arrow_upward_rounded,
                                size: MyExSizes.icon,
                                color: MyExColors.onAccent,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

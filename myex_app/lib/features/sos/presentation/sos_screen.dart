import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/analytics/analytics.dart';
import '../../../core/analytics/track_once.dart';
import '../../../core/design/design.dart';
import '../../../core/router/app_router.dart';
import '../../../core/util/context_x.dart';
import '../../home/application/streak.dart';
import '../domain/crisis_lines.dart';

// HARD RULE (M0 #1): this file and everything it opens must never import or
// render paywall, limits, coins, premium badges or upsells.
// test/sos/sos_never_paywalled_test.dart enforces it.

/// SOS (spec S9): always free, never limited. Presented modally.
class SosScreen extends ConsumerWidget {
  const SosScreen({super.key, this.from});

  /// Entry point, for the sos_opened safety metric only (never targeting).
  final String? from;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final since = ref.watch(noContactSinceProvider).value;
    final days = since == null ? null : streakDays(since, DateTime.now());
    final top = MediaQuery.paddingOf(context).top;
    return TrackOnce(
      onShown: () =>
          ref.read(analyticsProvider).sosOpened(from: from ?? 'other'),
      child: Scaffold(
        body: ScreenBackground(
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                  MyExSpacing.margin,
                  top + MyExSizes.navBarHeight,
                  MyExSpacing.margin,
                  MediaQuery.paddingOf(context).bottom + MyExSpacing.s4,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            const Gap(MyExSpacing.s4),
                            DisplayText(l.sosTitle, size: MyExType.displaySos),
                            const Gap(MyExSpacing.s6),
                            const _Breathing(),
                            const Gap(MyExSpacing.s6),
                            Text(
                              days != null && days > 0
                                  ? l.sosBodyStreak(days)
                                  : l.sosBody,
                              style: MyExType.body,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                    PrimaryButton(
                      label: l.sosTalk,
                      onPressed: () => context.push(Routes.sosChat),
                    ),
                    const Gap(MyExSpacing.s3),
                    GlassButton(
                      key: const Key('sos-draft'),
                      label: l.sosDraft,
                      icon: MyExIcons.edit,
                      onPressed: () => context.push(Routes.sosDraft),
                    ),
                    TextLinkButton(
                      key: const Key('sos-urgent'),
                      label: l.sosUrgent,
                      tone: TextLinkTone.danger,
                      onPressed: () => showCrisisSheet(context),
                    ),
                    Footnote(l.sosFree),
                  ],
                ),
              ),
              NavBar(
                leading: GlassIconButton(
                  icon: MyExIcons.close,
                  semanticLabel: l.commonClose,
                  onPressed: () => context.canPop()
                      ? context.pop()
                      : context.go(Routes.home),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The night mark breathes (8s cycle) with a synced "Breathe in / Breathe out" cue.
/// Reduce Motion: the mark holds still and only "Breathe in" is shown.
class _Breathing extends StatefulWidget {
  const _Breathing();

  @override
  State<_Breathing> createState() => _BreathingState();
}

class _BreathingState extends State<_Breathing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: MyExDurations.breath,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MyExMotion.of(context).allowLoops) {
      if (!_c.isAnimating) _c.repeat();
    } else {
      _c.stop();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final loops = MyExMotion.of(context).allowLoops;
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        // First half: in (grow), second half: out (shrink).
        final t = _c.value;
        final inhale = t < 0.5;
        final phase = inhale ? t * 2 : (1 - t) * 2;
        final scale = loops
            ? 0.92 + 0.14 * Curves.easeInOut.transform(phase)
            : 1.0;
        return Column(
          children: [
            Transform.scale(
              scale: scale,
              child: const NightMark(size: MyExSizes.lumiSos),
            ),
            const Gap(MyExSpacing.s4),
            Semantics(
              liveRegion: false,
              child: Text(
                !loops || inhale ? l.sosBreatheIn : l.sosBreatheOut,
                style: MyExType.headline.copyWith(color: MyExColors.ink2),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Crisis sheet: real humans first. Always free.
Future<void> showCrisisSheet(BuildContext context) {
  final l = context.l10n;
  final lines = CrisisLines.forLanguage(
    Localizations.localeOf(context).languageCode,
  );
  return showGlassSheet<void>(
    context: context,
    semanticLabel: l.crisisSheetLabel,
    builder: (ctx) => Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l.crisisTitle,
          style: MyExType.title2,
          textAlign: TextAlign.center,
        ),
        const Gap(MyExSpacing.s2),
        Text(
          l.crisisBody,
          style: MyExType.subheadline.copyWith(color: MyExColors.ink),
          textAlign: TextAlign.center,
        ),
        const Gap(MyExSpacing.s6),
        PrimaryButton(
          destructive: true,
          icon: MyExIcons.call,
          label: l.crisisCallEmergency,
          onPressed: () => Links.call(lines.emergency),
        ),
        if (lines.helpline != null) ...[
          const Gap(MyExSpacing.s3),
          GlassButton(
            icon: MyExIcons.support,
            label: l.crisisCallHelpline,
            onPressed: () => Links.call(lines.helpline!),
          ),
        ],
        const Gap(MyExSpacing.s2),
        Footnote(
          lines.helpline == null
              ? l.crisisNumbers(lines.emergency)
              : l.crisisNumbersHelpline(lines.emergency, lines.helpline!),
        ),
        TextLinkButton(
          label: l.commonCancel,
          onPressed: () => Navigator.of(ctx).pop(),
        ),
      ],
    ),
  );
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design/design.dart';
import '../../../core/util/context_x.dart';
import '../../../l10n/app_localizations.dart';
import '../../home/application/streak.dart';
import '../data/no_contact_repository.dart';
import '../domain/no_contact.dart';

/// No-contact challenge: goal ring with the serif day count, the forgiving
/// "days you chose yourself" count, milestones, history, and a kind restart.
/// Never shaming: reaching out is a restart, not a failure.
class NoContactScreen extends ConsumerWidget {
  const NoContactScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final async = ref.watch(noContactProvider);
    final s = async.value;
    final now = DateTime.now();

    return Scaffold(
      body: ScreenBackground(
        child: LargeTitleScrollView(
          title: l.noContactTitle,
          bottomPadding: MyExSpacing.s8 + MediaQuery.paddingOf(context).bottom,
          leading: GlassIconButton(
            icon: Icons.chevron_left_rounded,
            semanticLabel: l.commonBack,
            onPressed: () => context.pop(),
          ),
          onRefresh: () async => ref.invalidate(noContactProvider),
          children: [
            if (s == null)
              const SkeletonBox(height: 280)
            else if (s.current == null)
              _StartCard(hadRuns: s.attempts.isNotEmpty)
            else ...[
              _RingCard(state: s, now: now),
              StatPair(
                left: StatTile(
                  value: '${s.chosenDays(now)}',
                  label: l.noContactChosen,
                  note: l.noContactChosenNote,
                ),
                right: StatTile(
                  value: '${s.bestRun(now)}',
                  label: l.noContactBest,
                  note: l.noContactGoalDays(s.bestRun(now)),
                ),
              ),
              _Milestones(state: s, now: now),
              _GoalPicker(current: s.current!.goalDays),
            ],
            if (s != null && s.past.isNotEmpty) _History(state: s, now: now),
            if (s?.current != null)
              TextLinkButton(
                key: const Key('nc-reached-out'),
                label: l.noContactReachedOut,
                tone: TextLinkTone.muted,
                onPressed: () => _restart(context, ref, s!.currentDays(now)),
              ),
          ],
        ),
      ),
    );
  }

  static Future<void> _restart(
    BuildContext context,
    WidgetRef ref,
    int days,
  ) async {
    final restarted = await showGlassSheet<bool>(
      context: context,
      semanticLabel: context.l10n.noContactRestartTitle,
      builder: (_) => _RestartSheet(days: days),
    );
    if ((restarted ?? false) && context.mounted) {
      showMyExToast(context, context.l10n.noContactRestarted, success: true);
    }
  }
}

class _StartCard extends ConsumerStatefulWidget {
  const _StartCard({required this.hadRuns});
  final bool hadRuns;

  @override
  ConsumerState<_StartCard> createState() => _StartCardState();
}

class _StartCardState extends ConsumerState<_StartCard> {
  int _goal = 30;
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return SolidCard(
      padding: const EdgeInsets.all(MyExSpacing.s5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: PetalMark(size: 52),
          ),
          const Gap(MyExSpacing.s4),
          DisplayText(
            l.noContactIntroTitle,
            textAlign: TextAlign.start,
            size: 34,
          ),
          const Gap(MyExSpacing.s2),
          Text(l.noContactIntroBody, style: MyExType.subheadline),
          const Gap(MyExSpacing.s5),
          Text(l.noContactGoal, style: MyExType.footnote),
          const Gap(MyExSpacing.s2),
          MyExSegmented<int>(
            value: _goal,
            segments: {
              for (final g in noContactGoals) g: l.noContactGoalDays(g),
            },
            onChanged: (g) => setState(() => _goal = g),
          ),
          const Gap(MyExSpacing.s5),
          PrimaryButton(
            key: const Key('nc-start'),
            label: l.noContactStart,
            busy: _busy,
            onPressed: () async {
              setState(() => _busy = true);
              await ref.read(startStreakProvider)(goalDays: _goal);
              unawaited(MyExHaptics.success());
              if (mounted) setState(() => _busy = false);
            },
          ),
        ],
      ),
    );
  }
}

class _RingCard extends StatelessWidget {
  const _RingCard({required this.state, required this.now});
  final NoContactState state;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final days = state.currentDays(now);
    final goal = state.current!.goalDays;
    final target = state.nextTarget(now);
    final reached = days >= goal;
    return Semantics(
      label:
          '${l.noContactTitle}: $days ${l.homeHeroUnit(days)}, '
          '${l.noContactOfGoal(l.noContactGoalDays(goal))}',
      excludeSemantics: true,
      child: SolidCard(
        padding: const EdgeInsets.symmetric(
          horizontal: MyExSpacing.s5,
          vertical: MyExSpacing.s6,
        ),
        child: Column(
          children: [
            ProgressRing(
              value: days / goal,
              size: 196,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('$days', style: MyExType.numeral(MyExType.numeralHero)),
                  const Gap(MyExSpacing.s1),
                  Text(
                    l.noContactOfGoal(l.noContactGoalDays(goal)),
                    style: MyExType.footnote,
                  ),
                ],
              ),
            ),
            const Gap(MyExSpacing.s5),
            Text(
              reached ? l.noContactGoalReached : l.noContactNext(target - days),
              textAlign: TextAlign.center,
              style: MyExType.headline,
            ),
          ],
        ),
      ),
    );
  }
}

String _milestoneLabel(AppLocalizations l, int m) => switch (m) {
  1 => l.noContactMilestone1,
  3 => l.noContactMilestone3,
  7 => l.noContactMilestone7,
  14 => l.noContactMilestone14,
  30 => l.noContactMilestone30,
  60 => l.noContactMilestone60,
  _ => l.noContactMilestone90,
};

class _Milestones extends StatelessWidget {
  const _Milestones({required this.state, required this.now});
  final NoContactState state;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final days = state.currentDays(now);
    final goal = state.current!.goalDays;
    final shown = [
      for (final m in noContactMilestones)
        if (m <= goal || m <= days) m,
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(l.noContactMilestones),
        InsetGroup(
          children: [
            for (final m in shown)
              ListRow(
                leading: _MilestoneBadge(day: m, reached: days >= m),
                title: _milestoneLabel(l, m),
                subtitle: l.noContactGoalDays(m),
                titleColor: days >= m ? null : MyExColors.ink2,
                chevron: false,
              ),
          ],
        ),
      ],
    );
  }
}

class _MilestoneBadge extends StatelessWidget {
  const _MilestoneBadge({required this.day, required this.reached});
  final int day;
  final bool reached;

  @override
  Widget build(BuildContext context) => Container(
    width: MyExSizes.iconSquare,
    height: MyExSizes.iconSquare,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: reached ? MyExColors.accent : null,
      border: reached ? null : Border.all(color: MyExColors.sep, width: 1.5),
    ),
    child: reached
        ? const Icon(
            Icons.check_rounded,
            size: MyExSizes.icon,
            color: MyExColors.onAccent,
          )
        : Text(
            '$day',
            style: MyExType.caption1.copyWith(fontWeight: FontWeight.w600),
          ),
  );
}

class _GoalPicker extends ConsumerWidget {
  const _GoalPicker({required this.current});
  final int current;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(l.noContactGoal),
        MyExSegmented<int>(
          value: current,
          segments: {for (final g in noContactGoals) g: l.noContactGoalDays(g)},
          onChanged: (g) async {
            await ref.read(noContactRepositoryProvider).setGoal(g);
            ref.invalidate(noContactProvider);
          },
        ),
      ],
    );
  }
}

class _History extends StatelessWidget {
  const _History({required this.state, required this.now});
  final NoContactState state;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(l.noContactHistory),
        InsetGroup(
          children: [
            for (final a in state.past)
              ListRow(
                title: l.noContactRun(
                  a.days(now),
                  '${context.shortDate(a.startedOn)} – '
                  '${context.shortDate(a.endedOn!)}',
                ),
                subtitle: a.reflection,
                chevron: false,
              ),
          ],
        ),
      ],
    );
  }
}

class _RestartSheet extends ConsumerStatefulWidget {
  const _RestartSheet({required this.days});
  final int days;

  @override
  ConsumerState<_RestartSheet> createState() => _RestartSheetState();
}

class _RestartSheetState extends ConsumerState<_RestartSheet> {
  final _note = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DisplayText(l.noContactRestartTitle, size: 34),
        const Gap(MyExSpacing.s2),
        Text(
          l.noContactRestartBody(widget.days),
          textAlign: TextAlign.center,
          style: MyExType.subheadline,
        ),
        const Gap(MyExSpacing.s5),
        InsetTextField(
          label: l.noContactReflection,
          controller: _note,
          maxLength: 500,
          maxLines: 4,
          minLines: 2,
        ),
        const Gap(MyExSpacing.s5),
        PrimaryButton(
          key: const Key('nc-restart'),
          label: l.noContactRestart,
          busy: _busy,
          onPressed: () async {
            setState(() => _busy = true);
            await ref
                .read(noContactRepositoryProvider)
                .reachedOut(reflection: _note.text);
            ref.invalidate(noContactProvider);
            if (context.mounted) Navigator.of(context).pop(true);
          },
        ),
        TextLinkButton(
          label: l.commonNotNow,
          tone: TextLinkTone.muted,
          onPressed: () => Navigator.of(context).pop(false),
        ),
      ],
    );
  }
}

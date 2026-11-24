import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/analytics/analytics.dart';
import '../../../core/design/design.dart';
import '../../../core/router/app_router.dart';
import '../../../core/util/context_x.dart';
import '../application/plan_progress.dart';
import '../domain/plan_models.dart';

/// One plan day: the prompt, three answers, Complete. Content comes from
/// rpc get_plan_day (null prompt when locked); completion from
/// rpc complete_plan_day, which re-checks access and the 09:00 time gate.
class DailyTaskScreen extends ConsumerStatefulWidget {
  const DailyTaskScreen({super.key, required this.day});
  final int day;

  @override
  ConsumerState<DailyTaskScreen> createState() => _DailyTaskScreenState();
}

class _DailyTaskScreenState extends ConsumerState<DailyTaskScreen> {
  static const _entries = 3;
  static const _maxChars = 500;
  final _controllers = List.generate(_entries, (_) => TextEditingController());
  bool _busy = false;

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  bool get _filled => _controllers.every((c) => c.text.trim().isNotEmpty);

  Future<void> _complete() async {
    if (_busy || !_filled) return;
    setState(() => _busy = true);
    final l = context.l10n;
    try {
      final r = await ref.read(planRepositoryProvider).complete(widget.day, [
        for (final c in _controllers) c.text.trim(),
      ]);
      if (!mounted) return;
      if (!r.ok) {
        showMyExToast(context, l.taskNotOpen);
        setState(() => _busy = false);
        return;
      }
      ref.invalidate(planStateProvider);
      ref.read(analyticsProvider).planDayCompleted(day: widget.day);
      unawaited(MyExHaptics.success());
      context.pushReplacement(Routes.planDayDone(widget.day));
    } catch (_) {
      if (!mounted) return;
      setState(() => _busy = false);
      showMyExToast(context, l.taskSaveError);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final detail = ref.watch(planDayProvider(widget.day));
    final d = detail.value;
    final editable = d?.status == PlanDayStatus.open;

    return Scaffold(
      body: ScreenBackground(
        child: Column(
          children: [
            Expanded(
              child: LargeTitleScrollView(
                title: l.taskTitle(widget.day),
                largeTitle: false,
                bottomPadding: MyExSpacing.s6,
                leading: GlassIconButton(
                  icon: Icons.chevron_left_rounded,
                  semanticLabel: l.commonBack,
                  onPressed: () => context.canPop()
                      ? context.pop()
                      : context.go(Routes.plan),
                ),
                children: switch (detail) {
                  AsyncData(value: final d) => _content(context, d),
                  AsyncError() => [
                    SolidCard(
                      child: Column(
                        children: [
                          Text(l.taskError, style: MyExType.headline),
                          const Gap(MyExSpacing.s3),
                          PrimaryButton(
                            label: l.commonRetry,
                            onPressed: () =>
                                ref.invalidate(planDayProvider(widget.day)),
                          ),
                        ],
                      ),
                    ),
                  ],
                  _ => const [SkeletonBox(height: MyExSizes.skeletonList)],
                },
              ),
            ),
            if (editable)
              Padding(
                padding: EdgeInsets.fromLTRB(
                  MyExSpacing.margin,
                  MyExSpacing.s3,
                  MyExSpacing.margin,
                  MediaQuery.paddingOf(context).bottom + MyExSpacing.s4,
                ),
                child: ListenableBuilder(
                  listenable: Listenable.merge(_controllers),
                  builder: (context, _) => PrimaryButton(
                    key: const Key('task-complete'),
                    label: l.taskComplete(widget.day),
                    busy: _busy,
                    onPressed: _filled ? _complete : null,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<Widget> _content(BuildContext context, PlanDayDetail d) {
    final l = context.l10n;
    final done = d.status == PlanDayStatus.done;
    return [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(d.title, style: MyExType.title1),
          const Gap(MyExSpacing.s1),
          Text(d.promise, style: MyExType.subheadline),
        ],
      ),
      if (d.prompt != null)
        SolidCard(child: Text(d.prompt!, style: MyExType.body)),
      if (done) ...[
        InsetGroup(
          children: [
            for (final (i, e) in (d.entries ?? const <String>[]).indexed)
              ListRow(
                leading: DayBadge(day: i + 1, tone: DayBadgeTone.open),
                title: e,
                chevron: false,
              ),
          ],
        ),
        Footnote(l.taskDoneNote, icon: Icons.check_rounded),
      ] else if (d.status == PlanDayStatus.open) ...[
        for (var i = 0; i < _entries; i++)
          InsetTextField(
            key: Key('task-entry-$i'),
            label: l.taskEntryLabel(i + 1),
            hint: l.taskEntryHint,
            controller: _controllers[i],
            maxLength: _maxChars,
            maxLines: 4,
          ),
        Footnote(l.taskPrivate, icon: Icons.lock_outline_rounded),
      ] else
        Footnote(l.taskNotOpen),
    ];
  }
}

/// Shown after completing a day: success, what's next, back to the plan.
class DayCompleteScreen extends ConsumerWidget {
  const DayCompleteScreen({super.key, required this.day});
  final int day;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final s = ref.watch(planStateProvider).value;
    final next = day + 1;
    final String nextLine;
    if (day >= planTotalDays) {
      nextLine = l.dayCompleteAll;
    } else if (s != null && s.statusOf(next) == PlanDayStatus.locked) {
      nextLine = l.dayCompleteNextLocked(next);
    } else {
      nextLine = l.dayCompleteNext(
        next,
        context.timeOfDay(PlanSchedule.nextReset(DateTime.now())),
      );
    }
    final m = MyExMotion.of(context);
    return Scaffold(
      body: ScreenBackground(
        child: SafeArea(
          child: Padding(
            padding: kScreenPadding,
            child: Column(
              children: [
                const Spacer(),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: m.reduced ? 1 : 0.6, end: 1),
                  duration: m.bouncy,
                  curve: m.bouncyCurve,
                  builder: (context, v, child) =>
                      Transform.scale(scale: v, child: child),
                  child: Container(
                    width: MyExSizes.successMark,
                    height: MyExSizes.successMark,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: MyExColors.successSoft,
                    ),
                    child: Icon(
                      Icons.check_rounded,
                      color: MyExColors.success,
                      size: MyExSizes.successMark / 2,
                    ),
                  ),
                ),
                const Gap(MyExSpacing.s6),
                Semantics(
                  header: true,
                  child: Text(
                    l.dayCompleteTitle(day),
                    style: MyExType.title1,
                    textAlign: TextAlign.center,
                  ),
                ),
                const Gap(MyExSpacing.s2),
                Text(
                  l.dayCompleteBody,
                  style: MyExType.body.copyWith(color: MyExColors.ink2),
                  textAlign: TextAlign.center,
                ),
                const Gap(MyExSpacing.s4),
                Footnote(nextLine),
                const Spacer(),
                PrimaryButton(
                  label: l.dayCompleteDone,
                  onPressed: () => context.go(Routes.plan),
                ),
                const Gap(MyExSpacing.s4),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

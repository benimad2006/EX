import 'package:flutter/material.dart';

import '../../../../core/design/design.dart';
import '../../../../core/util/context_x.dart';

/// Trial timeline (spec P3 + research R3/R5):
///   ✓ Build your plan (done, from the quiz) → Today → reminder (switch
///   inline) → plan starts. Collapses (smooth spring) when Monthly is picked.
/// If the reminder is on but notifications are blocked, an inline row says so
/// and links to Settings, so the promise is honest.
class TrialTimeline extends StatelessWidget {
  const TrialTimeline({
    super.key,
    required this.open,
    required this.remindDate,
    required this.endDate,
    required this.annualPrice,
    required this.remind,
    required this.onRemindChanged,
    this.notificationsBlocked = false,
    this.onOpenSettings,
  });

  final bool open;
  final DateTime remindDate;
  final DateTime endDate;
  final String annualPrice;
  final bool remind;
  final ValueChanged<bool> onRemindChanged;
  final bool notificationsBlocked;
  final VoidCallback? onOpenSettings;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final m = MyExMotion.of(context);
    return AnimatedSize(
      duration: m.smooth,
      curve: m.smoothCurve,
      alignment: Alignment.topCenter,
      child: AnimatedOpacity(
        opacity: open ? 1 : 0,
        duration: MyExDurations.tabFade,
        child: !open
            ? const SizedBox(width: double.infinity)
            : SolidCard(
                key: const Key('trial-timeline'),
                child: Column(
                  children: [
                    _Step(
                      key: const Key('timeline-built'),
                      icon: Icons.check_rounded,
                      title: l.paywallTimelineBuild,
                      body: l.paywallTimelineBuildBody,
                      done: true,
                    ),
                    _Step(
                      icon: Icons.lock_open_rounded,
                      title: l.paywallTimelineToday,
                      body: l.paywallTimelineTodayBody,
                      current: true,
                    ),
                    _Step(
                      icon: Icons.notifications_none_rounded,
                      title: context.shortDate(remindDate),
                      body: remind
                          ? l.paywallTimelineRemindBody
                          : l.paywallTimelineRemindOffBody,
                      trailing: MyExSwitch(
                        key: const Key('remind-switch'),
                        value: remind,
                        onChanged: onRemindChanged,
                        semanticLabel: l.paywallRemindSemantics,
                      ),
                      extra: remind && notificationsBlocked
                          ? Row(
                              key: const Key('notif-off'),
                              children: [
                                Expanded(
                                  child: Text(
                                    l.paywallNotifOff,
                                    style: MyExType.footnote,
                                  ),
                                ),
                                if (onOpenSettings != null)
                                  TextLinkButton(
                                    label: l.paywallOpenSettings,
                                    small: true,
                                    semibold: true,
                                    onPressed: onOpenSettings,
                                  ),
                              ],
                            )
                          : null,
                    ),
                    _Step(
                      icon: Icons.workspace_premium_outlined,
                      title: context.shortDate(endDate),
                      body: l.paywallTimelineEndBody(annualPrice),
                      last: true,
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
    this.done = false,
    this.current = false,
    this.last = false,
    this.trailing,
    this.extra,
  });

  final IconData icon;
  final String title;
  final String body;

  /// Completed step: success check, title struck through in tertiary ink.
  final bool done;
  final bool current;
  final bool last;
  final Widget? trailing;
  final Widget? extra;

  @override
  Widget build(BuildContext context) {
    final (Color dotBg, Color dotFg) = done
        ? (MyExColors.successSoft, MyExColors.success)
        : current
        ? (MyExColors.accent, MyExColors.onAccent)
        : (MyExColors.accentSoft, MyExColors.accent);
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              Container(
                width: MyExSizes.timelineDot,
                height: MyExSizes.timelineDot,
                decoration: BoxDecoration(shape: BoxShape.circle, color: dotBg),
                child: Icon(icon, size: MyExSizes.iconSm + 2, color: dotFg),
              ),
              if (!last)
                Expanded(
                  child: Container(
                    width: MyExSizes.timelineConnector,
                    color: MyExColors.sep,
                  ),
                ),
            ],
          ),
          const Gap(MyExSpacing.s3),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: last ? 0 : MyExSpacing.s4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MergeSemantics(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: done
                              ? MyExType.headline.copyWith(
                                  color: MyExColors.ink3,
                                  decoration: TextDecoration.lineThrough,
                                  decorationColor: MyExColors.ink3,
                                )
                              : MyExType.headline,
                        ),
                        Text(body, style: MyExType.subheadline),
                      ],
                    ),
                  ),
                  ?extra,
                ],
              ),
            ),
          ),
          if (trailing != null) ...[
            const Gap(MyExSpacing.s2),
            Align(alignment: Alignment.topCenter, child: trailing),
          ],
        ],
      ),
    );
  }
}

/// R13: "How do I cancel?" row that expands in place with the real steps.
class HowToCancelRow extends StatefulWidget {
  const HowToCancelRow({super.key, required this.steps});
  final String steps;

  @override
  State<HowToCancelRow> createState() => _HowToCancelRowState();
}

class _HowToCancelRowState extends State<HowToCancelRow> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final m = MyExMotion.of(context);
    // One group so no separator shows while collapsed.
    return InsetGroup(
      children: [
        Column(
          children: [
            ListRow(
              key: const Key('how-cancel'),
              title: l.paywallHowCancel,
              chevron: false,
              trailing: AnimatedRotation(
                turns: _open ? 0.25 : 0,
                duration: m.reduced ? Duration.zero : MyExDurations.tabFade,
                child: Icon(
                  Icons.chevron_right_rounded,
                  size: MyExSizes.icon,
                  color: MyExColors.ink3,
                ),
              ),
              onTap: () => setState(() => _open = !_open),
            ),
            AnimatedSize(
              duration: m.smooth,
              curve: m.smoothCurve,
              alignment: Alignment.topCenter,
              child: !_open
                  ? const SizedBox(width: double.infinity)
                  : Padding(
                      padding: const EdgeInsets.fromLTRB(
                        MyExSpacing.rowHorizontal,
                        0,
                        MyExSpacing.rowHorizontal,
                        MyExSpacing.rowVertical,
                      ),
                      child: Text(
                        widget.steps,
                        key: const Key('how-cancel-steps'),
                        style: MyExType.subheadline,
                      ),
                    ),
            ),
          ],
        ),
      ],
    );
  }
}

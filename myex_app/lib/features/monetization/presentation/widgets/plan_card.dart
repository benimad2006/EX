import 'package:flutter/material.dart';

import '../../../../core/design/design.dart';

/// One plan option. The billed price ([price] + [period]) is the main price.
class PlanOptionData {
  const PlanOptionData({
    required this.title,
    required this.price,
    required this.period,
    required this.semanticLabel,
    this.saveLabel,
    this.detail,
  });

  final String title;

  /// Billed price, verbatim from StoreKit ("$49.99").
  final String price;

  /// "per year" / "per month".
  final String period;
  final String? saveLabel;

  /// Small secondary line ("7 days free · $4.17/month", "No free trial").
  final String? detail;
  final String semanticLabel;
}

/// Plan picker: one white container with a highlight that slides between
/// rows on a snappy spring (spec P3). Radio semantics; selection haptic.
class PlanPicker extends StatefulWidget {
  const PlanPicker({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelect,
    required this.semanticLabel,
  });

  final List<PlanOptionData> options;
  final int selected;
  final ValueChanged<int> onSelect;
  final String semanticLabel;

  @override
  State<PlanPicker> createState() => _PlanPickerState();
}

class _PlanPickerState extends State<PlanPicker> {
  late List<GlobalKey> _keys;
  List<Rect> _rects = const [];

  @override
  void initState() {
    super.initState();
    _keys = [for (final _ in widget.options) GlobalKey()];
  }

  @override
  void didUpdateWidget(PlanPicker old) {
    super.didUpdateWidget(old);
    if (old.options.length != widget.options.length) {
      _keys = [for (final _ in widget.options) GlobalKey()];
    }
  }

  void _measure() {
    final stack = context.findRenderObject() as RenderBox?;
    if (stack == null || !stack.hasSize) return;
    final rects = <Rect>[];
    for (final k in _keys) {
      final box = k.currentContext?.findRenderObject() as RenderBox?;
      if (box == null || !box.hasSize) return;
      final o = box.localToGlobal(Offset.zero, ancestor: stack);
      rects.add(o & box.size);
    }
    if (!_listEquals(rects, _rects)) setState(() => _rects = rects);
  }

  static bool _listEquals(List<Rect> a, List<Rect> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _measure();
    });
    final m = MyExMotion.of(context);
    final hl = _rects.length > widget.selected ? _rects[widget.selected] : null;
    return Semantics(
      label: widget.semanticLabel,
      container: true,
      child: Container(
        padding: const EdgeInsets.all(MyExSizes.tabBarPadding),
        decoration: BoxDecoration(
          color: MyExColors.bgElev,
          borderRadius: BorderRadius.circular(MyExRadii.l),
          border: Border.all(color: MyExColors.sep),
        ),
        child: Stack(
          children: [
            if (hl != null)
              AnimatedPositioned(
                key: const Key('plan-highlight'),
                duration: m.snappy,
                curve: m.snappyCurve,
                left: 0,
                right: 0,
                top: hl.top - MyExSizes.tabBarPadding,
                height: hl.height,
                child: Container(
                  decoration: BoxDecoration(
                    color: MyExColors.blush,
                    borderRadius: BorderRadius.circular(MyExRadii.planRow),
                  ),
                ),
              ),
            Column(
              children: [
                for (var i = 0; i < widget.options.length; i++)
                  _PlanRow(
                    key: _keys[i],
                    data: widget.options[i],
                    selected: i == widget.selected,
                    onTap: () {
                      if (i != widget.selected) MyExHaptics.selection();
                      widget.onSelect(i);
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanRow extends StatelessWidget {
  const _PlanRow({
    super.key,
    required this.data,
    required this.selected,
    required this.onTap,
  });

  final PlanOptionData data;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // On the blush highlight, text switches to the dark "on blush" ink.
    final on = selected ? MyExColors.onBlush : null;
    final onSoft = selected ? MyExColors.onBlush.withValues(alpha: 0.72) : null;
    return Semantics(
      inMutuallyExclusiveGroup: true,
      checked: selected,
      selected: selected,
      button: true,
      label: data.semanticLabel,
      excludeSemantics: true,
      child: Pressable(
        onTap: onTap,
        pressedScale: 0.98,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: MyExSizes.planRowMinHeight,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: MyExSpacing.s4,
              vertical: MyExSizes.planRowVertical,
            ),
            child: Row(
              children: [
                RadioDot(selected: selected),
                const Gap(MyExSpacing.s3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text.rich(
                        TextSpan(
                          text: data.title,
                          style: MyExType.headline.copyWith(color: on),
                          children: [
                            if (data.saveLabel != null) ...[
                              const TextSpan(text: '  '),
                              TextSpan(
                                text: data.saveLabel,
                                style: MyExType.save.copyWith(
                                  color: selected ? MyExColors.onBlush : null,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (data.detail != null)
                        Text(
                          data.detail!,
                          style: MyExType.footnote.copyWith(color: onSoft),
                        ),
                    ],
                  ),
                ),
                const Gap(MyExSpacing.s2),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      data.price,
                      key: const Key('plan-billed'),
                      style: MyExType.billedPrice.copyWith(color: on),
                    ),
                    Text(
                      data.period,
                      key: const Key('plan-period'),
                      style: MyExType.priceDetail.copyWith(color: onSoft),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 22pt radio: ring when off, accent fill + check (bouncy pop) when on.
class RadioDot extends StatelessWidget {
  const RadioDot({super.key, required this.selected});
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final m = MyExMotion.of(context);
    return AnimatedContainer(
      duration: m.reduced ? Duration.zero : MyExDurations.tabFade,
      width: MyExSizes.radio,
      height: MyExSizes.radio,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? MyExColors.accent : null,
        border: selected
            ? null
            : Border.all(color: MyExColors.ink3, width: 1.5),
      ),
      child: AnimatedScale(
        scale: selected ? 1 : 0,
        duration: selected ? m.bouncy : MyExDurations.tabFade,
        curve: selected ? m.bouncyCurve : MyExCurves.easeIn,
        child: const Icon(
          Icons.check_rounded,
          size: MyExSizes.radioCheck + 2,
          color: MyExColors.onAccent,
        ),
      ),
    );
  }
}

/// Loading placeholder: never shows placeholder prices.
class PlanCardSkeleton extends StatelessWidget {
  const PlanCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) =>
      const SkeletonBox(height: MyExSizes.planRowMinHeight * 2 + 8);
}

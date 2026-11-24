import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'components.dart';
import 'glass.dart';
import 'motion.dart';
import 'tokens.dart';
import 'typography.dart';

// =============================================================================
// WELLBEING COMPONENTS — mood scale, mood chart, week strip, stat tiles and the
// petal empty state (docs/design/MYEX_DESIGN_DIRECTION.md). Words over faces:
// every mood colour is paired with a label; no emoji anywhere.
// =============================================================================

/// Filled mood dot (level 1..5). [level] null = an empty day (hairline ring).
class MoodDot extends StatelessWidget {
  const MoodDot({super.key, required this.level, this.size = 10});
  final double? level;
  final double size;

  @override
  Widget build(BuildContext context) {
    final l = level;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: l == null ? null : MyExColors.mood(l.round()),
        border: l == null
            ? Border.all(color: MyExColors.sep, width: 1.5)
            : null,
      ),
    );
  }
}

/// Five-step mood selector. The selected step swells (bouncy spring; a plain
/// swap under Reduce Motion) and its word shows underneath.
class MoodScale extends StatelessWidget {
  const MoodScale({
    super.key,
    required this.value,
    required this.onChanged,
    required this.words,
    required this.semantics,
    this.dotSize = 40,
  });

  final int? value;
  final ValueChanged<int> onChanged;

  /// Words for levels 1..5 (lowercase, e.g. "heavy").
  final List<String> words;

  /// Semantic label for a level, e.g. "Mood 2 of 5, low".
  final String Function(int level, String word) semantics;
  final double dotSize;

  @override
  Widget build(BuildContext context) {
    final m = MyExMotion.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (var lv = 1; lv <= 5; lv++)
              Semantics(
                button: true,
                inMutuallyExclusiveGroup: true,
                selected: value == lv,
                label: semantics(lv, words[lv - 1]),
                excludeSemantics: true,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    MyExHaptics.selection();
                    onChanged(lv);
                  },
                  child: SizedBox.square(
                    dimension: math.max(dotSize + 12, MyExSizes.minTap),
                    child: Center(
                      child: AnimatedScale(
                        scale: value == lv ? 1.18 : 1,
                        duration: m.bouncy,
                        curve: m.bouncyCurve,
                        child: AnimatedContainer(
                          duration: m.snappy,
                          width: dotSize,
                          height: dotSize,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: MyExColors.mood(lv).withValues(
                              alpha: value == null || value == lv ? 1 : 0.5,
                            ),
                            border: value == lv
                                ? Border.all(color: MyExColors.bgElev, width: 3)
                                : null,
                            boxShadow: value == lv
                                ? [
                                    BoxShadow(
                                      color: MyExColors.mood(lv),
                                      spreadRadius: 1.5,
                                    ),
                                  ]
                                : null,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        const Gap(MyExSpacing.s1),
        Row(
          children: [
            Text(words.first, style: MyExType.caption1),
            const Spacer(),
            SwapText(
              value == null ? '' : words[value! - 1],
              style: MyExType.subheadline.copyWith(
                color: MyExColors.ink,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Text(words.last, style: MyExType.caption1),
          ],
        ),
      ],
    );
  }
}

/// Selectable word capsule (feelings, filters). A control, so it may be a pill.
class WordChip extends StatelessWidget {
  const WordChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.leading,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final m = MyExMotion.of(context);
    return Semantics(
      button: true,
      selected: selected,
      child: Pressable(
        onTap: () {
          MyExHaptics.selection();
          onTap();
        },
        pressedScale: MyExPress.glass,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: MyExSizes.minTap),
          child: Center(
            widthFactor: 1,
            child: AnimatedContainer(
              duration: m.snappy,
              curve: m.snappyCurve,
              padding: const EdgeInsets.symmetric(
                horizontal: MyExSpacing.s3 + 2,
                vertical: MyExSpacing.s2,
              ),
              decoration: BoxDecoration(
                color: selected ? MyExColors.accentSoft : MyExColors.bgElev,
                borderRadius: BorderRadius.circular(MyExRadii.capsule),
                border: Border.all(
                  color: selected ? MyExColors.accent : MyExColors.sep,
                  width: selected ? 1.2 : MyExSizes.hairline,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (leading != null) ...[
                    leading!,
                    const Gap(MyExSpacing.s1 + 2),
                  ],
                  Text(
                    label,
                    style: MyExType.subheadline.copyWith(
                      color: selected ? MyExColors.accentInk : MyExColors.ink,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Number + label tile (serif numeral; the label is the accessible name).
class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.value,
    required this.label,
    this.note,
    this.onTap,
  });

  final String value;
  final String label;
  final String? note;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tile = SolidCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: MyExType.numeral(MyExType.numeralRing)),
          const Gap(MyExSpacing.s2),
          Text(label, style: MyExType.footnote.copyWith(color: MyExColors.ink)),
          if (note != null) Text(note!, style: MyExType.caption1),
        ],
      ),
    );
    return MergeSemantics(
      child: Semantics(
        button: onTap != null,
        child: onTap == null
            ? tile
            : Pressable(onTap: onTap, pressedScale: 0.98, child: tile),
      ),
    );
  }
}

/// Two tiles side by side, equal height.
class StatPair extends StatelessWidget {
  const StatPair({super.key, required this.left, required this.right});
  final Widget left;
  final Widget right;

  @override
  Widget build(BuildContext context) => IntrinsicHeight(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: left),
        const Gap(MyExSpacing.s3),
        Expanded(child: right),
      ],
    ),
  );
}

/// Calm empty state: the petal mark, a sentence-case title, one line, and an
/// optional primary action. The night mark stays on its four screens.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.title,
    required this.body,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String body;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => SolidCard(
    padding: const EdgeInsets.fromLTRB(
      MyExSpacing.s5,
      MyExSpacing.s8,
      MyExSpacing.s5,
      MyExSpacing.s5,
    ),
    child: Column(
      children: [
        const PetalMark(),
        const Gap(MyExSpacing.s5),
        Text(
          title,
          textAlign: TextAlign.center,
          style: MyExType.display.copyWith(fontSize: 28, height: 32 / 28),
        ),
        const Gap(MyExSpacing.s2),
        Text(body, textAlign: TextAlign.center, style: MyExType.subheadline),
        if (actionLabel != null) ...[
          const Gap(MyExSpacing.s5),
          PrimaryButton(label: actionLabel!, onPressed: onAction),
        ],
      ],
    ),
  );
}

/// Three overlapping rose petals: the brand mark for empty states.
class PetalMark extends StatelessWidget {
  const PetalMark({super.key, this.size = 64});
  final double size;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: CustomPaint(
      size: Size.square(size),
      painter: _PetalPainter(
        MyExColors.accent,
        MyExColors.mood(5),
        MyExColors.mood(2),
      ),
    ),
  );
}

class _PetalPainter extends CustomPainter {
  _PetalPainter(this.a, this.b, this.c);
  final Color a, b, c;

  @override
  void paint(Canvas canvas, Size s) {
    final center = Offset(s.width / 2, s.height * 0.58);
    final r = s.width * 0.3;
    Path petal(double angle) {
      final p = Path()
        ..moveTo(0, 0)
        ..cubicTo(-r * 0.9, -r * 0.5, -r * 0.55, -r * 1.7, 0, -r * 1.75)
        ..cubicTo(r * 0.55, -r * 1.7, r * 0.9, -r * 0.5, 0, 0)
        ..close();
      return p.transform(
        (Matrix4.identity()
              ..translateByDouble(center.dx, center.dy, 0, 1)
              ..rotateZ(angle))
            .storage,
      );
    }

    canvas
      ..drawPath(petal(-0.62), Paint()..color = c.withValues(alpha: 0.85))
      ..drawPath(petal(0.62), Paint()..color = b.withValues(alpha: 0.9))
      ..drawPath(petal(0), Paint()..color = a);
  }

  @override
  bool shouldRepaint(_PetalPainter o) => o.a != a || o.b != b || o.c != c;
}

/// Daily mood averages as a soft line with dots; null days leave a gap.
/// Draws in once (left to right) unless Reduce Motion is on.
class MoodLineChart extends StatelessWidget {
  const MoodLineChart({
    super.key,
    required this.values,
    required this.xLabels,
    required this.semanticLabel,
    this.height = 150,
  });

  /// Oldest → newest, each 1..5 or null.
  final List<double?> values;

  /// Three labels: start, middle, end.
  final List<String> xLabels;
  final String semanticLabel;
  final double height;

  @override
  Widget build(BuildContext context) {
    final m = MyExMotion.of(context);
    return Semantics(
      label: semanticLabel,
      image: true,
      excludeSemantics: true,
      child: Column(
        children: [
          SizedBox(
            height: height,
            width: double.infinity,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: m.reduced ? 1 : 0, end: 1),
              duration: m.reduced ? Duration.zero : MyExDurations.chartDraw,
              curve: MyExCurves.easeOut,
              builder: (context, t, _) => CustomPaint(
                painter: _MoodLinePainter(
                  values: values,
                  progress: t,
                  grid: MyExColors.sep,
                  line: MyExColors.accent,
                  dotRing: MyExColors.bgElev,
                ),
              ),
            ),
          ),
          const Gap(MyExSpacing.s2),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (final x in xLabels) Text(x, style: MyExType.caption1),
            ],
          ),
        ],
      ),
    );
  }
}

class _MoodLinePainter extends CustomPainter {
  _MoodLinePainter({
    required this.values,
    required this.progress,
    required this.grid,
    required this.line,
    required this.dotRing,
  });

  final List<double?> values;
  final double progress;
  final Color grid, line, dotRing;

  @override
  void paint(Canvas canvas, Size size) {
    const pad = 8.0;
    final w = size.width - pad * 2;
    final h = size.height - pad * 2;
    double y(double v) => pad + h - (v - 1) / 4 * h;
    double x(int i) =>
        pad + (values.length == 1 ? w / 2 : w * i / (values.length - 1));

    final gridPaint = Paint()
      ..color = grid
      ..strokeWidth = MyExSizes.hairline;
    for (var lv = 1; lv <= 5; lv++) {
      canvas.drawLine(
        Offset(pad, y(lv.toDouble())),
        Offset(pad + w, y(lv.toDouble())),
        gridPaint,
      );
    }

    final limitX = pad + w * progress;
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, limitX + 6, size.height));

    // Smooth segments between consecutive non-null points.
    final path = Path();
    Offset? prev;
    for (var i = 0; i < values.length; i++) {
      final v = values[i];
      if (v == null) {
        prev = null;
        continue;
      }
      final p = Offset(x(i), y(v));
      if (prev == null) {
        path.moveTo(p.dx, p.dy);
      } else {
        final mid = (prev.dx + p.dx) / 2;
        path.cubicTo(mid, prev.dy, mid, p.dy, p.dx, p.dy);
      }
      prev = p;
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = line.withValues(alpha: 0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
    for (var i = 0; i < values.length; i++) {
      final v = values[i];
      if (v == null) continue;
      final c = Offset(x(i), y(v));
      canvas
        ..drawCircle(c, 6, Paint()..color = dotRing)
        ..drawCircle(c, 4.5, Paint()..color = MyExColors.mood(v.round()));
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_MoodLinePainter o) =>
      o.progress != progress || o.values != values || o.line != line;
}

/// Seven days (Mon..Sun or locale order) with a mood dot each.
class WeekStrip extends StatelessWidget {
  const WeekStrip({super.key, required this.days});

  /// (weekday letter, average level or null, isToday).
  final List<(String, double?, bool)> days;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      for (final (label, level, today) in days)
        Column(
          children: [
            MoodDot(level: level, size: 22),
            const Gap(MyExSpacing.s2),
            Text(
              label,
              style: MyExType.caption1.copyWith(
                color: today ? MyExColors.ink : MyExColors.ink2,
                fontWeight: today ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ],
        ),
    ],
  );
}

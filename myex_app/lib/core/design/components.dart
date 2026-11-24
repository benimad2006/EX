import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'art.dart';
import 'glass.dart';
import 'motion.dart';
import 'tokens.dart';
import 'typography.dart';

// =============================================================================
// SHARED COMPONENTS — flat white surfaces on the grouped background, iOS
// grouped inset lists, solid accent buttons, serif display text, Lumi + Mira.
// All visuals come from tokens / typography / motion. No shadows on content,
// no gradients except the streak hero, no tags/pills except the coin chip.
// =============================================================================

/// Calm static page background: bg + two faint glows (gives glass something
/// to refract without moving).
class ScreenBackground extends StatelessWidget {
  const ScreenBackground({super.key, required this.child, this.stars = true});
  final Widget child;

  /// Night only: a faint star field over the upper sky.
  final bool stars;

  @override
  Widget build(BuildContext context) {
    final night = MyExColors.isNight;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: MyExColors.bg,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [MyExColors.skyTop, MyExColors.bg],
          stops: const [0, 0.55],
        ),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(1, -1),
            radius: 1.0,
            colors: [MyExColors.pageGlowTop, const Color(0x00FF78A0)],
            stops: const [0, 0.7],
          ),
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(-1, 1),
              radius: 0.8,
              colors: [MyExColors.pageGlowBottom, const Color(0x00FFAAC3)],
              stops: const [0, 0.7],
            ),
          ),
          child: night && stars
              ? Stack(
                  children: [
                    const Positioned(
                      left: 0,
                      right: 0,
                      top: 0,
                      height: 420,
                      child: Opacity(
                        opacity: 0.55,
                        child: StarField(count: 38, seed: 21),
                      ),
                    ),
                    Positioned.fill(child: child),
                  ],
                )
              : child,
        ),
      ),
    );
  }
}

/// Standard screen margin.
const kScreenPadding = EdgeInsets.symmetric(horizontal: MyExSpacing.margin);

class Gap extends StatelessWidget {
  const Gap(this.size, {super.key});
  final double size;
  @override
  Widget build(BuildContext context) => SizedBox(height: size, width: size);
}

/// Flat white card (no border, no shadow).
class SolidCard extends StatelessWidget {
  const SolidCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(MyExSpacing.cardPadding),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: MyExColors.bgElev,
        borderRadius: const BorderRadius.all(Radius.circular(MyExRadii.l)),
        border: Border.all(
          color: MyExColors.cardRim,
          width: MyExSizes.hairline,
        ),
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

// -----------------------------------------------------------------------------
// Grouped inset list
// -----------------------------------------------------------------------------

/// Section header above an [InsetGroup] (Title 3).
class SectionHeader extends StatelessWidget {
  const SectionHeader(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(
      MyExSpacing.s4,
      MyExSpacing.s2,
      MyExSpacing.s4,
      MyExSpacing.s2,
    ),
    child: Semantics(header: true, child: Text(text, style: MyExType.title3)),
  );
}

/// Footnote under an [InsetGroup].
class SectionFooter extends StatelessWidget {
  const SectionFooter(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(
      MyExSpacing.s4,
      MyExSpacing.s2,
      MyExSpacing.s4,
      0,
    ),
    child: Text(text, style: MyExType.footnote),
  );
}

/// White rounded container of [ListRow]s with inset hairline separators.
class InsetGroup extends StatelessWidget {
  const InsetGroup({super.key, required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      if (i > 0) {
        final prev = children[i - 1];
        final inset = prev is ListRow && prev.hasLeading
            ? MyExSpacing.separatorInsetIcon
            : MyExSpacing.separatorInset;
        rows.add(
          Padding(
            padding: EdgeInsets.only(left: inset),
            child: Divider(
              height: MyExSizes.hairline,
              thickness: MyExSizes.hairline,
              color: MyExColors.sep,
            ),
          ),
        );
      }
      rows.add(children[i]);
    }
    return DecoratedBox(
      position: DecorationPosition.foreground,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(MyExRadii.l),
        border: Border.all(
          color: MyExColors.cardRim,
          width: MyExSizes.hairline,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(MyExRadii.l),
        child: ColoredBox(
          color: MyExColors.bgElev,
          child: Column(mainAxisSize: MainAxisSize.min, children: rows),
        ),
      ),
    );
  }
}

enum IconTone { accent, neutral, success, danger }

/// 30pt rounded icon square used as a row's leading glyph.
class IconSquare extends StatelessWidget {
  const IconSquare({
    super.key,
    required this.icon,
    this.tone = IconTone.accent,
  });
  final IconData icon;
  final IconTone tone;

  @override
  Widget build(BuildContext context) {
    final bg = switch (tone) {
      IconTone.accent => MyExColors.accent,
      IconTone.neutral => MyExColors.neutralIcon,
      IconTone.success => MyExColors.success,
      IconTone.danger => MyExColors.danger,
    };
    return Container(
      width: MyExSizes.iconSquare,
      height: MyExSizes.iconSquare,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(MyExRadii.xs),
      ),
      child: Icon(icon, size: MyExSizes.icon, color: MyExColors.onAccent),
    );
  }
}

/// One row of a grouped list. Rows highlight with [MyExColors.fill] on press
/// (they do not scale).
class ListRow extends StatefulWidget {
  const ListRow({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.value,
    this.trailing,
    this.onTap,
    this.chevron,
    this.titleColor,
    this.subtitleColor,
    this.semanticLabel,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final String? value;
  final Widget? trailing;
  final VoidCallback? onTap;

  /// Defaults to `onTap != null`.
  final bool? chevron;
  final Color? titleColor;
  final Color? subtitleColor;
  final String? semanticLabel;

  bool get hasLeading => leading != null;

  @override
  State<ListRow> createState() => _ListRowState();
}

class _ListRowState extends State<ListRow> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final w = widget;
    final showChevron = w.chevron ?? w.onTap != null;
    final row = AnimatedContainer(
      duration: _down ? Duration.zero : MyExDurations.pressOut,
      curve: MyExCurves.easeOut,
      color: _down ? MyExColors.fill : MyExColors.bgElev,
      constraints: const BoxConstraints(minHeight: MyExSizes.rowMinHeight),
      padding: const EdgeInsets.symmetric(
        horizontal: MyExSpacing.rowHorizontal,
        vertical: MyExSpacing.rowVertical,
      ),
      child: Row(
        children: [
          if (w.leading != null) ...[w.leading!, const Gap(MyExSpacing.s3)],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  w.title,
                  style: MyExType.body.copyWith(color: w.titleColor),
                ),
                if (w.subtitle != null)
                  Text(
                    w.subtitle!,
                    style: MyExType.footnote.copyWith(color: w.subtitleColor),
                  ),
              ],
            ),
          ),
          if (w.value != null) ...[
            const Gap(MyExSpacing.s2),
            Text(
              w.value!,
              style: MyExType.body.copyWith(
                color: MyExColors.ink2,
                fontFeatures: MyExType.tabular,
              ),
            ),
          ],
          if (w.trailing != null) ...[const Gap(MyExSpacing.s2), w.trailing!],
          if (showChevron) ...[
            const Gap(MyExSpacing.s2),
            Icon(
              Icons.chevron_right_rounded,
              size: MyExSizes.icon,
              color: MyExColors.ink3,
            ),
          ],
        ],
      ),
    );
    return MergeSemantics(
      child: Semantics(
        button: w.onTap != null,
        label: w.semanticLabel,
        child: w.onTap == null
            ? row
            : GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: (_) => setState(() => _down = true),
                onTapUp: (_) => setState(() => _down = false),
                onTapCancel: () => setState(() => _down = false),
                onTap: w.onTap,
                child: row,
              ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Buttons
// -----------------------------------------------------------------------------

/// Primary CTA: solid accent capsule, 52pt, 17/600 Title Case.
/// Press scales to 0.97. Shows a spinner and ignores taps while busy.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.busy = false,
    this.icon,
    this.destructive = false,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool busy;
  final IconData? icon;

  /// Danger background (crisis "Call Emergency Services").
  final bool destructive;

  /// Full width (false = hug content, for small inline buttons).
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !busy;
    final bg = destructive ? MyExColors.danger : MyExColors.accent;
    final content = busy
        ? const SizedBox.square(
            dimension: MyExSizes.iconLg,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: MyExColors.onAccent,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, color: MyExColors.onAccent, size: MyExSizes.icon),
                const Gap(MyExSpacing.s2),
              ],
              Flexible(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: MyExType.button.copyWith(color: MyExColors.onAccent),
                ),
              ),
            ],
          );
    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      excludeSemantics: true,
      child: Pressable(
        onTap: enabled ? onPressed : null,
        child: Opacity(
          opacity: onPressed == null ? 0.4 : 1,
          child: Container(
            width: expand ? double.infinity : null,
            constraints: const BoxConstraints(
              minHeight: MyExSizes.buttonHeight,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: MyExSpacing.s5,
              vertical: MyExSpacing.s2,
            ),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(MyExRadii.capsule),
            ),
            alignment: expand ? Alignment.center : null,
            child: expand ? content : Center(widthFactor: 1, child: content),
          ),
        ),
      ),
    );
  }
}

enum TextLinkTone { accent, muted, danger }

/// Text button (Restore, Not Now, links). 44pt tall.
class TextLinkButton extends StatelessWidget {
  const TextLinkButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.tone = TextLinkTone.accent,
    this.small = false,
    this.semibold = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final TextLinkTone tone;

  /// Footnote size (13pt) instead of body (17pt).
  final bool small;
  final bool semibold;

  @override
  Widget build(BuildContext context) {
    final color = switch (tone) {
      TextLinkTone.accent => MyExColors.accentInk,
      TextLinkTone.muted => MyExColors.ink2,
      TextLinkTone.danger => MyExColors.danger,
    };
    final base = small ? MyExType.footnote : MyExType.body;
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onPressed,
        behavior: HitTestBehavior.opaque,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: MyExSizes.minTap,
            minWidth: MyExSizes.minTap,
          ),
          child: Center(
            widthFactor: 1,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: MyExSpacing.s2),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: base.copyWith(
                  color: onPressed == null ? MyExColors.ink3 : color,
                  fontWeight: semibold ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Text
// -----------------------------------------------------------------------------

/// Instrument Serif display headline, upright. One per emotional screen.
class DisplayText extends StatelessWidget {
  const DisplayText(
    this.text, {
    super.key,
    this.size,
    this.textAlign = TextAlign.center,
  });

  final String text;
  final double? size;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) => Semantics(
    header: true,
    child: Text(
      text,
      textAlign: textAlign,
      style: size == null
          ? MyExType.display
          : MyExType.display.copyWith(
              fontSize: size,
              height: (size! + 4) / size!,
            ),
    ),
  );
}

/// Footnote line with an optional leading glyph (replaces coloured notes).
class Footnote extends StatelessWidget {
  const Footnote(
    this.text, {
    super.key,
    this.icon,
    this.textAlign = TextAlign.center,
    this.color,
  });

  final String text;
  final IconData? icon;
  final TextAlign textAlign;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final style = MyExType.footnote.copyWith(color: color);
    final t = Text(text, style: style, textAlign: textAlign);
    if (icon == null) return t;
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: textAlign == TextAlign.center
          ? MainAxisAlignment.center
          : MainAxisAlignment.start,
      children: [
        Icon(icon, size: MyExSizes.iconSm, color: style.color),
        const Gap(MyExSpacing.s1 + 2),
        Flexible(child: t),
      ],
    );
  }
}

/// Placeholder block for loading states (never placeholder prices).
class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    super.key,
    this.height = 72,
    this.width = double.infinity,
  });
  final double height;
  final double width;

  @override
  Widget build(BuildContext context) => Container(
    height: height,
    width: width,
    decoration: BoxDecoration(
      color: MyExColors.fill,
      borderRadius: BorderRadius.circular(MyExRadii.l),
    ),
  );
}

/// iOS switch (system green), selection haptic on change.
class MyExSwitch extends StatelessWidget {
  const MyExSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.semanticLabel,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) => Semantics(
    label: semanticLabel,
    child: CupertinoSwitch(
      value: value,
      activeTrackColor: MyExColors.switchOn,
      onChanged: (v) {
        MyExHaptics.selection();
        onChanged(v);
      },
    ),
  );
}

/// 4pt progress bar.
class ProgressBar extends StatelessWidget {
  const ProgressBar({super.key, required this.value, this.color, this.track});

  final double value;
  final Color? color;
  final Color? track;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(MyExRadii.progress),
    child: SizedBox(
      height: MyExSizes.progressHeight,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ColoredBox(color: track ?? MyExColors.fill),
          FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: value.clamp(0, 1),
            child: ColoredBox(color: color ?? MyExColors.accent),
          ),
        ],
      ),
    ),
  );
}

/// The ONLY gradient surface: the Home streak hero.
class HeroCard extends StatelessWidget {
  const HeroCard({super.key, required this.child, this.onTap});
  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      pressedScale: 0.98,
      child: Container(
        width: double.infinity,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(MyExRadii.xl),
          gradient: MyExColors.heroGradient,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(MyExRadii.xl),
            gradient: MyExColors.heroHighlightGradient,
          ),
          child: Stack(
            children: [
              const Positioned(
                right: -6,
                top: -10,
                child: Opacity(opacity: 0.9, child: CrescentMoon(size: 92)),
              ),
              const Positioned.fill(
                child: Opacity(
                  opacity: 0.6,
                  child: StarField(
                    count: 14,
                    seed: 9,
                    color: MyExColors.onHero,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(MyExSpacing.s5),
                child: DefaultTextStyle.merge(
                  style: const TextStyle(color: MyExColors.onHero),
                  child: IconTheme.merge(
                    data: const IconThemeData(color: MyExColors.onHero),
                    child: child,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Coin glyph (keeps its real gold colour).
class CoinIcon extends StatelessWidget {
  const CoinIcon({super.key, this.size = MyExSizes.coin});
  final double size;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: MyExColors.coinFace,
        border: Border.all(color: MyExColors.coinGold, width: size / 9),
      ),
      child: Icon(Icons.favorite, size: size * 0.5, color: MyExColors.accent),
    ),
  );
}

// -----------------------------------------------------------------------------
// Mascots
// -----------------------------------------------------------------------------

enum LumiPose { happy, eyesClosed }

/// Lumi, the heart mascot. ONLY on Plan ready, SOS, Welcome and Win-back.
/// No crown, no confetti, no glow. Swap the painter for final artwork.
class LumiMascot extends StatelessWidget {
  const LumiMascot({
    super.key,
    this.size = MyExSizes.lumi,
    this.pose = LumiPose.happy,
    this.entrance = false,
  });

  final double size;
  final LumiPose pose;

  /// Bouncy scale-in (Welcome success). Off under Reduce Motion.
  final bool entrance;

  @override
  Widget build(BuildContext context) {
    final art = ExcludeSemantics(
      child: CustomPaint(size: Size.square(size), painter: _LumiPainter(pose)),
    );
    final m = MyExMotion.of(context);
    if (!entrance || m.reduced) return art;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.7, end: 1),
      duration: m.bouncy,
      curve: m.bouncyCurve,
      builder: (context, s, child) => Opacity(
        opacity: ((s - 0.7) / 0.3).clamp(0, 1),
        child: Transform.scale(scale: s, child: child),
      ),
      child: art,
    );
  }
}

class _LumiPainter extends CustomPainter {
  _LumiPainter(this.pose);
  final LumiPose pose;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 200;
    canvas.scale(s);
    final heart = Path()
      ..moveTo(100, 174)
      ..cubicTo(40, 132, 22, 98, 22, 70)
      ..cubicTo(22, 44, 42, 28, 64, 28)
      ..cubicTo(80, 28, 92, 36, 100, 50)
      ..cubicTo(108, 36, 120, 28, 136, 28)
      ..cubicTo(158, 28, 178, 44, 178, 70)
      ..cubicTo(178, 98, 160, 132, 100, 174)
      ..close();
    canvas.drawPath(
      heart,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [MyExColors.lumiTop, MyExColors.lumiBottom],
        ).createShader(const Rect.fromLTWH(0, 0, 200, 200)),
    );
    final ink = Paint()
      ..color = MyExColors.lumiFace
      ..strokeWidth = 4.2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    for (final cx in [76.0, 124.0]) {
      if (pose == LumiPose.eyesClosed) {
        canvas.drawPath(
          Path()
            ..moveTo(cx - 8, 89)
            ..quadraticBezierTo(cx, 97, cx + 8, 89),
          ink,
        );
      } else {
        canvas.drawOval(
          Rect.fromCenter(center: Offset(cx, 90), width: 14, height: 18),
          Paint()..color = MyExColors.lumiFace,
        );
      }
    }
    canvas.drawPath(
      Path()
        ..moveTo(90, 112)
        ..quadraticBezierTo(100, 122, 110, 112),
      ink,
    );
  }

  @override
  bool shouldRepaint(_LumiPainter old) => old.pose != pose;
}

/// Mira: a faceless orb (presence, not a second character).
class MiraOrb extends StatelessWidget {
  const MiraOrb({
    super.key,
    this.size = MyExSizes.miraHeader,
    this.thinking = false,
  });
  final double size;

  /// Gentle brightness pulse while Mira is typing (off under Reduce Motion).
  final bool thinking;

  @override
  Widget build(BuildContext context) {
    final orb = ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: MyExColors.miraOrb,
          border: Border.all(color: MyExColors.miraRim, width: size / 100 * 2),
        ),
      ),
    );
    if (!thinking || !MyExMotion.of(context).allowLoops) return orb;
    return _Pulse(child: orb);
  }
}

class _Pulse extends StatefulWidget {
  const _Pulse({required this.child});
  final Widget child;
  @override
  State<_Pulse> createState() => _PulseState();
}

class _PulseState extends State<_Pulse> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: Tween<double>(begin: 1, end: 0.8).animate(_c),
    child: widget.child,
  );
}

/// Chat bubble: 17/22, radius 18; user = solid accent, Mira = white.
class ChatBubble extends StatelessWidget {
  const ChatBubble({super.key, required this.text, required this.fromUser});
  final String text;
  final bool fromUser;

  @override
  Widget build(BuildContext context) => Align(
    alignment: fromUser ? Alignment.centerRight : Alignment.centerLeft,
    child: ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.sizeOf(context).width * 0.78,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: fromUser ? MyExColors.accent : MyExColors.bgElev,
          borderRadius: BorderRadius.circular(MyExRadii.bubble),
        ),
        child: Text(
          text,
          style: MyExType.body.copyWith(
            color: fromUser ? MyExColors.onAccent : MyExColors.ink,
          ),
        ),
      ),
    ),
  );
}

/// Free-message meter dots (6pt).
class MeterDots extends StatelessWidget {
  const MeterDots({super.key, required this.total, required this.filled});
  final int total;
  final int filled;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      for (var i = 0; i < total; i++)
        Padding(
          padding: const EdgeInsets.only(right: MyExSpacing.s1),
          child: Container(
            width: MyExSizes.meterDot,
            height: MyExSizes.meterDot,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: i < filled ? MyExColors.accent : MyExColors.sep,
            ),
          ),
        ),
    ],
  );
}

/// 30-day strip (15×2 capsules): done = success, today = accent, rest = fill.
class DayStrip extends StatelessWidget {
  const DayStrip({super.key, required this.total, required this.today});
  final int total;

  /// 1-based current day.
  final int today;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: LayoutBuilder(
        builder: (context, c) {
          const cols = MyExSizes.stripColumns;
          const gap = MyExSpacing.s1;
          final w = (c.maxWidth - gap * (cols - 1)) / cols;
          return Wrap(
            spacing: gap,
            runSpacing: gap,
            children: [
              for (var d = 1; d <= total; d++)
                Container(
                  width: w,
                  height: MyExSizes.stripCell,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(MyExRadii.strip),
                    color: d < today
                        ? MyExColors.success
                        : d == today
                        ? MyExColors.accent
                        : MyExColors.fill,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// Smoothly swaps text when it changes (opacity 120ms).
class SwapText extends StatelessWidget {
  const SwapText(this.text, {super.key, this.style, this.textAlign});
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) => AnimatedSwitcher(
    duration: MyExMotion.of(context).reduced
        ? Duration.zero
        : MyExDurations.textSwap,
    child: Text(text, key: ValueKey(text), style: style, textAlign: textAlign),
  );
}

// -----------------------------------------------------------------------------
// Toast: a Dynamic Island HUD that grows out of the island.
// -----------------------------------------------------------------------------

OverlayEntry? _toastEntry;
Timer? _toastTimer;

void showMyExToast(
  BuildContext context,
  String message, {
  bool success = false,
}) {
  final overlay = Overlay.maybeOf(context, rootOverlay: true);
  if (overlay == null) return;
  _toastTimer?.cancel();
  _toastEntry?.remove();
  final entry = OverlayEntry(
    builder: (ctx) => _IslandToast(message: message, success: success),
  );
  _toastEntry = entry;
  overlay.insert(entry);
  _toastTimer = Timer(const Duration(milliseconds: 2400), () {
    if (_toastEntry == entry) {
      entry.remove();
      _toastEntry = null;
    }
  });
}

class _IslandToast extends StatelessWidget {
  const _IslandToast({required this.message, required this.success});
  final String message;
  final bool success;

  @override
  Widget build(BuildContext context) {
    final m = MyExMotion.of(context);
    final top = math.max(MediaQuery.paddingOf(context).top - 36, 11.0);
    return Positioned(
      top: top,
      left: MyExSpacing.s4,
      right: MyExSpacing.s4,
      child: IgnorePointer(
        child: Semantics(
          liveRegion: true,
          label: message,
          child: Center(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: m.reduced ? 1 : 0.4, end: 1),
              duration: m.snappy,
              curve: m.snappyCurve,
              builder: (context, t, child) => Opacity(
                opacity: t.clamp(0, 1),
                child: Transform.scale(scaleX: t, child: child),
              ),
              child: Container(
                constraints: const BoxConstraints(minWidth: 126, minHeight: 37),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: MyExColors.presentingBackdrop,
                  borderRadius: BorderRadius.circular(19),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (success) ...[
                      const Icon(
                        Icons.check_circle_rounded,
                        size: MyExSizes.icon,
                        color: MyExColors.switchOn,
                      ),
                      const Gap(MyExSpacing.s2),
                    ],
                    Flexible(
                      child: Text(
                        message,
                        textAlign: TextAlign.center,
                        style: MyExType.subheadline.copyWith(
                          color: MyExColors.onAccent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Form controls (grouped-list style)
// -----------------------------------------------------------------------------

/// A selectable list row: trailing accent check when selected. Radio
/// semantics by default, checkbox semantics when [multi] is true.
class SelectRow extends StatelessWidget {
  const SelectRow({
    super.key,
    required this.title,
    required this.selected,
    required this.onTap,
    this.subtitle,
    this.multi = false,
  });

  final String title;
  final String? subtitle;
  final bool selected;
  final bool multi;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      inMutuallyExclusiveGroup: !multi,
      checked: selected,
      selected: selected,
      child: ListRow(
        title: title,
        subtitle: subtitle,
        chevron: false,
        onTap: () {
          MyExHaptics.selection();
          onTap();
        },
        trailing: AnimatedOpacity(
          opacity: selected ? 1 : 0,
          duration: MyExDurations.tabFade,
          child: Icon(
            Icons.check_rounded,
            color: MyExColors.accent,
            size: MyExSizes.iconMd,
          ),
        ),
      ),
    );
  }
}

/// Text field inside a white rounded row (label above, iOS look).
class InsetTextField extends StatelessWidget {
  const InsetTextField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.maxLength,
    this.maxLines = 1,
    this.minLines = 1,
    this.onChanged,
    this.textCapitalization = TextCapitalization.sentences,
  });

  final String label;
  final String? hint;
  final TextEditingController controller;
  final int? maxLength;
  final int maxLines;
  final int minLines;
  final ValueChanged<String>? onChanged;
  final TextCapitalization textCapitalization;

  @override
  Widget build(BuildContext context) {
    return SolidCard(
      padding: const EdgeInsets.symmetric(
        horizontal: MyExSpacing.rowHorizontal,
        vertical: MyExSpacing.s2,
      ),
      child: TextField(
        controller: controller,
        maxLength: maxLength,
        maxLines: maxLines,
        minLines: minLines,
        onChanged: onChanged,
        textCapitalization: textCapitalization,
        style: MyExType.body,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: MyExType.footnote,
          floatingLabelStyle: MyExType.footnote,
          hintText: hint,
          counterText: '',
          isDense: true,
        ),
      ),
    );
  }
}

/// iOS slider in the accent colour.
class MyExSlider extends StatelessWidget {
  const MyExSlider({
    super.key,
    required this.value,
    required this.onChanged,
    required this.min,
    required this.max,
    this.divisions,
    this.semanticLabel,
  });

  final double value;
  final double min;
  final double max;
  final int? divisions;
  final ValueChanged<double> onChanged;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) => Semantics(
    label: semanticLabel,
    child: CupertinoSlider(
      value: value,
      min: min,
      max: max,
      divisions: divisions,
      activeColor: MyExColors.accent,
      onChanged: (v) {
        if (v.round() != value.round()) MyExHaptics.selection();
        onChanged(v);
      },
    ),
  );
}

/// iOS segmented control in tokens.
class MyExSegmented<T extends Object> extends StatelessWidget {
  const MyExSegmented({
    super.key,
    required this.segments,
    required this.value,
    required this.onChanged,
  });

  final Map<T, String> segments;
  final T? value;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    child: CupertinoSlidingSegmentedControl<T>(
      groupValue: value,
      backgroundColor: MyExColors.fill,
      thumbColor: MyExColors.bgElev,
      onValueChanged: (v) {
        if (v == null) return;
        MyExHaptics.selection();
        onChanged(v);
      },
      children: {
        for (final e in segments.entries)
          e.key: Padding(
            padding: const EdgeInsets.symmetric(vertical: MyExSpacing.s2),
            child: Text(
              e.value,
              style: MyExType.subheadline.copyWith(
                color: MyExColors.ink,
                fontWeight: e.key == value ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
      },
    ),
  );
}

/// Destructive confirm dialog (iOS alert style).
Future<bool> showConfirmDialog({
  required BuildContext context,
  required String title,
  required String message,
  required String confirmLabel,
  required String cancelLabel,
  bool destructive = true,
}) async {
  final r = await showCupertinoDialog<bool>(
    context: context,
    builder: (ctx) => CupertinoAlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        CupertinoDialogAction(
          isDefaultAction: true,
          onPressed: () => Navigator.of(ctx).pop(false),
          child: Text(cancelLabel),
        ),
        CupertinoDialogAction(
          isDestructiveAction: destructive,
          onPressed: () => Navigator.of(ctx).pop(true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return r ?? false;
}

enum DayBadgeTone { done, today, open, locked }

/// 28pt plan-day circle: done = success check, today = solid accent number,
/// open = neutral number, locked = tertiary lock.
class DayBadge extends StatelessWidget {
  const DayBadge({super.key, required this.day, required this.tone});
  final int day;
  final DayBadgeTone tone;

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color fg) = switch (tone) {
      DayBadgeTone.done => (MyExColors.successSoft, MyExColors.success),
      DayBadgeTone.today => (MyExColors.accent, MyExColors.onAccent),
      DayBadgeTone.open => (MyExColors.fill, MyExColors.ink),
      DayBadgeTone.locked => (MyExColors.fill, MyExColors.ink3),
    };
    return ExcludeSemantics(
      child: Container(
        width: MyExSizes.timelineDot,
        height: MyExSizes.timelineDot,
        decoration: BoxDecoration(shape: BoxShape.circle, color: bg),
        alignment: Alignment.center,
        child: switch (tone) {
          DayBadgeTone.done => Icon(
            Icons.check_rounded,
            size: MyExSizes.iconSm,
            color: fg,
          ),
          DayBadgeTone.locked => Icon(
            Icons.lock_outline_rounded,
            size: MyExSizes.iconSm,
            color: fg,
          ),
          _ => Text(
            '$day',
            style: MyExType.footnote.copyWith(
              color: fg,
              fontWeight: FontWeight.w600,
            ),
          ),
        },
      ),
    );
  }
}

/// Circular progress ring (Trial status): accent stroke on a fill track.
class ProgressRing extends StatelessWidget {
  const ProgressRing({
    super.key,
    required this.value,
    required this.child,
    this.size = MyExSizes.ring,
  });

  final double value;
  final double size;
  final Widget child;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: size,
    child: Stack(
      alignment: Alignment.center,
      children: [
        CustomPaint(
          size: Size.square(size),
          painter: _RingPainter(value.clamp(0, 1)),
        ),
        child,
      ],
    ),
  );
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.value);
  final double value;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = MyExSizes.ringStroke;
    final rect = Offset.zero & size;
    final r = rect.deflate(stroke / 2);
    canvas.drawArc(
      r,
      0,
      2 * math.pi,
      false,
      Paint()
        ..color = MyExColors.fill
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke,
    );
    canvas.drawArc(
      r,
      -math.pi / 2,
      2 * math.pi * value,
      false,
      Paint()
        ..color = MyExColors.accent
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = stroke,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.value != value;
}

/// Calm billing-issue banner (no guilt copy). Tapping opens App Store
/// subscription management.
class BillingIssueBanner extends StatelessWidget {
  const BillingIssueBanner({
    super.key,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) => InsetGroup(
    children: [
      ListRow(
        key: const Key('billing-issue'),
        leading: const IconSquare(
          icon: Icons.credit_card_rounded,
          tone: IconTone.danger,
        ),
        title: title,
        subtitle: message,
        value: actionLabel,
        onTap: onAction,
      ),
    ],
  );
}

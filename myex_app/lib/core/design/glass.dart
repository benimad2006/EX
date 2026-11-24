import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../accessibility/accessibility_flags.dart';
import 'motion.dart';
import 'tokens.dart';
import 'typography.dart';

// =============================================================================
// LIQUID GLASS (iOS 26) — floating chrome ONLY: nav buttons, tab bar + SOS
// accessory, coin chip, composer + meter, sheets, secondary buttons.
// Recipe: white 55% + blur 14 + saturate 180% + 0.5pt white rim + soft neutral
// shadow + a faint top-left specular highlight.
// Reduce Transparency ON → solid white, hairline rim, no blur.
// Glass controls SWELL on press (1.06) instead of shrinking.
// =============================================================================

/// Saturation matrix (s = 1 → identity).
List<double> _saturation(double s) {
  const r = 0.2126, g = 0.7152, b = 0.0722;
  final i = 1 - s;
  return [
    i * r + s, i * g, i * b, 0, 0, //
    i * r, i * g + s, i * b, 0, 0, //
    i * r, i * g, i * b + s, 0, 0, //
    0, 0, 0, 1, 0,
  ];
}

final _glassFilter = ImageFilter.compose(
  outer: ImageFilter.blur(
    sigmaX: MyExGlassTokens.blurSigma,
    sigmaY: MyExGlassTokens.blurSigma,
  ),
  inner: ColorFilter.matrix(_saturation(MyExGlassTokens.saturation)),
);

/// The base glass surface.
class GlassSurface extends ConsumerWidget {
  const GlassSurface({
    super.key,
    required this.child,
    this.radius = MyExRadii.l,
    this.padding = EdgeInsets.zero,
    this.shadow = true,
    this.shape = BoxShape.rectangle,
  });

  final Widget child;
  final double radius;
  final EdgeInsetsGeometry padding;
  final bool shadow;
  final BoxShape shape;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reduced = ref.watch(reduceTransparencyProvider);
    final circle = shape == BoxShape.circle;
    final r = circle ? null : BorderRadius.circular(radius);
    final box = DecoratedBox(
      decoration: BoxDecoration(
        shape: shape,
        borderRadius: r,
        color: reduced ? MyExColors.bgElev : MyExColors.glassFill,
        gradient: reduced
            ? null
            : RadialGradient(
                center: const Alignment(-0.5, -1),
                radius: 1.2,
                colors: [MyExColors.glassHighlight, MyExColors.glassFill],
                stops: [0, 0.55],
              ),
        border: Border.all(
          color: reduced ? MyExColors.sep : MyExColors.glassRim,
          width: MyExGlassTokens.rimWidth,
        ),
        boxShadow: shadow ? MyExShadows.glass : null,
      ),
      child: Padding(padding: padding, child: child),
    );
    if (reduced) return box;
    final filtered = BackdropFilter(filter: _glassFilter, child: box);
    return circle
        ? ClipOval(child: filtered)
        : ClipRRect(borderRadius: r!, child: filtered);
  }
}

/// Press feedback: fast in (80ms easeOut), slower snappy release.
class Pressable extends StatefulWidget {
  const Pressable({
    super.key,
    required this.child,
    required this.onTap,
    this.pressedScale = MyExPress.filled,
    this.haptic = false,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double pressedScale;

  /// Fire a selection haptic on tap.
  final bool haptic;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _down = false;

  void _set(bool v) {
    if (widget.onTap == null || _down == v) return;
    setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) {
    final m = MyExMotion.of(context);
    final scale = m.reduced || !_down ? 1.0 : widget.pressedScale;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _set(true),
      onTapUp: (_) => _set(false),
      onTapCancel: () => _set(false),
      onTap: widget.onTap == null
          ? null
          : () {
              if (widget.haptic) MyExHaptics.selection();
              widget.onTap!();
            },
      child: AnimatedScale(
        scale: scale,
        duration: _down ? m.pressIn : m.pressOut,
        curve: _down ? MyExCurves.easeOut : m.snappyCurve,
        child: widget.child,
      ),
    );
  }
}

/// Round glass nav button (close, back). 44×44, visible at first frame.
class GlassIconButton extends StatelessWidget {
  const GlassIconButton({
    super.key,
    required this.icon,
    required this.semanticLabel,
    required this.onPressed,
  });

  final IconData icon;
  final String semanticLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      excludeSemantics: true,
      child: Pressable(
        onTap: onPressed,
        pressedScale: MyExPress.glass,
        child: SizedBox.square(
          dimension: MyExSizes.minTap,
          child: GlassSurface(
            shape: BoxShape.circle,
            child: Center(
              child: Icon(icon, size: MyExSizes.iconMd, color: MyExColors.ink),
            ),
          ),
        ),
      ),
    );
  }
}

/// Glass chip (coin balance). 36pt visual inside a 44pt hit area.
class GlassChip extends StatelessWidget {
  const GlassChip({
    super.key,
    required this.label,
    this.leading,
    this.onPressed,
    this.semanticLabel,
    this.foreground,
  });

  final String label;
  final Widget? leading;
  final VoidCallback? onPressed;
  final String? semanticLabel;
  final Color? foreground;

  @override
  Widget build(BuildContext context) {
    final chip = SizedBox(
      height: MyExSizes.minTap,
      child: Center(
        widthFactor: 1,
        child: SizedBox(
          height: MyExSizes.chipVisualHeight,
          child: GlassSurface(
            radius: MyExRadii.capsule,
            padding: const EdgeInsets.symmetric(horizontal: MyExSpacing.s3),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (leading != null) ...[
                  IconTheme.merge(
                    data: IconThemeData(
                      color: foreground ?? MyExColors.ink,
                      size: MyExSizes.icon,
                    ),
                    child: leading!,
                  ),
                  const SizedBox(width: MyExSpacing.s1 + 2),
                ],
                Text(
                  label,
                  style: MyExType.subheadline.copyWith(
                    color: foreground ?? MyExColors.ink,
                    fontWeight: FontWeight.w600,
                    fontFeatures: MyExType.tabular,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    return Semantics(
      button: onPressed != null,
      label: semanticLabel ?? label,
      excludeSemantics: true,
      child: onPressed == null
          ? chip
          : Pressable(
              onTap: onPressed,
              pressedScale: MyExPress.glass,
              child: chip,
            ),
    );
  }
}

/// Secondary glass button (52pt, Title Case label).
class GlassButton extends StatelessWidget {
  const GlassButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.leading,
    this.busy = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Widget? leading;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !busy;
    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      excludeSemantics: true,
      child: Pressable(
        onTap: enabled ? onPressed : null,
        pressedScale: MyExPress.glass,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: MyExSizes.buttonHeight),
          child: GlassSurface(
            radius: MyExRadii.capsule,
            padding: const EdgeInsets.symmetric(
              horizontal: MyExSpacing.s5,
              vertical: MyExSpacing.s3,
            ),
            child: Center(
              child: busy
                  ? SizedBox.square(
                      dimension: MyExSizes.icon,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: MyExColors.ink2,
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (leading != null || icon != null) ...[
                          leading ??
                              Icon(
                                icon,
                                size: MyExSizes.icon,
                                color: MyExColors.ink,
                              ),
                          const SizedBox(width: MyExSpacing.s2),
                        ],
                        Flexible(
                          child: Text(
                            label,
                            textAlign: TextAlign.center,
                            style: MyExType.button,
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

// -----------------------------------------------------------------------------
// Floating tab bar + SOS accessory
// -----------------------------------------------------------------------------

class GlassTabItem {
  const GlassTabItem({
    required this.icon,
    required this.label,
    this.selectedIcon,
  });
  final IconData icon;
  final IconData? selectedIcon;
  final String label;
}

/// Floating glass tab bar with a sliding selection capsule (snappy spring).
class GlassTabBar extends StatelessWidget {
  const GlassTabBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  final List<GlassTabItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final m = MyExMotion.of(context);
    return SizedBox(
      height: MyExSizes.tabBarHeight,
      child: GlassSurface(
        radius: MyExSizes.tabBarHeight / 2,
        padding: const EdgeInsets.all(MyExSizes.tabBarPadding),
        child: LayoutBuilder(
          builder: (context, c) {
            final w = c.maxWidth / items.length;
            return Stack(
              children: [
                AnimatedPositioned(
                  key: const Key('tab-capsule'),
                  duration: m.snappy,
                  curve: m.snappyCurve,
                  left: w * currentIndex,
                  top: 0,
                  bottom: 0,
                  width: w,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: MyExColors.capsule,
                      borderRadius: const BorderRadius.all(
                        Radius.circular(MyExRadii.tabCapsule),
                      ),
                    ),
                  ),
                ),
                Row(
                  children: [
                    for (var i = 0; i < items.length; i++)
                      Expanded(
                        child: Semantics(
                          selected: i == currentIndex,
                          button: true,
                          label: items[i].label,
                          excludeSemantics: true,
                          child: Pressable(
                            pressedScale: MyExPress.tab,
                            onTap: () {
                              if (i != currentIndex) MyExHaptics.selection();
                              onTap(i);
                            },
                            child: _TabCell(
                              item: items[i],
                              selected: i == currentIndex,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _TabCell extends StatelessWidget {
  const _TabCell({required this.item, required this.selected});
  final GlassTabItem item;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    // Unselected items use the primary label colour (iOS 26), not muted pink.
    final color = selected ? MyExColors.accent : MyExColors.ink;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          selected ? (item.selectedIcon ?? item.icon) : item.icon,
          color: color,
          size: MyExSizes.tabIcon,
        ),
        const SizedBox(height: 2),
        Text(
          item.label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: MyExType.caption2.copyWith(color: color),
        ),
      ],
    );
  }
}

/// The separate 62pt SOS circle next to the tab bar.
class SosCircleButton extends StatelessWidget {
  const SosCircleButton({
    super.key,
    required this.label,
    required this.semanticLabel,
    required this.onPressed,
  });

  final String label;
  final String semanticLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      excludeSemantics: true,
      child: Pressable(
        onTap: onPressed,
        pressedScale: MyExPress.glass,
        child: SizedBox.square(
          dimension: MyExSizes.sosCircle,
          child: GlassSurface(
            shape: BoxShape.circle,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.favorite_border_rounded,
                  color: MyExColors.danger,
                  size: MyExSizes.iconMd,
                ),
                const SizedBox(height: 1),
                Text(
                  label,
                  style: MyExType.caption2.copyWith(color: MyExColors.danger),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Sheets: the page behind scales to 0.94, moves down 14pt, rounds to 38.
// -----------------------------------------------------------------------------

/// Number of glass sheets currently presented.
abstract final class SheetPresentation {
  static final depth = ValueNotifier<int>(0);
}

/// Wrap every top-level page with this: it scales behind presented sheets.
class PresentingScale extends StatelessWidget {
  const PresentingScale({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final m = MyExMotion.of(context);
    return ValueListenableBuilder<int>(
      valueListenable: SheetPresentation.depth,
      child: child,
      builder: (context, depth, child) {
        final on = depth > 0 && m.allowPresentingScale;
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: depth > 0 || MyExColors.isNight
              ? SystemUiOverlayStyle.light
              : SystemUiOverlayStyle.dark,
          child: TweenAnimationBuilder<double>(
            tween: Tween(end: on ? 1 : 0),
            duration: on ? m.smooth : MyExDurations.dismiss,
            curve: on ? m.smoothCurve : MyExCurves.easeIn,
            child: child,
            builder: (context, t, child) {
              if (t == 0) return child!;
              return Transform.translate(
                offset: Offset(0, MyExPresentation.backgroundOffsetY * t),
                child: Transform.scale(
                  scale: 1 - (1 - MyExPresentation.backgroundScale) * t,
                  alignment: Alignment.topCenter,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(
                      MyExPresentation.backgroundRadius * t,
                    ),
                    child: child,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

/// Modal glass sheet (content height). Scales the app behind it.
Future<T?> showGlassSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  String? semanticLabel,
  bool isDismissible = true,
}) async {
  final m = MyExMotion.of(context);
  SheetPresentation.depth.value++;
  try {
    return await showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      isDismissible: isDismissible,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: MyExColors.scrim,
      elevation: 0,
      sheetAnimationStyle: AnimationStyle(
        duration: m.smooth,
        reverseDuration: m.reduced
            ? MyExDurations.reducedFade
            : MyExDurations.dismiss,
      ),
      builder: (ctx) => Semantics(
        scopesRoute: true,
        explicitChildNodes: true,
        namesRoute: semanticLabel != null,
        label: semanticLabel,
        child: _GlassSheetFrame(child: builder(ctx)),
      ),
    );
  } finally {
    SheetPresentation.depth.value--;
  }
}

class _GlassSheetFrame extends StatelessWidget {
  const _GlassSheetFrame({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Padding(
      padding: const EdgeInsets.all(MyExSpacing.s2),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(MyExRadii.sheet)),
          boxShadow: MyExShadows.sheet,
        ),
        child: GlassSurface(
          radius: MyExRadii.sheet,
          shadow: false,
          padding: EdgeInsets.fromLTRB(
            MyExSpacing.s5,
            MyExSpacing.s2,
            MyExSpacing.s5,
            MyExSpacing.s5 + bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: MyExSizes.grabberWidth,
                  height: MyExSizes.grabberHeight,
                  decoration: BoxDecoration(
                    color: MyExColors.ink3,
                    borderRadius: const BorderRadius.all(
                      Radius.circular(MyExRadii.capsule),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: MyExSpacing.s4),
              Flexible(child: SingleChildScrollView(child: child)),
            ],
          ),
        ),
      ),
    );
  }
}

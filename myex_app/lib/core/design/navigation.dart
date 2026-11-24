import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';

import 'components.dart';
import 'motion.dart';
import 'tokens.dart';
import 'typography.dart';

// =============================================================================
// NAVIGATION CHROME — iOS large titles that collapse into an inline title with
// a scroll-edge fade, a tab crossfade, and push/pop transitions that become a
// 200ms crossfade under Reduce Motion.
// =============================================================================

/// Scrollable page with an iOS large title. The 52pt nav bar shows the inline
/// title (and the scroll-edge fade) once scrolled past 36pt.
///
/// Set [largeTitle] to false for pushed utility screens (inline title only).
class LargeTitleScrollView extends StatefulWidget {
  const LargeTitleScrollView({
    super.key,
    required this.title,
    required this.children,
    this.subtitle,
    this.leading,
    this.trailing,
    this.largeTitle = true,
    this.bottomPadding = 120,
    this.onRefresh,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final bool largeTitle;
  final List<Widget> children;

  /// Room for the floating tab bar on tab screens.
  final double bottomPadding;
  final Future<void> Function()? onRefresh;

  @override
  State<LargeTitleScrollView> createState() => _LargeTitleScrollViewState();
}

class _LargeTitleScrollViewState extends State<LargeTitleScrollView> {
  final _scrolled = ValueNotifier<bool>(false);

  @override
  void dispose() {
    _scrolled.dispose();
    super.dispose();
  }

  bool _onScroll(ScrollNotification n) {
    if (n.depth == 0) {
      _scrolled.value =
          !widget.largeTitle || n.metrics.pixels > MyExSizes.largeTitleCollapse;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    if (!widget.largeTitle) _scrolled.value = true;
    Widget list = ListView(
      padding: EdgeInsets.fromLTRB(
        MyExSpacing.margin,
        top + MyExSizes.navBarHeight,
        MyExSpacing.margin,
        widget.bottomPadding,
      ),
      children: [
        if (widget.largeTitle) ...[
          Semantics(
            header: true,
            child: Text(widget.title, style: MyExType.largeTitle),
          ),
          if (widget.subtitle != null)
            Text(widget.subtitle!, style: MyExType.subheadline),
          const Gap(MyExSpacing.section - MyExSpacing.titleToContent),
        ],
        for (var i = 0; i < widget.children.length; i++) ...[
          if (i > 0) const Gap(MyExSpacing.section),
          widget.children[i],
        ],
      ],
    );
    if (widget.onRefresh != null) {
      list = RefreshIndicator(
        onRefresh: widget.onRefresh!,
        edgeOffset: top + MyExSizes.navBarHeight,
        color: MyExColors.accent,
        child: list,
      );
    }
    return Stack(
      children: [
        NotificationListener<ScrollNotification>(
          onNotification: _onScroll,
          child: list,
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: ValueListenableBuilder<bool>(
            valueListenable: _scrolled,
            builder: (context, scrolled, _) => NavBar(
              title: widget.title,
              showTitle: scrolled,
              showEdge: scrolled,
              leading: widget.leading,
              trailing: widget.trailing,
            ),
          ),
        ),
      ],
    );
  }
}

/// 52pt nav bar under the status bar: 44pt leading/trailing slots, centered
/// 17/600 title, optional scroll-edge fade behind it.
class NavBar extends StatelessWidget {
  const NavBar({
    super.key,
    this.title,
    this.showTitle = true,
    this.showEdge = false,
    this.leading,
    this.trailing,
    this.center,
  });

  final String? title;
  final bool showTitle;
  final bool showEdge;
  final Widget? leading;
  final Widget? trailing;

  /// Custom center (e.g. the Coach orb + name).
  final Widget? center;

  @override
  Widget build(BuildContext context) {
    final m = MyExMotion.of(context);
    final top = MediaQuery.paddingOf(context).top;
    return Stack(
      children: [
        Positioned.fill(
          bottom: -20,
          child: IgnorePointer(
            child: AnimatedOpacity(
              opacity: showEdge ? 1 : 0,
              duration: MyExDurations.tabFade,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [MyExColors.bg, MyExColors.bg, MyExColors.bgClear],
                    stops: [0, 0.55, 1],
                  ),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
            top: top,
            left: MyExSpacing.margin,
            right: MyExSpacing.margin,
          ),
          child: SizedBox(
            height: MyExSizes.navBarHeight,
            child: Row(
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: MyExSizes.minTap),
                  child: leading ?? const SizedBox.shrink(),
                ),
                Expanded(
                  child:
                      center ??
                      AnimatedSlide(
                        offset: showTitle ? Offset.zero : const Offset(0, 0.25),
                        duration: m.reduced
                            ? Duration.zero
                            : MyExDurations.pressOut,
                        curve: m.smoothCurve,
                        child: AnimatedOpacity(
                          opacity: showTitle && title != null ? 1 : 0,
                          duration: MyExDurations.tabFade,
                          child: Text(
                            title ?? '',
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: MyExType.navTitle,
                          ),
                        ),
                      ),
                ),
                ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: MyExSizes.minTap),
                  child: Align(
                    alignment: Alignment.centerRight,
                    widthFactor: 1,
                    child: trailing,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Tab switch: a quick 180ms crossfade (no slide, no scale). Keeps each
/// branch alive like IndexedStack.
class FadeIndexedStack extends StatefulWidget {
  const FadeIndexedStack({
    super.key,
    required this.index,
    required this.children,
  });
  final int index;
  final List<Widget> children;

  @override
  State<FadeIndexedStack> createState() => _FadeIndexedStackState();
}

class _FadeIndexedStackState extends State<FadeIndexedStack>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: MyExDurations.tabFade,
    value: 1,
  );

  @override
  void didUpdateWidget(FadeIndexedStack old) {
    super.didUpdateWidget(old);
    if (old.index != widget.index) _c.forward(from: 0);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: CurvedAnimation(parent: _c, curve: MyExCurves.easeOut),
    child: IndexedStack(index: widget.index, children: widget.children),
  );
}

/// Push/pop: native iOS parallax (Cupertino). Reduce Motion: 200ms crossfade.
class MyExPageTransitionsBuilder extends PageTransitionsBuilder {
  const MyExPageTransitionsBuilder();

  static const _cupertino = CupertinoPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (MyExMotion.of(context).reduced) {
      return FadeTransition(opacity: animation, child: child);
    }
    return _cupertino.buildTransitions(
      route,
      context,
      animation,
      secondaryAnimation,
      child,
    );
  }
}

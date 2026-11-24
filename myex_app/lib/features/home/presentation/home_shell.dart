import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design/design.dart';
import '../../../core/router/app_router.dart';
import '../../../core/util/context_x.dart';

/// Tab shell (spec N1): content runs under a persistent floating glass tab bar
/// (left 20 · bottom 20 · right edge leaves room for the 62pt SOS circle).
class HomeShell extends StatelessWidget {
  const HomeShell({super.key, required this.shell});
  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final bottom = MediaQuery.paddingOf(context).bottom;
    final barBottom = bottom > 0 ? bottom : MyExSpacing.tabBarInset;
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: shell),
          Positioned(
            left: MyExSpacing.tabBarInset,
            right:
                MyExSpacing.tabBarInset +
                MyExSizes.sosCircle +
                MyExSpacing.s2 +
                2,
            bottom: barBottom,
            child: GlassTabBar(
              currentIndex: shell.currentIndex,
              onTap: (i) =>
                  shell.goBranch(i, initialLocation: i == shell.currentIndex),
              items: [
                GlassTabItem(
                  icon: Icons.home_outlined,
                  selectedIcon: Icons.home_rounded,
                  label: l.tabHome,
                ),
                GlassTabItem(
                  icon: Icons.format_list_bulleted_rounded,
                  label: l.tabPlan,
                ),
                GlassTabItem(
                  icon: Icons.chat_bubble_outline_rounded,
                  selectedIcon: Icons.chat_bubble_rounded,
                  label: l.tabCoach,
                ),
                GlassTabItem(
                  icon: Icons.book_outlined,
                  selectedIcon: Icons.book_rounded,
                  label: l.tabJournal,
                ),
                GlassTabItem(
                  icon: Icons.person_outline_rounded,
                  selectedIcon: Icons.person_rounded,
                  label: l.tabMe,
                ),
              ],
            ),
          ),
          Positioned(
            right: MyExSpacing.tabBarInset,
            bottom: barBottom,
            child: SosCircleButton(
              key: const Key('tab-sos'),
              label: l.sosButton,
              semanticLabel: l.sosButtonSemantics,
              onPressed: () => context.push(Routes.sosFrom('tab_bar')),
            ),
          ),
        ],
      ),
    );
  }
}

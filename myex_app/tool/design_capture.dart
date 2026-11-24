// Design QA harness (dev only, never shipped): boots the app in demo mode and
// walks every route so the rendered screens can be captured on a simulator.
//
//   flutter run -d <simulator> -t tool/design_capture.dart
//
// For each screen it prints `CAPTURE:<name>` and holds still for [_hold], so a
// watcher script can run `xcrun simctl io booted screenshot <name>.png`.
// Empty states are captured first, then the demo "sample weeks" are filled in
// and the data screens are captured again (`*_filled`).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myex_app/app.dart';
import 'package:myex_app/core/router/app_router.dart';
import 'package:myex_app/demo/demo_mode.dart';
import 'package:myex_app/demo/demo_ui.dart';
import 'package:myex_app/features/journal/data/journal_repository.dart';
import 'package:myex_app/features/journal/presentation/mood_checkin_sheet.dart';
import 'package:myex_app/features/no_contact/data/no_contact_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _hold = Duration(milliseconds: 3000);
const _only = String.fromEnvironment('ONLY'); // comma list to limit routes

const _empty = <String, String>{
  'onboarding': Routes.onboarding,
  'plan_ready': Routes.planReady,
  'paywall': Routes.paywall,
  'welcome_trial': '/welcome?trial=1',
  'home': Routes.home,
  'plan': Routes.plan,
  'plan_day_1': '/plan/day/1',
  'plan_day_done': '/plan/day/1/done',
  'coach': Routes.coach,
  'journal': Routes.journal,
  'journal_new':
      '/journal-entry?kind=letter&prompt=A%20letter%20you%20won%E2%80%99t%20send',
  'no_contact': Routes.noContact,
  'insights': Routes.insights,
  'me': Routes.me,
  'sos': Routes.sos,
  'drafts': Routes.drafts,
  'coins': Routes.coins,
  'trial': Routes.trial,
  'winback': Routes.winback,
};

const _filled = <String, String>{
  'home_filled': Routes.home,
  'journal_filled': Routes.journal,
  'no_contact_filled': Routes.noContact,
  'insights_filled': Routes.insights,
  'me_filled': Routes.me,
};

bool _want(String name) =>
    _only.isEmpty || _only.split(',').any((p) => name.startsWith(p));

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();
  final container = ProviderContainer(overrides: demoOverrides(prefs));
  runApp(
    UncontrolledProviderScope(container: container, child: const MyExApp()),
  );
  await Future<void>.delayed(const Duration(seconds: 4));
  final router = container.read(appRouterProvider);

  Future<void> shoot(String name, String route) async {
    if (!_want(name)) return;
    router.go(route);
    await Future<void>.delayed(const Duration(milliseconds: 1800));
    debugPrint('CAPTURE:$name');
    await Future<void>.delayed(_hold);
  }

  for (final e in _empty.entries) {
    await shoot(e.key, e.value);
  }

  container.read(demoStoreProvider).fillSample(turkish: false);
  container
    ..invalidate(noContactProvider)
    ..invalidate(journalEntriesProvider)
    ..invalidate(moodEntriesProvider);
  for (final e in _filled.entries) {
    await shoot(e.key, e.value);
  }

  if (_want('mood_sheet')) {
    router.go(Routes.home);
    await Future<void>.delayed(const Duration(milliseconds: 1200));
    final ctx = router.routerDelegate.navigatorKey.currentContext;
    if (ctx != null && ctx.mounted) {
      // ignore: unawaited_futures
      showMoodCheckIn(ctx, initialLevel: 4);
      await Future<void>.delayed(const Duration(milliseconds: 1500));
      debugPrint('CAPTURE:mood_sheet');
      await Future<void>.delayed(_hold);
    }
  }
  debugPrint('CAPTURE_DONE');
}

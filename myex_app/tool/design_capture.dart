// Design QA harness (dev only, never shipped): boots the app in demo mode and
// walks every route so the rendered screens can be captured on a simulator.
//
//   flutter run -d <simulator> -t tool/design_capture.dart
//
// For each screen it prints `CAPTURE:<name>` and holds still for [_hold], so a
// watcher script can run `xcrun simctl io booted screenshot <name>.png`.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myex_app/app.dart';
import 'package:myex_app/core/router/app_router.dart';
import 'package:myex_app/demo/demo_mode.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _hold = Duration(milliseconds: 3500);

const _routes = <String, String>{
  'onboarding': Routes.onboarding,
  'plan_ready': Routes.planReady,
  'paywall': Routes.paywall,
  'welcome_trial': '/welcome?trial=1',
  'home': Routes.home,
  'plan': Routes.plan,
  'plan_day_1': '/plan/day/1',
  'plan_day_done': '/plan/day/1/done',
  'coach': Routes.coach,
  'me': Routes.me,
  'sos': Routes.sos,
  'drafts': Routes.drafts,
  'coins': Routes.coins,
  'trial': Routes.trial,
  'winback': Routes.winback,
};

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final container = ProviderContainer(overrides: demoOverrides(prefs));
  runApp(
    UncontrolledProviderScope(container: container, child: const MyExApp()),
  );
  await Future<void>.delayed(const Duration(seconds: 4));
  final router = container.read(appRouterProvider);
  for (final e in _routes.entries) {
    router.go(e.value);
    await Future<void>.delayed(const Duration(milliseconds: 1800));
    debugPrint('CAPTURE:${e.key}');
    await Future<void>.delayed(_hold);
  }
  debugPrint('CAPTURE_DONE');
}

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/app/app_overlay.dart';
import '../core/config/env.dart';
import '../core/router/app_router.dart';
import '../core/supabase/supabase_providers.dart';
import '../features/coach/application/coach_controller.dart';
import '../features/draft_jail/data/draft_repository.dart';
import '../features/journal/data/journal_repository.dart';
import '../features/lifecycle/data/lifecycle_repository.dart';
import '../features/monetization/application/monetization_providers.dart';
import '../features/no_contact/data/no_contact_repository.dart';
import '../features/onboarding/application/onboarding_controller.dart';
import '../features/plan/application/plan_progress.dart';
import '../features/subscription/data/subscription_repository.dart';
import 'demo_purchases.dart';
import 'demo_repositories.dart';
import 'demo_ui.dart';

/// DEMO MODE: try the whole app with no Supabase / RevenueCat keys.
///
/// Active when built with `--dart-define=DEMO=true`, or automatically when
/// the required env config is missing. NEVER active in a release build that
/// has a real config, even if DEMO=true is passed by mistake.
abstract final class DemoMode {
  static const _flag = bool.fromEnvironment('DEMO');

  static bool get isActive => resolve(
    flag: _flag,
    configComplete: Env.missingRequired.isEmpty,
    release: kReleaseMode,
  );

  /// Pure rule (unit tested).
  static bool resolve({
    required bool flag,
    required bool configComplete,
    required bool release,
  }) {
    if (!configComplete) return true;
    if (release) return false;
    return flag;
  }
}

/// Every provider that would reach Supabase or RevenueCat, replaced by an
/// in-memory fake. Only `main.dart` calls this, and only in demo mode.
List<Override> demoOverrides(SharedPreferences prefs) {
  String lang(Ref ref) =>
      ref.read(appLocaleProvider)?.languageCode ??
      ref.read(onboardingProvider).language ??
      'en';

  return [
    sharedPreferencesProvider.overrideWithValue(prefs),
    // Safety net: a client that points nowhere. Any call a fake missed fails
    // like an offline request instead of crashing.
    supabaseClientProvider.overrideWithValue(
      SupabaseClient(
        'https://demo.invalid',
        'demo-key',
        // No session in demo: don't start GoTrue's refresh timer.
        authOptions: const AuthClientOptions(autoRefreshToken: false),
      ),
    ),
    authUserIdProvider.overrideWith((ref) => Stream.value('demo-user')),
    appOverlayProvider.overrideWithValue(
      (context, child) => DemoPill(child: child ?? const SizedBox.shrink()),
    ),
    purchasesRepositoryProvider.overrideWith(
      (ref) => DemoPurchasesRepository(
        ref.watch(demoStoreProvider),
        confirm: (req) async {
          final ctx = ref
              .read(appRouterProvider)
              .routerDelegate
              .navigatorKey
              .currentContext;
          if (ctx == null || !ctx.mounted) return false;
          return showDemoPurchaseSheet(ctx, req);
        },
      ),
    ),
    walletRepositoryProvider.overrideWith(
      (ref) => DemoWalletRepository(ref.watch(demoStoreProvider)),
    ),
    coachRepositoryProvider.overrideWith(
      (ref) => DemoCoachRepository(
        ref.watch(demoStoreProvider),
        language: () => lang(ref),
      ),
    ),
    planRepositoryProvider.overrideWith(
      (ref) => DemoPlanRepository(
        ref.watch(demoStoreProvider),
        language: () => lang(ref),
      ),
    ),
    draftRepositoryProvider.overrideWith(
      (ref) => DemoDraftRepository(ref.watch(demoStoreProvider)),
    ),
    lifecycleRepositoryProvider.overrideWith(
      (ref) => DemoLifecycleRepository(ref.watch(demoStoreProvider)),
    ),
    onboardingRepositoryProvider.overrideWithValue(DemoOnboardingRepository()),
    cancelSurveyLogProvider.overrideWithValue(DemoCancelLog()),
    journalRepositoryProvider.overrideWith(
      (ref) => DemoJournalRepository(ref.watch(demoStoreProvider)),
    ),
    noContactRepositoryProvider.overrideWith(
      (ref) => DemoNoContactRepository(ref.watch(demoStoreProvider)),
    ),
  ];
}

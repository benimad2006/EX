import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/coach/domain/chat_origin.dart';
import '../../features/coach/presentation/coach_screen.dart';
import '../../features/draft_jail/presentation/draft_jail_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/home/presentation/home_shell.dart';
import '../../features/insights/presentation/insights_screen.dart';
import '../../features/journal/domain/journal_entry.dart';
import '../../features/journal/presentation/journal_entry_screen.dart';
import '../../features/journal/presentation/journal_screen.dart';
import '../../features/lifecycle/presentation/trial_status_screen.dart';
import '../../features/lifecycle/presentation/winback_screen.dart';
import '../../features/me/presentation/me_screen.dart';
import '../../features/monetization/domain/paywall_offer.dart';
import '../../features/monetization/presentation/coins_store_screen.dart';
import '../../features/monetization/presentation/paywall_screen.dart';
import '../../features/monetization/presentation/plan_ready_screen.dart';
import '../../features/monetization/presentation/welcome_screen.dart';
import '../../features/no_contact/presentation/no_contact_screen.dart';
import '../../features/onboarding/application/onboarding_controller.dart';
import '../../features/onboarding/presentation/onboarding_quiz_screen.dart';
import '../../features/plan/presentation/daily_task_screen.dart';
import '../../features/plan/presentation/plan_screen.dart';
import '../../features/sos/presentation/sos_screen.dart';
import '../design/design.dart';

abstract final class Routes {
  static const onboarding = '/onboarding';
  static const planReady = '/plan-ready';
  static const paywall = '/paywall';
  static const welcome = '/welcome';
  static const home = '/home';
  static const plan = '/plan';
  static const coach = '/coach';
  static const me = '/me';
  static const sos = '/sos';
  static const sosChat = '/sos/chat';
  static const coins = '/coins';
  static const drafts = '/drafts';
  static const trial = '/trial';
  static const winback = '/winback';
  static const sosDraft = '/sos/draft';
  static const journal = '/journal';
  static const noContact = '/no-contact';
  static const insights = '/insights';

  /// Journal editor: an existing entry ([id]) or a new one, optionally of a
  /// [kind] and answering a guided [prompt].
  static String journalEntry({String? id, String? kind, String? prompt}) => Uri(
    path: '/journal-entry',
    queryParameters: {'id': ?id, 'kind': ?kind, 'prompt': ?prompt},
  ).toString();

  /// SOS with its entry point, for the sos_opened safety metric.
  static String sosFrom(String from) => '$sos?from=$from';
  static String planDay(int day) => '/plan/day/$day';
  static String planDayDone(int day) => '/plan/day/$day/done';
  static String paywallFor(PaywallTrigger t) => '$paywall?trigger=${t.name}';
  static String welcomeFor({required bool trial}) =>
      '$welcome?trial=${trial ? 1 : 0}';
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final a = ref.read(onboardingProvider);
  // Retry a quiz save that failed offline.
  Future.microtask(() => ref.read(onboardingProvider.notifier).syncIfPending());
  return GoRouter(
    initialLocation: a.completed
        ? Routes.home
        : a.quizDone
        ? Routes.planReady
        : Routes.onboarding,
    routes: [
      GoRoute(
        path: Routes.onboarding,
        builder: (context, state) =>
            const PresentingScale(child: OnboardingQuizScreen()),
      ),
      GoRoute(
        path: Routes.planReady,
        builder: (context, state) =>
            const PresentingScale(child: PlanReadyScreen()),
      ),
      GoRoute(
        path: Routes.paywall,
        pageBuilder: (context, state) => MaterialPage(
          fullscreenDialog: true,
          child: PresentingScale(
            child: PaywallScreen(
              trigger: PaywallTrigger.parse(
                state.uri.queryParameters['trigger'],
              ),
            ),
          ),
        ),
      ),
      GoRoute(
        path: Routes.welcome,
        builder: (context, state) => PresentingScale(
          child: WelcomeScreen(
            isTrial: state.uri.queryParameters['trial'] == '1',
          ),
        ),
      ),
      // SOS lives OUTSIDE the tab shell: no coin chip, no premium chip,
      // no paywall entry points (M0 hard rule 1).
      GoRoute(
        path: Routes.sos,
        pageBuilder: (context, state) => MaterialPage(
          fullscreenDialog: true,
          child: PresentingScale(
            child: SosScreen(from: state.uri.queryParameters['from']),
          ),
        ),
        routes: [
          // Draft Jail from SOS: never limited, never upsold.
          GoRoute(
            path: 'draft',
            builder: (context, state) => const PresentingScale(
              child: DraftJailScreen(origin: ChatOrigin.sos),
            ),
          ),
          GoRoute(
            path: 'chat',
            builder: (context, state) => const PresentingScale(
              child: CoachScreen(origin: ChatOrigin.sos),
            ),
          ),
        ],
      ),
      // Plan day screens are pushed above the tab bar (full screen).
      GoRoute(
        path: '/plan/day/:day',
        builder: (context, state) => PresentingScale(
          child: DailyTaskScreen(
            day: int.tryParse(state.pathParameters['day'] ?? '') ?? 1,
          ),
        ),
        routes: [
          GoRoute(
            path: 'done',
            builder: (context, state) => PresentingScale(
              child: DayCompleteScreen(
                day: int.tryParse(state.pathParameters['day'] ?? '') ?? 1,
              ),
            ),
          ),
        ],
      ),
      GoRoute(
        path: Routes.trial,
        builder: (context, state) =>
            const PresentingScale(child: TrialStatusScreen()),
      ),
      GoRoute(
        path: Routes.winback,
        pageBuilder: (context, state) => const MaterialPage(
          fullscreenDialog: true,
          child: PresentingScale(child: WinbackScreen()),
        ),
      ),
      GoRoute(
        path: Routes.drafts,
        builder: (context, state) => const PresentingScale(
          child: DraftJailScreen(origin: ChatOrigin.normal),
        ),
      ),
      GoRoute(
        path: '/journal-entry',
        pageBuilder: (context, state) {
          final q = state.uri.queryParameters;
          return MaterialPage(
            fullscreenDialog: q['id'] == null,
            child: PresentingScale(
              child: JournalEntryScreen(
                id: q['id'],
                kind: q['kind'] == null ? null : JournalKind.parse(q['kind']),
                prompt: q['prompt'],
              ),
            ),
          );
        },
      ),
      GoRoute(
        path: Routes.noContact,
        builder: (context, state) =>
            const PresentingScale(child: NoContactScreen()),
      ),
      GoRoute(
        path: Routes.insights,
        builder: (context, state) =>
            const PresentingScale(child: InsightsScreen()),
      ),
      GoRoute(
        path: Routes.coins,
        builder: (context, state) =>
            const PresentingScale(child: CoinsStoreScreen()),
      ),
      // Tabs keep their state and switch with a 180ms crossfade (spec N1/N3).
      StatefulShellRoute(
        builder: (context, state, shell) =>
            PresentingScale(child: HomeShell(shell: shell)),
        navigatorContainerBuilder: (context, shell, children) =>
            FadeIndexedStack(index: shell.currentIndex, children: children),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.home,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.plan,
                builder: (context, state) => const PlanScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.coach,
                builder: (context, state) =>
                    const CoachScreen(origin: ChatOrigin.normal),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.journal,
                builder: (context, state) => const JournalScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.me,
                builder: (context, state) => const MeScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

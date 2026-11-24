import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design/design.dart';
import '../../../core/notifications/notification_service.dart';
import '../../../core/router/app_router.dart';
import '../../../core/supabase/supabase_providers.dart';
import '../../../core/util/context_x.dart';
import '../../lifecycle/application/trial_reminder_service.dart';
import '../../lifecycle/domain/reminder_plan.dart';
import '../../onboarding/application/onboarding_controller.dart';
import '../application/monetization_providers.dart';
import '../domain/monetization_ids.dart';

/// Polls the ledger briefly so "+50 coins added" is only claimed once the
/// server confirms the credit; otherwise "on the way".
final _bonusConfirmedProvider = FutureProvider.autoDispose<bool>((ref) async {
  final wallet = ref.watch(walletRepositoryProvider);
  for (var i = 0; i < 6; i++) {
    try {
      if (await wallet.premiumBonusCreditedThisMonth()) return true;
    } catch (_) {
      // keep polling
    }
    await Future<void>.delayed(const Duration(seconds: 2));
    if (!ref.mounted) return false;
  }
  return false;
});

/// After any successful premium purchase (spec S8 / M5): the night mark bounces in
/// (the only staggered entrance in the app), what unlocked, the trial date,
/// then straight to the plan. No confetti, crown or glow.
class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key, required this.isTrial});
  final bool isTrial;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final name = ref.watch(onboardingProvider).name;
    final remind = ref.watch(remindTrialProvider);
    final premium = ref.watch(premiumProvider).value;
    final bonus = ref.watch(_bonusConfirmedProvider).value ?? false;
    const coins = MonetizationDisplay.premiumMonthlyBonusCoins;
    final trialEnd = isTrial ? premium?.expiresAt : null;

    // Only promise a reminder once it is actually scheduled (see the
    // pre-prompt card below); until then, state the end date plainly.
    final reminded = ref.watch(_reminderScheduledProvider);
    final String sub;
    if (trialEnd == null) {
      sub = l.welcomeSubPaid;
    } else if (remind && reminded) {
      sub = l.welcomeSubTrialRemind(
        context.shortDate(trialEnd.subtract(const Duration(days: 2))),
      );
    } else {
      sub = l.welcomeSubTrial(context.shortDate(trialEnd));
    }

    final items = [
      l.welcomeAll30,
      l.welcomeMira,
      l.welcomeAnalysis,
      bonus ? l.welcomeCoinsAdded(coins) : l.welcomeCoinsPending(coins),
    ];

    return Scaffold(
      body: ScreenBackground(
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: kScreenPadding.copyWith(top: MyExSpacing.s6),
                  children: [
                    const Center(child: NightMark(entrance: true)),
                    const Gap(MyExSpacing.s4),
                    DisplayText(
                      name == null
                          ? l.welcomeTitleNoName
                          : l.welcomeTitle(name),
                    ),
                    const Gap(MyExSpacing.s2),
                    Text(
                      sub,
                      textAlign: TextAlign.center,
                      style: MyExType.body.copyWith(color: MyExColors.ink2),
                    ),
                    const Gap(MyExSpacing.section),
                    InsetGroup(
                      children: [
                        for (var i = 0; i < items.length; i++)
                          _Staggered(
                            index: i,
                            child: ListRow(
                              title: items[i],
                              chevron: false,
                              leading: Icon(
                                MyExIcons.check,
                                color: MyExColors.success,
                                size: MyExSizes.iconMd,
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (trialEnd != null && remind && !reminded)
                      Padding(
                        padding: const EdgeInsets.only(
                          top: MyExSpacing.section,
                        ),
                        child: _ReminderPrePrompt(trialEnd: trialEnd),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: kScreenPadding.copyWith(
                  top: MyExSpacing.s3,
                  bottom: MyExSpacing.s2,
                ),
                child: Column(
                  children: [
                    PrimaryButton(
                      label: l.welcomeCta,
                      onPressed: () => context.go(Routes.plan),
                    ),
                    const Gap(MyExSpacing.s2),
                    Footnote(l.welcomeFine),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 60ms-stepped fade-in for the Welcome list rows (off under Reduce Motion).
class _Staggered extends StatelessWidget {
  const _Staggered({required this.index, required this.child});
  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (MyExMotion.of(context).reduced) return child;
    const step = 60;
    const fade = 300;
    final total = Duration(milliseconds: fade + step * index);
    final start = (step * index) / total.inMilliseconds;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: total,
      curve: Interval(start, 1, curve: MyExCurves.easeOut),
      builder: (context, t, child) => Opacity(opacity: t, child: child),
      child: child,
    );
  }
}

/// True once the trial reminder is scheduled from this screen.
final _reminderScheduledProvider = StateProvider.autoDispose<bool>(
  (ref) => false,
);

/// Honest in-app pre-prompt before the iOS permission dialog (M7): asked
/// here, after purchase, only when "remind me" is on — never at launch.
class _ReminderPrePrompt extends ConsumerStatefulWidget {
  const _ReminderPrePrompt({required this.trialEnd});
  final DateTime trialEnd;

  @override
  ConsumerState<_ReminderPrePrompt> createState() => _ReminderPrePromptState();
}

class _ReminderPrePromptState extends ConsumerState<_ReminderPrePrompt> {
  static const _kPrompted = 'notif.prePrompted';
  bool _busy = false;
  bool _dismissed = false;

  @override
  void initState() {
    super.initState();
    _dismissed =
        ref.read(sharedPreferencesProvider).getBool(_kPrompted) ?? false;
  }

  Future<void> _allow() async {
    setState(() => _busy = true);
    final l = context.l10n;
    final remindDate = widget.trialEnd.subtract(const Duration(days: 2));
    final granted = await ref
        .read(notificationServiceProvider)
        .requestPermission()
        .catchError((Object _) => false);
    await ref.read(sharedPreferencesProvider).setBool(_kPrompted, true);
    if (!mounted) return;
    if (granted) {
      final premium = ref.read(premiumProvider).value;
      if (premium != null) {
        await ref
            .read(trialReminderServiceProvider)
            .sync(premium)
            .catchError((Object _) => const CancelReminder('error'));
      }
      if (!mounted) return;
      ref.read(_reminderScheduledProvider.notifier).state = true;
      showMyExToast(
        context,
        l.welcomeNotifOn(context.shortDate(remindDate)),
        success: true,
      );
    } else {
      showMyExToast(context, l.welcomeNotifDenied);
    }
    setState(() {
      _busy = false;
      _dismissed = true;
    });
  }

  Future<void> _notNow() async {
    await ref.read(sharedPreferencesProvider).setBool(_kPrompted, true);
    if (mounted) setState(() => _dismissed = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_dismissed) return const SizedBox.shrink();
    final l = context.l10n;
    final remindDate = widget.trialEnd.subtract(const Duration(days: 2));
    return SolidCard(
      key: const Key('welcome-notif-preprompt'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l.welcomeNotifTitle, style: MyExType.headline),
          const Gap(MyExSpacing.s1),
          Text(
            l.welcomeNotifBody(context.shortDate(remindDate)),
            style: MyExType.subheadline,
          ),
          const Gap(MyExSpacing.s3),
          GlassButton(
            label: l.welcomeNotifAllow,
            icon: MyExIcons.bell,
            busy: _busy,
            onPressed: _allow,
          ),
          TextLinkButton(
            label: l.commonNotNow,
            tone: TextLinkTone.muted,
            onPressed: _busy ? null : _notNow,
          ),
        ],
      ),
    );
  }
}

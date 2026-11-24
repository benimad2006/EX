import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/design/design.dart';
import '../core/router/app_router.dart';
import '../core/supabase/supabase_providers.dart';
import '../features/home/application/streak.dart';
import '../features/journal/data/journal_repository.dart';
import '../features/monetization/application/monetization_providers.dart';
import '../features/monetization/domain/paywall_offer.dart';
import '../features/no_contact/data/no_contact_repository.dart';
import '../features/onboarding/application/onboarding_controller.dart';
import '../features/plan/application/plan_progress.dart';
import 'demo_purchases.dart';
import 'demo_store.dart';

// DEMO MODE ONLY. Developer tooling: strings are English on purpose and live
// here, not in the ARB files, because none of this ships in a real build.

final demoStoreProvider = Provider<DemoStore>((ref) => DemoStore());

/// Simulated App Store purchase sheet: Confirm (success) or Cancel.
Future<bool> showDemoPurchaseSheet(
  BuildContext context,
  DemoPurchaseRequest r,
) async {
  final ok = await showGlassSheet<bool>(
    context: context,
    semanticLabel: 'Demo purchase',
    builder: (ctx) => Column(
      key: const Key('demo-purchase-sheet'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Footnote(
          'Demo purchase · no real money',
          icon: Icons.science_outlined,
        ),
        const Gap(MyExSpacing.s3),
        Text(r.title, style: MyExType.title2, textAlign: TextAlign.center),
        const Gap(MyExSpacing.s1),
        Text(r.price, style: MyExType.headline, textAlign: TextAlign.center),
        if (r.detail != null)
          Text(
            r.detail!,
            style: MyExType.subheadline,
            textAlign: TextAlign.center,
          ),
        const Gap(MyExSpacing.s6),
        PrimaryButton(
          key: const Key('demo-confirm'),
          label: 'Confirm Purchase',
          onPressed: () => Navigator.of(ctx).pop(true),
        ),
        TextLinkButton(
          key: const Key('demo-cancel'),
          label: 'Cancel',
          onPressed: () => Navigator.of(ctx).pop(false),
        ),
      ],
    ),
  );
  return ok ?? false;
}

/// Small "Demo" pill at the top of every screen. Tap → demo menu.
class DemoPill extends ConsumerWidget {
  const DemoPill({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final top = MediaQuery.paddingOf(context).top;
    return Stack(
      children: [
        child,
        Positioned(
          top: top,
          left: 0,
          right: 0,
          child: Center(
            child: GlassChip(
              key: const Key('demo-pill'),
              label: 'Demo',
              leading: const Icon(Icons.science_outlined),
              foreground: MyExColors.accentInk,
              semanticLabel: 'Demo mode. Open demo menu',
              onPressed: () {
                final ctx = ref
                    .read(appRouterProvider)
                    .routerDelegate
                    .navigatorKey
                    .currentContext;
                if (ctx != null) showDemoMenu(ctx, ref);
              },
            ),
          ),
        ),
      ],
    );
  }
}

/// Reset state, switch Free / Trial / Premium, and simulate time.
Future<void> showDemoMenu(BuildContext context, WidgetRef ref) {
  final store = ref.read(demoStoreProvider);
  void refresh() {
    ref
      ..invalidate(limitsProvider)
      ..invalidate(planStateProvider)
      ..invalidate(paywallOfferProvider)
      ..invalidate(noContactSinceProvider)
      ..invalidate(noContactProvider)
      ..invalidate(journalEntriesProvider)
      ..invalidate(moodEntriesProvider);
  }

  return showGlassSheet<void>(
    context: context,
    semanticLabel: 'Demo menu',
    builder: (ctx) => ListenableBuilder(
      listenable: store,
      builder: (ctx, _) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Demo menu', style: MyExType.title2),
          Text(
            'No Supabase or RevenueCat. Everything is fake and in memory.',
            style: MyExType.subheadline,
          ),
          const SectionHeader('Status'),
          InsetGroup(
            children: [
              for (final t in DemoTier.values)
                SelectRow(
                  key: Key('demo-tier-${t.name}'),
                  title: switch (t) {
                    DemoTier.free => 'Free',
                    DemoTier.trial => 'Free trial (7 days)',
                    DemoTier.monthly => 'Premium · Monthly',
                    DemoTier.annual => 'Premium · Yearly',
                  },
                  selected: store.isPremium
                      ? store.tier == t
                      : t == DemoTier.free,
                  onTap: () {
                    store.setTier(t);
                    refresh();
                  },
                ),
            ],
          ),
          const SectionHeader('Simulate'),
          InsetGroup(
            children: [
              ListRow(
                title: 'Trial/plan cancelled (won’t renew)',
                trailing: MyExSwitch(
                  value: store.isPremium && !store.willRenew,
                  onChanged: (_) => store.toggleWillRenew(),
                ),
              ),
              ListRow(
                title: 'Billing issue',
                trailing: MyExSwitch(
                  value: store.billingIssue,
                  onChanged: (_) => store.toggleBillingIssue(),
                ),
              ),
              ListRow(
                title: 'Paywall variant: Compare',
                trailing: MyExSwitch(
                  value: store.variant == PaywallVariant.compare,
                  onChanged: (v) {
                    store.variant = v
                        ? PaywallVariant.compare
                        : PaywallVariant.timeline;
                    store.changed();
                    refresh();
                  },
                ),
              ),
              ListRow(
                key: const Key('demo-fill-sample'),
                title: 'Fill sample weeks (moods, journal, no contact)',
                onTap: () {
                  store.fillSample(
                    turkish: ref.read(onboardingProvider).language == 'tr',
                  );
                  refresh();
                },
              ),
              ListRow(
                title: 'Add 50 coins',
                value: '${store.coins}',
                onTap: store.addCoins.bind(50),
              ),
              ListRow(
                title:
                    'Next day (limits reset, next plan day opens, drafts age)',
                onTap: () {
                  store.nextDay();
                  refresh();
                  ref.invalidate(authUserIdProvider);
                },
              ),
              ListRow(
                title: 'Premium lapsed → show Win-back',
                onTap: () {
                  store.simulateLapse();
                  refresh();
                  Navigator.of(ctx).pop();
                  ref.read(appRouterProvider).push(Routes.winback);
                },
              ),
              ListRow(
                title: 'Open Trial status',
                onTap: () {
                  Navigator.of(ctx).pop();
                  ref.read(appRouterProvider).push(Routes.trial);
                },
              ),
            ],
          ),
          const Gap(MyExSpacing.s4),
          TextLinkButton(
            key: const Key('demo-reset'),
            label: 'Reset Demo (start onboarding again)',
            tone: TextLinkTone.danger,
            onPressed: () async {
              store.reset();
              await ref.read(sharedPreferencesProvider).clear();
              refresh();
              if (ctx.mounted) Navigator.of(ctx).pop();
              ref
                ..invalidate(onboardingProvider)
                ..invalidate(appLocaleProvider)
                ..invalidate(remindTrialProvider)
                ..invalidate(appRouterProvider);
            },
          ),
        ],
      ),
    ),
  );
}

extension on void Function(int) {
  VoidCallback bind(int v) =>
      () => this(v);
}

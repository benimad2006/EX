# MyEx (Flutter · Supabase · RevenueCat)

Breakup-recovery iPhone app: AI coach Mira, 30-day plan, no-contact streak, SOS, Draft Jail,
coins + subscriptions. Source of truth: `../MyEx_Monetization_Prompts.md` (phases M0–MR) and
`../MyEx_Glass_Premium.html` (UX). Agent context: `CLAUDE.md`.

## Status

| Area | State |
|---|---|
| Flutter app (`lib/`) | `flutter analyze` 0 issues, `flutter test` 98 green. Runs on the iOS Simulator in demo mode (see "Run on the iOS Simulator"). Not tested on a physical device. |
| Demo mode (`lib/demo/`) | Runs the whole app with no keys (see "Demo / Android test build"). |
| Supabase migrations (`supabase/migrations/`, incl. `20261124000000_wellbeing`) | **UNTESTED.** Written without the Supabase CLI. Run `supabase db reset` first. |
| SQL tests (`supabase/tests/*.sql`) | **UNTESTED.** |
| Edge Functions (`supabase/functions/`) | **UNTESTED.** Written without Deno. Run `deno check` on each before deploying. |
| iOS `AppDelegate.swift` (Reduce Transparency channel, notification delegate) | **UNTESTED.** Needs Xcode. |

### Phases done
| Phase | What | Key files |
|---|---|---|
| Onboarding quiz (+ research R1, R2, R8, R9, R10, R20) | 13 steps: language, name, what happened, when, details (their name, length), contact, hardest time, Mira, mood + feelings, focus, 3 attachment statements, one unsent message (→ Draft Jail, doesn't use the daily free draft), check-in pre-prompt at the hardest time; then a ~4 s "Building your plan" that ticks through the real answers. SOS on every step. Saved to `onboarding_answers` (RLS). Plan ready shows every answer, the first 3 days and the hardest-time support row. | `lib/features/onboarding/`, migrations `…0000_onboarding`, `…0400_onboarding_v2` |
| Plan | 30-day catalog (teasers public, content gated by RLS), progress, 09:00-local time gate (one new day per day), Daily task (3 entries), Day complete, LockDaySheet (Premium or 15 coins via `spend_coins`). `currentPlanDayProvider` is real. IANA timezone via `flutter_timezone`. | `lib/features/plan/`, migration `…0100_plan` |
| Draft Jail | Lock 24 h, live countdown, unlock after 24 h, copy, delete forever (confirm). Free 1/day; Premium unlimited; **SOS never limited** (server bypass + UI rule). Reached from Home, Me and SOS. | `lib/features/draft_jail/`, migration `…0200_draft_jail` |
| M7 | Trial reminder (48 h before end, clamped 10:00–20:00 and never later than 48 h; value recap; cancelled on convert/cancel/expiry; reschedules on foreground), Trial status, Win-back (promo offer, once, 7–14 days after lapse), billing-issue banner, honest pre-prompt on Welcome (skipped if already asked in onboarding). | `lib/features/lifecycle/`, `lib/core/notifications/`, migration `…0300_lifecycle` |
| M8 | Me = subscription hub; cancel survey (price → save-50 promo or switch to yearly, better → celebrate, unused → nightly check-in, other → note). "Continue to Cancel" always opens App Store management from the first frame. | `lib/features/me/`, `lib/features/subscription/`, `lib/features/checkins/` |
| M9 | Typed analytics facade with per-event allowlists (no free text can leave the app), debug sink + `[ANALYTICS_PROVIDER]` stub, wired to the funnel. KPI doc. | `lib/core/analytics/`, `docs/monetization/KPIS.md` |
| Design pass + wellbeing (2026-11-24) | Research in `docs/design/` (44 references, competitor analysis, moodboard, screen map, direction). Night "wine" theme (Me › Appearance: Automatic / Light / Night). New: **Journal** tab (prompts, unsent letters, search, kinds), **mood check-in** (5 levels + feeling words), **No contact** challenge (goal 7/30/60/90, milestones, "days you chose yourself" that never resets, kind restart with reflection), **Insights** (14-day mood line, week summary, counts). Home redesigned (hero, inline check-in, week dots); Coach gets the "AI · not therapy" label, starter prompts, New Conversation; Draft Jail empty state; Day complete ring. | `lib/features/{journal,no_contact,insights}/`, `lib/core/design/{wellbeing,theme_mode}.dart`, migration `20261124000000_wellbeing` |
| Paywall research items | R3 completed "Build your plan" step, R4 "No payment today", R5 honest reminder switch (notifications off → Open Settings), R13 "How do I cancel?", R14 billed price in the subtitle. | `lib/features/monetization/presentation/` |

## Demo / Android test build

Demo mode replaces Supabase + RevenueCat with in-memory fakes (`lib/demo/`): auth, profile, plan
progress, Draft Jail, coins, limits, Mira (canned replies with a typing delay), and offerings with the
prototype's example prices ($49.99/year with a 7-day trial, $12.99/month, $24.99 exit offer, coin packs
$2.99 / $6.99 / $14.99). Purchases open a simulated store sheet (Confirm = success, Cancel = cancelled).
A **Demo** pill at the top of every screen opens the demo menu: switch Free / Trial / Premium monthly /
yearly, mark the plan as cancelled, toggle a billing issue, switch the paywall A/B variant, add coins,
**Next day** (limits reset, the next plan day opens, drafts age a day), simulate a lapse (Win-back), and
reset everything (back to onboarding). State lives in memory, so it resets when the app restarts.

When it's on: `--dart-define=DEMO=true`, or automatically when the env config is missing. It is **never**
on in a release build that has a real config (`DemoMode.resolve`, unit tested).

```bash
# Android APK for sideloading (no keys needed):
flutter build apk --release --dart-define=DEMO=true
# → build/app/outputs/flutter-apk/app-release.apk
```

Android notes: minSdk 24, compileSdk 36 (install Android SDK Platform 36), core library desugaring
(flutter_local_notifications), INTERNET + POST_NOTIFICATIONS + RECEIVE_BOOT_COMPLETED permissions,
notification receivers, and `<queries>` for https/tel/mailto are in place. The release APK is signed
with the debug key (fine for sideloading; set up a real keystore before any store upload). iOS-only code
is guarded: the Reduce Transparency channel falls back to `false`, "Open Settings" is hidden on Android,
haptics are cross-platform, and the cancel steps show Play Store wording on Android.

## Decisions pending (founder)
- **R6, exit offer.** The research suggests keeping the free trial in the exit offer: a separate
  `myex_premium_annual_offer` at $29.99/year with a 7-day trial, copy "Still free to try, for less."
  Not implemented (it's a new paid product). The current pay-up-front `myex_annual_intro_50` stays; a
  `TODO(founder)` marks the spot in `exit_offer_sheet.dart`.
- **"Your conversations stay private."** on the paywall: chats are stored in Supabase and sent to the
  LLM provider. Check the wording against the privacy policy.

## Next
- Server push backup for the trial reminder and win-back (`lifecycle-push` + `notification_log`, M7 §3).
- Sign in with Apple linked to the anonymous user; account deletion.
- Analysis feature (+ its lock sheet) and the journal.
- Research items not done yet: R11 "Your 30-day promise" (hold Lumi), R15 first-week recap card on trial
  day 5, R16 lock-day preview lines, R17 real social-proof slot (off until real numbers exist), R18
  timeline-first paywall (variant C), R19 annual win-back card, R21 "note from Day 30 you", R22 7- vs
  14-day trial test, R23 "How did you hear about MyEx?" after purchase. R7 was done by the coordinator.
- Play Billing setup in RevenueCat if Android ships (the app is iPhone-first).
- A native speaker should proofread all Turkish copy (ARB + plan seed).

## Placeholders

Replace these before release. App-side values go in `env/dev.json` / `env/prod.json` (copy `env/example.json`,
git-ignored). Server-side values are Supabase secrets. **Never** put a server secret in `env/*.json`.

| Placeholder | Where it goes | What it is |
|---|---|---|
| `[BUNDLE_ID]` | Xcode › Runner › Signing (currently `com.example.myexApp`); Android `applicationId`/`namespace` (`com.example.myex_app`) | iOS bundle id, e.g. `app.myex.ios` |
| `[APP_STORE_APP_ID]` | App Store Connect, RevenueCat | Numeric Apple app id |
| `[SUPABASE_URL]` | `env/*.json` → `SUPABASE_URL` | `https://[SUPABASE_PROJECT_REF].supabase.co` |
| `[SUPABASE_PUBLISHABLE_KEY]` | `env/*.json` → `SUPABASE_PUBLISHABLE_KEY` | Publishable (or legacy anon) key. Public by design. |
| `[SUPABASE_PROJECT_REF]` | CLI `supabase link`, RevenueCat webhook URL | Project ref |
| `[RC_API_KEY_IOS]` | `env/*.json` → `RC_API_KEY_IOS` | RevenueCat **public** Apple SDK key `appl_…` |
| `[RC_SECRET_API_KEY]` | `supabase secrets set REVENUECAT_SECRET_API_KEY=…` | RevenueCat secret key. Server only. |
| `[RC_WEBHOOK_AUTH]` | `supabase secrets set REVENUECAT_WEBHOOK_AUTH=…` + RevenueCat webhook header | `openssl rand -hex 32` |
| `[ANTHROPIC_API_KEY]` | `supabase secrets set ANTHROPIC_API_KEY=…` | LLM key for `mira-chat`. Server only. |
| `[TERMS_URL]`, `[PRIVACY_URL]` | `env/*.json` | Hosted EULA + privacy policy |
| `[SUPPORT_EMAIL]` | `env/*.json` | Shown in Me |
| `[EMERGENCY_TR]`, `[EMERGENCY_US]`, `[HELPLINE_TR]`, `[HELPLINE_US]` | `env/*.json` (app) **and** Supabase secrets `EMERGENCY_*`/`HELPLINE_*` (SOS prompt) | Defaults: 112 / 911 / (none) / 988. **Verify every number with official sources before release.** |

## Run on the iOS Simulator

Verified on macOS with Flutter 3.44, Xcode and an iPhone 17 simulator (iOS 26.5). No keys are needed:
with no `env/dev.json` the app starts in **demo mode** (in-memory fakes, a Demo pill on every screen).

```bash
cd myex_app
flutter pub get
open -a Simulator                       # or boot one: xcrun simctl boot "iPhone 17"
flutter devices                         # copy the simulator id
flutter run -d <simulator-id>           # add --no-resident for build + install + exit (no hot reload)
```

Real backend instead of demo mode: `cp env/example.json env/dev.json`, fill it in, then
`flutter run -d <simulator-id> --dart-define-from-file=env/dev.json`.

The first build takes a few minutes (`pod install` + a full Xcode build); later ones take about a minute.
In a `flutter run` session: `r` hot reload, `R` hot restart, `q` quit.

### Design QA screenshots

`tool/design_capture.dart` walks every route in demo mode (empty states first, then the demo "sample weeks", then
the mood sheet) and prints `CAPTURE:<name>` for each screen, so a script can run
`xcrun simctl io <device> screenshot <name>.png`. Limit it with `--dart-define=ONLY=home,journal`.
Switch the simulator theme with `xcrun simctl ui <device> appearance dark`.

```bash
flutter run -d <simulator-id> -t tool/design_capture.dart
```

### Troubleshooting

| Symptom | Fix |
|---|---|
| `Could not resolve package dependencies … purchases-hybrid-common 20.9.0` (Swift Package Manager) | Turn SPM off so Flutter uses CocoaPods: `flutter config --no-enable-swift-package-manager`. This is a global Flutter setting. Undo it with `flutter config --enable-swift-package-manager`. |
| `Method not found: 'CupertinoPageTransitionsBuilder'` | Flutter 3.44 no longer re-exports Cupertino from `material.dart`. `navigation.dart` imports `package:flutter/cupertino.dart` explicitly. Do the same for any other Cupertino symbol. |
| Build killed (exit 137) or very slow | Close other heavy apps and re-run. Run it in the background and log to a file. Pods are cached after the first build. |
| Pod or Xcode errors after a Flutter or plugin upgrade | `flutter clean && flutter pub get`, then `cd ios && pod install --repo-update`. |

Pods print an `IPHONEOS_DEPLOYMENT_TARGET is set to 11.0` warning (from `flutter_timezone`) and RevenueCat
deprecation warnings. Both are harmless.

## Run

```bash
flutter pub get
flutter gen-l10n            # also runs automatically on build
cp env/example.json env/dev.json   # fill in real values
flutter run --dart-define-from-file=env/dev.json
flutter analyze && flutter test
```

Without the required defines the app starts in demo mode (see "Demo / Android test build").

Changing the org/bundle id later: edit `PRODUCT_BUNDLE_IDENTIFIER` in `ios/Runner.xcodeproj/project.pbxproj`
(or in Xcode) and `applicationId`/`namespace` in `android/app/build.gradle.kts`.

## Structure

```
lib/
  main.dart, app.dart        bootstrap (or demo) → ProviderScope → MaterialApp.router
  core/
    design/                  ← ALL visual decisions (tokens, typography, motion, glass, navigation, components, theme)
    analytics/               typed events + allowlists, sinks (debug, [ANALYTICS_PROVIDER] stub)
    notifications/           local notifications (trial reminder, check-ins), tap routing
    accessibility/           Reduce Transparency flag (MethodChannel "myex/accessibility")
    bootstrap/               Supabase init, anonymous sign-in, RevenueCat (appUserID = uid), IANA timezone
    config/env.dart          --dart-define values
    router/                  go_router: onboarding → plan ready → paywall → welcome; tab shell; SOS outside it
    app/app_overlay.dart     optional app-wide overlay (demo pill)
  features/
    onboarding/  plan/  draft_jail/  coach/  sos/  home/  me/
    journal/                 journal entries + mood check-ins (repository, sheet, editor)
    no_contact/              no-contact challenge (attempts, milestones, kind restart)
    insights/                14-day mood line, week summary
    monetization/            purchase layer, paywall, exit offer, welcome, coins, limit + lock-day sheets
    lifecycle/               trial reminder, trial status, win-back, coordinator
    subscription/            cancel survey        checkins/   nightly check-in
  demo/                      demo-mode fakes, store, simulated purchase sheet, menu (never in a real release)
  l10n/app_en.arb, app_tr.arb
supabase/
  migrations/  20261117…: core, monetization (M2) · 20261118…: onboarding, plan, draft_jail, lifecycle, onboarding_v2
  functions/   _shared, revenuecat-webhook, sync-purchases, mira-chat
  tests/       monetization_test.sql, plan_drafts_test.sql, wellbeing_test.sql
docs/monetization/KPIS.md
docs/design/                 design research, competitor analysis, moodboard, screen map, direction
tool/design_capture.dart     simulator screenshot harness (dev only)
```

## Design system (ported from `../MyEx_Design_Spec.md` §13)

All visual decisions live in `lib/core/design/`:

- `tokens.dart` — colours (one accent #D81B60 / #B0124F for small text, wine-tinted neutrals,
  the single hero gradient), radii, 4/8 spacing, sizes, glass recipe, sheet-presentation scale, shadows
- `typography.dart` — iOS Dynamic Type roles on the **system font** (SF Pro on iOS); Instrument Serif
  (bundled, upright) only for `display` and hero `numeral`s. Weights 400/600/700.
- `motion.dart` — smooth / snappy / bouncy springs (`SpringDescription` from SwiftUI response + damping,
  exposed as `SpringCurve`s), durations, press scales, Reduce Motion rules, haptics
- `glass.dart` — Liquid Glass surface (Reduce Transparency → solid), swell-on-press controls, floating tab bar
  with sliding capsule, SOS circle, sheets that scale the page behind to 0.94 (`PresentingScale`)
- `navigation.dart` — collapsing large titles + scroll-edge nav bar, tab crossfade, Reduce Motion page fades
- `components.dart` — grouped inset lists, flat cards, buttons, serif display text, Lumi (Plan ready, SOS,
  Welcome, Win-back only), Mira orb (faceless), Dynamic Island toast, day strip
- `theme.dart` — Material theme derived from the above

Fonts: `assets/fonts/FrauncesSoft-SemiBold.ttf` (the brand serif since 2026-11-24: a static instance of Fraunces at
opsz 72 / wght 620 / SOFT 100, OFL, license in `assets/fonts/OFL-Fraunces.txt`) and the older
`InstrumentSerif-Regular.ttf` (OFL, `assets/fonts/OFL.txt`, no longer used by the theme).
Illustrations (night sky, moon, dreamer figure, medallions) are drawn in code in `lib/core/design/art.dart`.
Lumi is drawn by `_LumiPainter` in `components.dart`; replace it when final artwork exists.

## Manual setup

### 1. App Store Connect ([BUNDLE_ID], [APP_STORE_APP_ID])
Full checklist is phase M1 (`docs/monetization/STORE_SETUP.md`, not written yet). Minimum:
- [ ] Paid Apps agreement active (sandbox purchases fail silently otherwise).
- [ ] In-App Purchase capability on the App ID and in Xcode › Signing & Capabilities.
- [ ] Subscription group "MyEx Premium" (EN + TR names):
  `myex_premium_annual` (1 year, intro: free trial 1 week), `myex_premium_monthly` (1 month),
  `myex_annual_intro_50` (1 year, intro: pay up front 1 year at the exit-offer price).
  Promotional offers: `save50_annual` (annual), `winback_3m` (monthly). Billing grace period ON. Family Sharing: decide (OFF for v1).
- [ ] Consumables `coins_30`, `coins_80`, `coins_200` (EN + TR display names).
- [ ] App Store Server Notifications V2 → the RevenueCat-provided URL (production + sandbox).
- [ ] Two sandbox testers (EN storefront, TR storefront).
- [ ] Prices are set **only** here, never in code.

### 2. RevenueCat
- [ ] Project "MyEx" › App Store app with [BUNDLE_ID]; upload the In-App Purchase Key (.p8) + issuer id + key id.
- [ ] Import the 6 products. Entitlement `premium` ← the 3 subscriptions (not the coins).
- [ ] Offerings: `default` ($rc_annual + $rc_monthly, metadata `{"paywall_variant":"timeline"}`, CURRENT),
  `default_compare` (same, `{"paywall_variant":"compare"}`), `exit_offer` ($rc_annual = `myex_annual_intro_50`),
  `winback` ($rc_monthly, `{"promo_offer_id":"winback_3m"}`), `coins` (custom packages `coins_30/80/200`,
  `{"popular":"coins_80","best_value":"coins_200"}`).
- [ ] Webhook: `https://[SUPABASE_PROJECT_REF].supabase.co/functions/v1/revenuecat-webhook`,
  Authorization `Bearer [RC_WEBHOOK_AUTH]`, production **and** sandbox.
- [ ] Keep the default transfer behavior (transfer to new App User ID).

### 3. Supabase
```bash
supabase login
supabase link --project-ref [SUPABASE_PROJECT_REF]
supabase db reset                     # LOCAL first: applies migrations
psql "<local db url>" -f supabase/tests/monetization_test.sql
supabase db push                      # remote
supabase secrets set \
  REVENUECAT_WEBHOOK_AUTH=[RC_WEBHOOK_AUTH] \
  REVENUECAT_SECRET_API_KEY=[RC_SECRET_API_KEY] \
  ANTHROPIC_API_KEY=[ANTHROPIC_API_KEY] \
  EMERGENCY_TR=[EMERGENCY_TR] EMERGENCY_US=[EMERGENCY_US] \
  HELPLINE_TR=[HELPLINE_TR] HELPLINE_US=[HELPLINE_US]
supabase functions deploy revenuecat-webhook --no-verify-jwt
supabase functions deploy sync-purchases
supabase functions deploy mira-chat
```
- [ ] Auth › Providers: enable **Anonymous sign-ins**, Apple, (Google), email.
- [ ] Database › Extensions: `pg_cron` enabled (the migration also runs `create extension if not exists pg_cron`).
- [ ] Realtime: `coin_wallets` is added to `supabase_realtime` by the migration; confirm in Database › Publications.
- [ ] Advisors › Security: no RLS warnings for the new tables.

### 4. Sign in with Apple (later phase; the app currently uses anonymous auth only)
- [ ] Apple Developer › Identifiers › [BUNDLE_ID] › enable Sign in with Apple; Xcode capability.
- [ ] Supabase › Auth › Providers › Apple: add the bundle id as client id (native sign-in).
- [ ] In the app, **link** the Apple identity to the existing anonymous user (`linkIdentity` / `signInWithIdToken`
  on the same session) so the RevenueCat appUserID (= Supabase uid) does not change.

### Edge Functions — manual checks (they are untested)
```bash
deno check supabase/functions/*/index.ts
# wrong token → 401
curl -i -X POST https://[SUPABASE_PROJECT_REF].supabase.co/functions/v1/revenuecat-webhook \
  -H "Authorization: Bearer wrong" -d '{}'
# RevenueCat dashboard › Webhooks › "Send test event" → 200 and a row in webhook_events
# Replay the same NON_RENEWING_PURCHASE twice → coins credited once (coin_ledger has one iap:<txn> row)
```

## VERIFY items (open)

- `mira-chat`: `fallbacks: "default"` + beta `server-side-fallback-2026-07-01` + `output_config.effort` on
  `anthropic.beta.messages.create` — confirm against the installed `@anthropic-ai/sdk` typings (cast to `any` for now).
- RevenueCat REST v1 subscriber field names (`entitlements`, `subscriptions`, `non_subscriptions[].store_transaction_id`)
  and webhook `transaction_id` = store transaction id.
- `storeProduct.pricePerWeekString` exists in purchases_flutter 11 but its rounding is undocumented, so the
  app computes per-week itself (rounded **up**). Derived prices borrow the currency symbol from StoreKit's
  `priceString` because intl renders TRY as "TL" while the App Store shows "₺".
- Timezone: resolved with flutter_timezone (IANA names sent at startup). The server still ignores more than one change per 24 h.
- flutter_local_notifications on iOS needs the delegate line in AppDelegate (added, untested on device).
- Swift Package Manager: with Flutter 3.44, SPM could not resolve purchases_flutter 11's `purchases-hybrid-common`
  20.9.0 (the tag exists upstream). CocoaPods works, so SPM is turned off (`flutter config --no-enable-swift-package-manager`).
- The exit-offer flag is marked "shown" before the sheet renders (server is authoritative; a crash at that instant loses the offer).

## Manual tests (not automatable here)
- 50 parallel `spend_coins` (pgbench) never drive a balance negative.
- Sandbox purchases EN + TR storefronts; Ask to Buy (StoreKit config file in Xcode); kill the app mid-purchase.
- Reduce Transparency ON → no blur anywhere; Reduce Motion ON → no breathing/celebration animation.
- VoiceOver on paywall plan cards (name, billed, per-week, trial, selected).

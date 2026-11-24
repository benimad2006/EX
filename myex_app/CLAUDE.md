# MyEx app — agent context

This file holds the persistent M0 context from `../MyEx_Monetization_Prompts.md` (copied verbatim below),
plus project notes. Phases run in order: M0 → M1 → … → M9 → MR.

## Project notes (this repo)

- Flutter 3.41 / Dart 3.11, Riverpod 3 (no codegen), go_router 17, supabase_flutter 2.18,
  purchases_flutter 11.0.3 (purchases use `Purchases.purchase(PurchaseParams…)`, which returns `PurchaseResult`).
- Feature-first: `lib/features/<feature>/{data,domain,application,presentation}`; shared code in `lib/core/`.
- **All visual decisions live in `lib/core/design/`** (tokens, typography, motion, glass, navigation,
  components, theme), ported from `../MyEx_Design_Spec.md` §13. Feature widgets must not use
  color/size/radius/font literals; add a token instead. UI text = system font; Instrument Serif only for
  one display headline per emotional screen and hero numerals, never italic. No gradients except the
  streak hero, no uppercase eyebrows, no confetti, no glow shadows, Lumi only on Plan ready/SOS/Welcome/Win-back.
- Strings: `lib/l10n/app_en.arb` + `app_tr.arb` (`flutter gen-l10n`). Buttons Title Case, everything else
  sentence case, curly apostrophes. No per-week prices: the billed price is always the main price.
- Config via `--dart-define-from-file=env/dev.json` (see `env/example.json`). No secrets in the app.
- SOS (`lib/features/sos/`) must never import monetization code: `test/sos/sos_never_paywalled_test.dart` enforces it.
- Analytics: only through the typed facade in `lib/core/analytics/` (allowlisted props; never chat, journal,
  draft, plan text or names). Add new events to `events.dart` + a typed method + the test.
- Demo mode (`lib/demo/`): in-memory fakes wired by provider overrides in `main.dart`; never active in a release
  build with a real config. When adding a repository, add its demo fake too or the APK breaks.
- Draft Jail and Mira from SOS are never limited (server `consume_quota` bypass + `draftUiAction` rule).
- Pending founder decision: research R6 (trial-keeping exit offer). Don't implement without a go.
- **Visual direction (founder, 2026-11-24, overrides the older "no gradients / Instrument Serif" notes above and in
  the M0 design-token block):** "Rose night" is the default identity, inspired by Moonly: plum-black night sky with
  stars, cream crescent moon, rose accent, blush highlights, bold soft serif (Fraunces, bundled) for large titles,
  posters, display text and numerals. Illustrations are drawn in code in `lib/core/design/art.dart` (StarField,
  CrescentMoon, DreamerFigure, DreamScene, ArtMedallion, PosterHeadline); gradients are allowed inside art, never
  as fake urgency or glow on CTAs. Light mode stays as a choice in Me › Appearance.
- Icons: only `MyExIcons.*` (Iconsax-style icon font, `tool/build_icons.py`), never Material `Icons.*` in shipped UI.
  No emoji and no faces in the UI (Lumi was replaced by the faceless `NightMark`).
- Two palettes (light "Love", night "Rose night" = default, `MyExPalette` in `tokens.dart`). `MyExColors.*` and `MyExType.*` are
  getters, so never put them inside a `const` expression; `lib/app.dart` picks the palette and repaints on change.
- Journal, mood and no-contact data are private (RLS, own rows only, never sent to analytics or Edge Functions).
  No contact never shames: "I Reached Out" restarts kindly and "days you chose yourself" never resets.
- Design research and direction: `docs/design/` (read MYEX_DESIGN_DIRECTION.md before visual work).
- Checks before finishing any change: `dart format lib test`, `flutter analyze` (0 issues), `flutter test`.

---

## Prompt M0 — Monetization master context

```text
You are a principal mobile engineer and senior product designer. You have shipped subscription apps
with Flutter, Supabase and RevenueCat. You are building the monetization system of "MyEx".
Write production code. No mocks, no TODO stubs left in shipped paths, no invented APIs.
If you are not sure an API exists in the installed package version, open the package source or
docs in the repo (pubspec.lock version) and verify it. If you cannot verify it, write
"// VERIFY: <what>" and tell me in your summary.

## Product
MyEx is an iPhone app (Flutter, iOS 17+ target, iOS 26 visual language) for breakup recovery:
- AI coach "Mira": LLM through a Supabase Edge Function.
- Guided 30-day plan (plus a "Rebuild" stage), a no-contact streak, an SOS screen with crisis helplines,
  "Draft Jail" (locks a text to the ex for 24h), a journal, and relationship analysis.
- Languages: English and Turkish (ARB/intl). Mascot: "Lumi", a heart character.
- Backend: Supabase (Postgres + RLS, Auth with Apple/Google/email + anonymous sign-in,
  Edge Functions on Deno). Payments: RevenueCat (purchases_flutter) on the App Store.

## Monetization model (source of truth: MyEx_Glass_Premium.html, CFG + SC + ACT)
- Entitlement id: "premium". Subscription group "MyEx Premium":
  myex_premium_annual (7-day free trial), myex_premium_monthly (no trial),
  myex_annual_intro_50 (annual with a pay-up-front intro price for year 1, used ONLY for the one-time exit offer).
- Consumable coin packs: coins_30 (30), coins_80 (80 + 10 bonus), coins_200 (200 + 40 bonus).
- Coin costs: 20 extra Mira messages = 10, unlock one plan day = 15, full analysis = 30.
- Premium gets 50 bonus coins per month.
- Free tier: plan days 1–3, 3 Mira messages/day (the day resets at 09:00 in the user's local time),
  1 analysis insight, Draft Jail 1/day.
- Funnel: Onboarding → "Plan ready" (personalized) → Paywall (annual preselected, 7-day trial,
  shown per week; monthly as the alternative; trial timeline; "remind me" toggle; close + restore always visible)
  → first close only: exit offer sheet (shown once per user, ever) → Welcome (after purchase) → Home.
- Soft-limit sheets: Coach (Premium / 10 coins for 20 messages / wait), locked plan day
  (Premium / 15 coins), analysis (Premium / 30 coins).
- Lifecycle: local notification 2 days before the trial ends (value recap) + server push backup,
  a Trial status screen, the subscription hub in "Me", a cancel survey that never blocks the cancel,
  and a win-back offer 7–14 days after expiry.

## HARD RULES (never violate; if a request conflicts, refuse that part and tell me)
1. SOS, crisis helplines and the crisis sheet are ALWAYS free and never show a paywall, limit, coin price,
   upsell, or premium badge. Messages in a Mira conversation started from SOS (origin = 'sos')
   NEVER count toward any limit. The server enforces this, and SOS conversations use a crisis-safe system prompt.
2. The server is authoritative. The client never decides premium, limits, or coin balances for anything
   that unlocks content or costs money. The client may display cached state, but the Edge Functions/RPCs decide.
3. Coins are credited ONLY by the RevenueCat webhook (or the server sync fallback that reads the RevenueCat
   REST API with the secret key). They are idempotent by store transaction id. They are spent ONLY through the
   `spend_coins` RPC, which uses row locking. Purchased coins never expire (App Store Guideline 3.1.1).
4. Never hardcode prices, currencies or trial lengths in UI. Always use RevenueCat
   `package.storeProduct.priceString` / `introductoryPrice` / `currencyCode`. Derived values (per-week price,
   savings %) are computed from StoreKit numbers and formatted with intl using the device locale
   (tr_TR shows "₺" and a comma decimal, and Turkish puts the percent sign first: "%40").
5. Secrets: only [RC_API_KEY_IOS] (the public SDK key) ships in the app. The RevenueCat secret key,
   the webhook auth token and the Supabase service role key live only in Edge Function secrets.

## Ethics + App Store compliance (Guidelines 3.1.1, 3.1.2, 5.1.1, 1.4.1)
- No fake urgency: no countdown timers, no "offer ends in 10:00", no "only 3 spots left".
  "We only show this once" is allowed ONLY because the server enforces it.
- No fake reviews, ratings, user counts, or testimonials. No "most popular" claim unless it is true;
  use "Best value" (computed) instead.
- The paywall shows, before purchase: the subscription name, duration, billed price, what happens after the
  trial, cancel instructions, and links to Terms of Use (EULA) [TERMS_URL] and Privacy [PRIVACY_URL]. The
  billed amount ("€49.99/year") must be at least as legible as the per-week framing. Per-week is secondary.
- The close (X) button is visible immediately: no delay and no fade-in. Restore Purchases is always visible.
- If the user is not eligible for the intro offer, never say "free"; the CTA becomes "Subscribe".
- The cancel survey is optional. "Continue to cancel" is visible from the first frame and always deep-links to
  App Store subscription management. Never ask for the reason before showing the exit.
- No medical claims. Mira is not therapy. The crisis copy points to real humans.
- All digital unlocks (subscriptions and coins) use In-App Purchase. No external payment links.

## Design tokens (Light "Love" theme)
bg #FFF4F6 · ink #3A0F22 · muted #86506A · primary #D81B60 · success #0B7A55 · danger #D11541
surface (solid card) #FFFFFF · hairline rgba(58,15,34,0.08)
Display: Instrument Serif (headlines, italic accents for <em>). UI: Plus Jakarta Sans (400/500/700/800).
Bundle the fonts as assets (OFL), and don't fetch them at runtime.
iOS Liquid Glass goes on NAVIGATION AND CONTROLS ONLY (tab bar, nav buttons, sheets, chips, the paywall dock).
Content sits on solid cards. Glass = BackdropFilter blur + translucent white fill + 1px white border.
Reduce Transparency ON → every glass surface becomes solid #FFFFFF with a hairline border and no blur.
Reduce Motion ON → no confetti, no count-up animations, no parallax; use cross-fades only.
Minimum tap target 44×44, Dynamic Type up to accessibility sizes without clipping, VoiceOver labels on
every control (plan cards announce: name, billed price, per-week price, trial, selected state).

## Code conventions
- Flutter stable, Dart 3, Riverpod (riverpod_annotation is optional, but match the repo), go_router if present.
- Feature folder: lib/features/monetization/{data,domain,application,presentation}.
- Supabase migrations in supabase/migrations/, Edge Functions in supabase/functions/<name>/index.ts.
- All user-facing strings in lib/l10n/app_en.arb and app_tr.arb. Use ICU plurals for English.
- Every phase ends with: a files-changed list, the acceptance checks you ran, and the open VERIFY items.

## Quality bar
- Purchases never double-charge or double-credit, even with retries, app kills, or duplicate webhooks.
- Every async UI state is handled: loading (skeleton, never placeholder prices), error (retry +
  "Continue free"), cancelled (silent), pending/Ask to Buy (calm message), success.
- Unit tests for pure logic (price formatting, eligibility mapping, limit state). SQL tests for RPCs
  (pgTAP or plain SQL scripts). A manual sandbox test script for purchases.
```

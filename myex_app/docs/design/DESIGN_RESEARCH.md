# MyEx: design research (Phase 0)

Date: 2026-11-24. This file is the entry point to the research set:

| File | What it holds |
|---|---|
| [DESIGN_REFERENCE_LIBRARY.md](DESIGN_REFERENCE_LIBRARY.md) | 44 references (36 fetched, 8 search-only or inaccessible), each flagged REAL PRODUCT or CONCEPT |
| [COMPETITOR_ANALYSIS.md](COMPETITOR_ANALYSIS.md) | 9 breakup apps, plus adjacent benchmarks and patterns across the category |
| [VISUAL_MOODBOARD.md](VISUAL_MOODBOARD.md) | The visual direction, with a reference behind each choice |
| [SCREEN_REFERENCE_MAP.md](SCREEN_REFERENCE_MAP.md) | Each MyEx screen mapped to the references that inspired it |
| [MYEX_DESIGN_DIRECTION.md](MYEX_DESIGN_DIRECTION.md) | The synthesized design language and what changes in code |

## Method

1. **Audited the real app.** It ran on the iOS Simulator (iPhone 17 Pro Max, iOS 26.5, demo mode).
   `tool/design_capture.dart` walks every route, and each screen was captured with
   `xcrun simctl io screenshot`.
2. **Read the existing spec.** `MyEx_Design_Spec.md` (critique and tokens) and `CLAUDE.md` (hard rules) are
   the primary design reference, and nothing here overrides them.
3. **Researched the web.** App Store listings, developer posts, Figma's Headspace Ebb case study, RevenueCat,
   Adapty and ScreensDesign paywall galleries, and concept portfolios.
4. **Took in the founder's inputs.** A ChatGPT conversation (pasted into the session) and three Dribbble shots:
   MindEase (26604818), Breakup Recovery App Design (26661492) and Kalito (27033580).

## Access limitations (honest list)

- **ChatGPT share link:** the page returns no conversation text to a script. Its content came from the text the
  founder pasted.
- **Dribbble:** every shot page, including the three the founder linked, returns an empty body or a bot-check page
  to scripted fetches. Shots are listed as SEARCH-ONLY: the title and URL are confirmed, the visuals are not.
- **Behance, Mobbin, uxdesign.cc:** 403. **Pinterest:** not attempted (login wall).
- **Three App Store listings returned 404:** Mended, No Contact Tracker & Move On, Celyo.
- **Text only:** no competitor screenshots were collected, and their palettes and typefaces are "not verified"
  unless a page stated them.

## Findings that drive the design

1. **Every competitor has the same features:** a streak, a panic button and an AI coach. Features alone don't
   differentiate MyEx (COMPETITOR_ANALYSIS, pattern 1).
2. **No breakup app claims a premium editorial look.** Design-led Editors' Choice apps (Stoic, How We Feel,
   Day One) win partly on design. The rose-and-serif identity has no direct competitor (LIBRARY, synthesis 6).
3. **Relapse framing matters.** Break no contact in a typical tracker and the counter goes back to zero. (Not Boring)
   Habits and Let it Go keep a metric that never resets. MyEx adds "days you chose yourself", which never resets,
   next to the strict streak.
4. **Mood: an emotion word beats a 1–5 face.** How We Feel's word check-in is the category leader. Daylio shows
   logging can take two taps. MyEx uses 5 levels plus emotion words, and never emoji faces.
5. **AI trust.** Always label the AI, keep "delete conversation" visible, never paywall part of a reply (Replika's
   top complaint), and keep a calm persona (Headspace Ebb).
6. **Liquid Glass belongs on controls.** Stoic ships "Liquid Glass controls", matching MyEx's rule that glass is
   for chrome only.
7. **Crisis tools stay free.** Competitors ration emergency sessions (NoContact) or lock dark mode behind Pro.
   MyEx's free SOS and free dark mode are trust signals.

## Screenshot audit (before), iPhone 17 Pro Max, light mode

| Screen | What works | What's weak |
|---|---|---|
| Onboarding | Clean grouped list, SOS on every step | Plain, little brand voice on step 1 |
| Plan ready | Serif headline, Lumi, real answers | Long list, so the first 3 days sit below the fold |
| Paywall | Honest hierarchy, billed price first | Dense: 3 benefits, plans, timeline and legal text compete |
| Home | Hero gradient, quiet upsell | Reads as a settings list. No mood check-in, no week view, no journal entry point. The hero has no numeral when the streak hasn't started |
| Plan | Week grouping, lock icons | 30 near-identical rows; weak progress (a 2pt bar) |
| Daily task | Calm, private note | Empty input boxes look like a form, not a ritual |
| Day complete | Clear | Grey check in a grey circle, flat, no warmth |
| Coach | Gentle opener | Empty canvas, the Mira header is hidden under the demo pill, no suggested prompts, no AI label |
| Me | Settings structure | Generic avatar, no theme setting, no data or privacy section |
| SOS | Strong: serif, Lumi, breathing | Good as is |
| Draft Jail | Works | No title; the empty state is one grey line |
| Coins | Big serif balance | Fine |
| Trial / Win-back | Honest | Zeros on Trial look empty: needs an empty-state voice |
| Global | Consistent tokens | **No dark mode at all.** No journal, no mood history, no progress view. The no-contact streak has no screen of its own |

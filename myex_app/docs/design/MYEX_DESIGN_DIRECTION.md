# MyEx: design direction

> **Update 2026-11-24 (founder):** the refined-rose result was too plain. The direction is now **"Rose night"**,
> inspired by the Moonly paywall (Pinterest reference shared by the founder): dark by default, a plum-black sky with
> stars, a cream crescent moon, an illustrated "dreamer" figure with flowing rose-to-lavender hair, a bold soft serif
> (Fraunces SemiBold, SOFT 100) for large titles and posters with the last words in blush, painted feature
> medallions, and blush plan cards. All art is drawn in code (`lib/core/design/art.dart`). Light mode stays
> available. The principles below still apply, except "no decorative gradients": gradients are allowed inside
> illustrations.

**Decision (founder, 2026-11-24):** refine the rose "Love" identity and add a night theme. The dark purple / Kalito
direction from the ChatGPT conversation was not chosen. `MyEx_Design_Spec.md` and the CLAUDE.md hard rules still
apply.

## One-line identity

*A private, beautifully set journal that happens to be smart:* rose on blush by day, rose on wine at night, serif
numbers that make progress feel personal.

## Principles

1. **One thing first.** Every screen has one primary action and one serif moment at most.
2. **Progress never resets to nothing.** The strict streak sits next to a forgiving count.
3. **Words over faces.** Feelings are named, and colour is always paired with text.
4. **AI is labelled; crisis is free.** Mira says she's an AI, SOS has no paywall, and dark mode is free.
5. **Glass for chrome, solid for content.** No glows, no decorative gradients (the streak hero is the one exception).

## System changes (code)

| Area | Change | Where |
|---|---|---|
| Colour | `MyExColors` reads from the active `MyExPalette` (light "Love" / night "Wine"). The app root picks it from the system or the user's choice and rebuilds | `lib/core/design/tokens.dart`, `lib/app.dart` |
| Type | `MyExType` styles are getters, so the ink colour follows the palette | `lib/core/design/typography.dart` |
| Theme preference | System / Light / Dark in Me, saved locally | `lib/core/design/theme_mode.dart` |
| New components | `MoodDots` (5-level selector), `MoodLine` (chart), `EmptyState` (petal mark + copy), `StatTile`, `GoalRing` | `lib/core/design/components.dart` and new files |
| Navigation | Tabs: Home · Plan · Coach · Journal · Me, plus the SOS circle. Insights and No-contact are pushed from Home and Me | `home_shell.dart`, `app_router.dart` |

## New and redesigned screens

- **Home:**
  - serif greeting
  - the no-contact hero with a numeral and a milestone bar, or a start card
  - an inline mood check-in (today)
  - today's plan step
  - a 7-day strip
  - Mira and Journal entry points
  - Draft Jail / SOS
  - a quiet upsell
- **No contact:**
  - goal ring with the serif day count and a goal of 7, 30, 60 or 90 days
  - milestones
  - "Days you chose yourself" (never resets)
  - history of attempts
  - "I reached out": a kind restart with an optional reflection, no shaming
- **Journal:**
  - entries with mood dot, kind and date
  - search
  - kinds: Reflection, Letter I won't send, Gratitude, List
  - guided prompts
  - a private-by-default line
- **Mood check-in sheet:** level, emotion words, optional note.
- **Insights:**
  - 14-day mood line
  - week summary
  - stat tiles (check-ins, journal entries, plan days, no-contact days)
  - non-linear copy ("Healing isn't a straight line")
- **Coach:**
  - header with the Mira orb and "AI · not therapy"
  - suggested prompts when the conversation is empty
- **Me:** profile, a theme preference, links to Insights and No contact.
- **Polish:** Draft Jail title and empty state, Day complete success mark, Trial status empty voice.

## Backend

New tables, each with RLS where `auth.uid() = user_id`:
- `mood_entries`
- `journal_entries`
- `no_contact_attempts`

Each gets a repository interface, a Supabase implementation and a demo fake, following the existing pattern.
The migrations are untested, like the others (see the README).

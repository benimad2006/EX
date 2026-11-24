# MyEx: visual moodboard

Each choice cites a reference from [DESIGN_REFERENCE_LIBRARY.md](DESIGN_REFERENCE_LIBRARY.md) (#n). Visuals
are described from fetched text and the MyEx app itself. See the access limits in DESIGN_RESEARCH.md.

## Primary direction: "Rose editorial"

A warm, intimate journal more than a fitness dashboard. Mend's own redesign moved from a "personal trainer for
heartbreak" to something that feels "like a best friend" (#10).

- **Calm surfaces.** Solid white (or night wine) cards on a blush page, glass only on chrome. Stoic's "Liquid
  Glass controls" (#17) and the existing spec F4/F7 back this.
- **The serif as the voice.** Instrument Serif for one headline per emotional screen and for hero numerals: day
  counts, mood averages, coin balance. Nothing in the category does this (#1–#13 state no visual identity).
- **One accent.** Rose #D81B60. Emotions map to tints of rose and plum, not a rainbow (adapted from How We Feel
  #15, without its four-quadrant colours).

## Secondary influences

| Influence | Taken from | How it shows up |
|---|---|---|
| Two progress metrics, one forgiving | (Not Boring) Habits #32, Let it Go #5 | "Days you chose yourself" (never resets) beside the strict no-contact streak |
| Milestone "gold" state | Streaks #31 | Milestone days (7/14/30/60/90) get a deeper rose ring, not a badge zoo |
| Morning/evening bookends | Finch #14, Stoic #17 | The Home greeting changes with the time; the evening check-in invites a journal line |
| A list as low-effort journaling | Spill #43 | "3 things I won't miss" style prompts in the journal |
| Weekly AI reflection | Rosebud #18, Ash #24 | The Insights week summary is written in Mira's calm voice (in demo it's assembled from real counts) |
| Named phases | BREAKFREE #6 | Plan weeks are named (already partly in place: "Rebuild") |
| Visible AI and privacy | Headspace Ebb #27, Day One #21 | "Mira is an AI. Not therapy." on the coach; "Only you can see this" on the journal |

## Palette

| Token | Light ("Love") | Night ("Wine") | Notes |
|---|---|---|---|
| bg | #FFF5F7 | #140A0F | Night is a warm black-wine, never neutral grey |
| bgElev (cards) | #FFFFFF | #231219 | |
| ink | #3A0F22 | #FBEAF0 | |
| ink2 | #86506A | #C79AAE | ≥ 4.5:1 on bg in both themes |
| accent | #D81B60 | #FF4F8B | Brighter in night mode for contrast |
| accentInk | #B0124F | #FF8DB3 | Small accent text |
| success | #0B7A55 | #3CCB94 | |
| Mood 1→5 | plum #6B3A5B → rose #D81B60 → blush #F59AB8 (light). Night uses lighter steps | | Always paired with a word (Daylio a11y, #19) |

**Not used:** purple gradient backgrounds, glow shadows, gradient text, rainbow mood colours. These come from the
ChatGPT direction (Kalito/MindEase style). The spec's §2 "AI tells" already rejected them, and the founder chose
"Refine rose + dark mode".

## Typography

- System font (SF Pro) for all UI text, using the existing Dynamic Type scale.
- Instrument Serif, upright, for one display line per emotional screen and for hero numerals: the streak count,
  the mood average on Insights, the journal entry count.
- No uppercase eyebrows, no italics (spec A1/A2).

## Iconography

Material Rounded outline icons (already in use), one stroke family, filled only when selected. No emoji as
production icons; mood levels use drawn dots, not faces.

## Illustration

Lumi only on Plan ready, SOS, Welcome and Win-back (CLAUDE.md). Empty states use a drawn "petal" mark: a small
rose-tinted shape built from the Lumi geometry with no face, so the brand stays consistent without the mascot
spreading.

## Surfaces and motion

- Solid cards with radius 22, hairline separators, no shadows on content (spec F4).
- Glass: tab bar, nav buttons, chips, sheets (spec F7). Reduce Transparency makes them solid.
- Motion: a spring press on cards, cross-fading tabs, a mood dot that grows on select, and a chart that draws in
  once. Reduce Motion turns these into cross-fades, and the chart appears without the draw-in (spec M7).

## Paywall

Keep the existing honest paywall (spec P1/P2). The research confirms it: two plans, an effective monthly price as
secondary, no trial toggle (Apple began rejecting trial toggles in February 2026, #35), and no promotional pop-ups
(Reflectly complaints, #20).

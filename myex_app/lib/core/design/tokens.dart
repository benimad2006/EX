import 'package:flutter/widgets.dart';

// =============================================================================
// DESIGN TOKENS — the ONLY place colors, radii, spacing, sizes and shadows are
// defined. Feature widgets reference these, never literals.
//
// Source: MyEx_Design_Spec.md §13 "Final design tokens" (iOS 26 Love theme).
// One accent (#D81B60, #B0124F for small text), wine-tinted neutrals, flat
// white surfaces, glass only on floating chrome, ONE gradient (streak hero).
// =============================================================================

/// One full set of colours. [light] is the "Love" theme (spec §13); [night] is
/// the warm wine dark theme (docs/design/MYEX_DESIGN_DIRECTION.md).
@immutable
class MyExPalette {
  const MyExPalette({
    required this.brightness,
    required this.bg,
    required this.bgElev,
    required this.ink,
    required this.ink2,
    required this.ink3,
    required this.sep,
    required this.fill,
    required this.capsule,
    required this.neutralIcon,
    required this.accent,
    required this.accentInk,
    required this.accentSoft,
    required this.success,
    required this.successSoft,
    required this.danger,
    required this.scrim,
    required this.pushDim,
    required this.glassFill,
    required this.glassRim,
    required this.glassHighlight,
    required this.pageGlowTop,
    required this.pageGlowBottom,
    required this.mood,
    required this.shadowTint,
    required this.skyTop,
    required this.blush,
    required this.onBlush,
    required this.moon,
    required this.lavender,
    required this.cardRim,
  });

  final Brightness brightness;
  final Color bg, bgElev, ink, ink2, ink3, sep, fill, capsule, neutralIcon;
  final Color accent, accentInk, accentSoft, success, successSoft, danger;
  final Color scrim, pushDim, glassFill, glassRim, glassHighlight;
  final Color pageGlowTop, pageGlowBottom;

  /// Mood levels 1 (heaviest) → 5 (lightest): plum → rose → blush.
  /// Always shown with a word, never colour alone.
  final List<Color> mood;

  /// Base colour of the (neutral) floating shadows.
  final Color shadowTint;

  /// Top of the page sky (night: a plum dusk fading into [bg]).
  final Color skyTop;

  /// Soft pink highlight: headline accent words, the selected plan card.
  final Color blush;
  final Color onBlush;

  /// Art colours (illustrations only, never UI text).
  final Color moon;
  final Color lavender;

  /// Hairline rim on content cards (night only; transparent by day).
  final Color cardRim;

  static const light = MyExPalette(
    brightness: Brightness.light,
    bg: Color(0xFFFFF5F7),
    bgElev: Color(0xFFFFFFFF),
    ink: Color(0xFF3A0F22),
    ink2: Color(0xFF86506A),
    ink3: Color(0x4D3A0F22),
    sep: Color(0x1F3A0F22),
    fill: Color(0x0F3A0F22),
    capsule: Color(0x143A0F22),
    neutralIcon: Color(0xFF8E7280),
    accent: Color(0xFFD81B60),
    accentInk: Color(0xFFB0124F),
    accentSoft: Color(0x1AD81B60),
    success: Color(0xFF0B7A55),
    successSoft: Color(0x1A0B7A55),
    danger: Color(0xFFD70015),
    scrim: Color(0x3814040C),
    pushDim: Color(0x1F14040C),
    glassFill: Color(0x8CFFFFFF),
    glassRim: Color(0xBFFFFFFF),
    glassHighlight: Color(0x80FFFFFF),
    pageGlowTop: Color(0x29FF78A0),
    pageGlowBottom: Color(0x24FFAAC3),
    mood: [
      Color(0xFF6B3A5B),
      Color(0xFF9C4A78),
      Color(0xFFC2306E),
      Color(0xFFE5608F),
      Color(0xFFF59AB8),
    ],
    shadowTint: Color(0xFF3A0F22),
    skyTop: Color(0xFFFFE9EF),
    blush: Color(0xFFFFD6E4),
    onBlush: Color(0xFF3A0F22),
    moon: Color(0xFFF7C9A6),
    lavender: Color(0xFF9C7BEA),
    cardRim: Color(0x00000000),
  );

  /// "Rose night": the default identity. Plum-black sky, rose accent,
  /// blush highlights, a cream moon (docs/design/MYEX_DESIGN_DIRECTION.md).
  static const night = MyExPalette(
    brightness: Brightness.dark,
    bg: Color(0xFF140A18),
    bgElev: Color(0xFF22122A),
    ink: Color(0xFFFFF0F5),
    ink2: Color(0xFFCDA6BC),
    ink3: Color(0x52FFF0F5),
    sep: Color(0x1FFFF0F5),
    fill: Color(0x14FFF0F5),
    capsule: Color(0x1FFFF0F5),
    neutralIcon: Color(0xFF7E5F78),
    accent: Color(0xFFFF5C93),
    accentInk: Color(0xFFFF9EC2),
    accentSoft: Color(0x2EFF5C93),
    success: Color(0xFF45D19E),
    successSoft: Color(0x2445D19E),
    danger: Color(0xFFFF5A6E),
    scrim: Color(0x99000000),
    pushDim: Color(0x4D000000),
    glassFill: Color(0x8C2A1633),
    glassRim: Color(0x29FFFFFF),
    glassHighlight: Color(0x14FFFFFF),
    pageGlowTop: Color(0x40B3134F),
    pageGlowBottom: Color(0x33603A9C),
    mood: [
      Color(0xFF8C5A9C),
      Color(0xFFB862A0),
      Color(0xFFE8508A),
      Color(0xFFFF7EA8),
      Color(0xFFFFC4D8),
    ],
    shadowTint: Color(0xFF000000),
    skyTop: Color(0xFF2A1233),
    blush: Color(0xFFFFC4D8),
    onBlush: Color(0xFF2B0E22),
    moon: Color(0xFFFDE1CD),
    lavender: Color(0xFFB79BFF),
    cardRim: Color(0x14FFFFFF),
  );
}

abstract final class MyExColors {
  static MyExPalette _p = MyExPalette.night;

  /// The active palette. Set ONLY by the app root (lib/app.dart), which then
  /// remounts the tree so every widget picks it up.
  static MyExPalette get palette => _p;
  static void use(MyExPalette p) => _p = p;
  static bool get isNight => _p.brightness == Brightness.dark;

  // ---- Surfaces ----
  /// Grouped page background.
  static Color get bg => _p.bg;

  /// Cells, cards, bubbles.
  static Color get bgElev => _p.bgElev;

  // ---- Labels (wine-tinted neutrals) ----
  /// Primary label (≈15:1 on bg).
  static Color get ink => _p.ink;

  /// Secondary label (≥5.8:1 on bg).
  static Color get ink2 => _p.ink2;

  /// Tertiary: chevrons, placeholders. Glyphs only, NEVER text.
  static Color get ink3 => _p.ink3;

  /// 0.5pt hairlines.
  static Color get sep => _p.sep;

  /// Pressed cells, tracks, neutral fills.
  static Color get fill => _p.fill;

  /// Tab selection capsule.
  static Color get capsule => _p.capsule;

  /// Neutral icon square (secondary rows).
  static Color get neutralIcon => _p.neutralIcon;

  // ---- Accent (one) ----
  /// Fills, icons, text ≥17pt semibold.
  static Color get accent => _p.accent;

  /// Small accent text and links.
  static Color get accentInk => _p.accentInk;

  /// Tinted fills; text on it uses [accentInk], never [accent].
  static Color get accentSoft => _p.accentSoft;

  static const onAccent = Color(0xFFFFFFFF);

  // ---- Semantic ----
  static Color get success => _p.success;
  static Color get successSoft => _p.successSoft;
  static Color get danger => _p.danger;

  /// Switches only.
  static const switchOn = Color(0xFF34C759);

  // ---- Highlights + art ----
  static Color get blush => _p.blush;
  static Color get onBlush => _p.onBlush;
  static Color get moon => _p.moon;
  static Color get lavender => _p.lavender;
  static Color get skyTop => _p.skyTop;
  static Color get cardRim => _p.cardRim;

  // ---- Mood (1..5) ----
  static Color mood(int level) => _p.mood[(level - 1).clamp(0, 4)];

  // ---- Coin (the object's real colour) ----
  static const coinGold = Color(0xFFF6C25B);
  static const coinFace = Color(0xFFFFE7A8);

  // ---- Scrims ----
  static Color get scrim => _p.scrim;
  static Color get pushDim => _p.pushDim;

  /// Behind a scaled page while a sheet is presented.
  static const presentingBackdrop = Color(0xFF0B0A10);

  // ---- Glass (floating chrome only) ----
  /// Transparent bg, for fades into the page (dock, nav edge).
  static Color get bgClear => _p.bg.withValues(alpha: 0);
  static Color get glassFill => _p.glassFill;
  static Color get glassRim => _p.glassRim;
  static Color get glassHighlight => _p.glassHighlight;

  // ---- Page background: static glows over bg ----
  static Color get pageGlowTop => _p.pageGlowTop;
  static Color get pageGlowBottom => _p.pageGlowBottom;

  // ---- The ONLY gradient: Home streak hero (+ app icon) ----
  static const heroStart = Color(0xFFB3134F);
  static const heroEnd = Color(0xFFD81B60);
  static const heroHighlight = Color(0x73FF96B4); // rgba(255,150,180,.45)
  static const onHero = Color(0xFFFFFFFF);
  static const heroTrack = Color(0x4DFFFFFF); // white 30%

  static const heroGradient = LinearGradient(
    // 160°
    begin: Alignment(-0.34, -0.94),
    end: Alignment(0.34, 0.94),
    colors: [heroStart, heroEnd],
  );
  static const heroHighlightGradient = RadialGradient(
    center: Alignment(0.8, -1),
    radius: 1.1,
    colors: [heroHighlight, Color(0x00FF96B4)],
    stops: [0, 0.6],
  );

  // ---- Mira orb (faceless) ----
  static const miraOrb = RadialGradient(
    center: Alignment(-0.24, -0.4),
    radius: 0.8,
    colors: [Color(0xFFFFE3EC), Color(0xFFF06A95), Color(0xFFB3134F)],
    stops: [0, 0.5, 1],
  );
  static const miraRim = Color(0x59FFFFFF); // white 35%
}

/// Corner radii.
abstract final class MyExRadii {
  /// Icon squares.
  static const xs = 8.0;
  static const s = 12.0;

  /// StoreKit boxes.
  static const m = 16.0;

  /// Lists, cards, plan picker.
  static const l = 22.0;

  /// Hero.
  static const xl = 28.0;
  static const sheet = 38.0;
  static const capsule = 999.0;

  static const planRow = 18.0;
  static const tabCapsule = 27.0;
  static const bubble = 18.0;
  static const composer = 22.0;
  static const strip = 4.0;
  static const progress = 2.0;
}

/// Spacing (4/8 grid).
abstract final class MyExSpacing {
  /// Hairline gap (icon → caption in tab cells, orb → name).
  static const tight = 2.0;
  static const s1 = 4.0;
  static const s2 = 8.0;
  static const s3 = 12.0;
  static const s4 = 16.0;
  static const s5 = 20.0;
  static const s6 = 24.0;
  static const s8 = 32.0;

  /// Screen margin.
  static const margin = 16.0;

  /// Gap between sections.
  static const section = 24.0;

  /// Large title → content.
  static const titleToContent = 8.0;
  static const cardPadding = 16.0;
  static const rowVertical = 11.0;
  static const rowHorizontal = 16.0;

  /// Separator inset (plain / with leading icon).
  static const separatorInset = 16.0;
  static const separatorInsetIcon = 58.0;

  /// Dock bottom padding.
  static const dockBottom = 30.0;

  /// Floating tab bar insets.
  static const tabBarInset = 20.0;
}

/// Component sizes.
abstract final class MyExSizes {
  /// Apple HIG minimum hit target.
  static const minTap = 44.0;
  static const rowMinHeight = 44.0;
  static const buttonHeight = 52.0;
  static const navBarHeight = 52.0;

  /// Large-title collapse threshold (scroll offset).
  static const largeTitleCollapse = 36.0;

  // Tab bar + SOS accessory
  static const tabBarHeight = 62.0;
  static const tabBarPadding = 4.0;
  static const sosCircle = 62.0;
  static const tabIcon = 24.0;

  // Glyphs
  static const iconSm = 14.0;
  static const icon = 18.0;
  static const iconMd = 22.0;
  static const iconLg = 24.0;
  static const iconSquare = 30.0;
  static const radio = 22.0;
  static const radioCheck = 12.0;

  // Chips
  static const chipVisualHeight = 36.0;
  static const coin = 18.0;
  static const coinRow = 30.0;
  static const coinBalance = 32.0;

  // Avatars / mascots
  static const miraHeader = 36.0;
  static const miraSheet = 44.0;
  static const miraInline = 20.0;
  static const lumi = 170.0;
  static const lumiSos = 180.0;
  static const avatar = 56.0;
  static const mascotOrb = 120.0;

  // Paywall
  static const planRowMinHeight = 72.0;
  static const planRowVertical = 14.0;
  static const getCapsulePadding = 14.0;
  static const skeletonList = 156.0;
  static const datePickerHeight = 216.0;
  static const successMark = 96.0;
  static const ring = 100.0;
  static const ringStroke = 8.0;
  static const planHighlightBorder = 2.0;
  static const stripCell = 8.0;
  static const stripColumns = 15;
  static const timelineDot = 28.0;
  static const timelineConnector = 1.0;

  // Coach
  static const sendButton = 32.0;
  static const meterDot = 6.0;

  // Progress
  static const progressHeight = 4.0;

  // Coins "Get" capsule
  static const getCapsuleMinWidth = 76.0;
  static const getCapsuleHeight = 30.0;

  /// 0.5pt hairline.
  static const hairline = 0.5;

  static const grabberWidth = 36.0;
  static const grabberHeight = 5.0;
}

/// Glass recipe (floating chrome only).
abstract final class MyExGlassTokens {
  static const blurSigma = 14.0;

  /// 180% saturation boost behind glass.
  static const saturation = 1.8;
  static const rimWidth = 0.5;
}

/// Sheet presentation: the page behind scales and rounds.
abstract final class MyExPresentation {
  static const backgroundScale = 0.94;
  static const backgroundOffsetY = 14.0;
  static const backgroundRadius = MyExRadii.sheet;
}

/// Shadows: ONLY floating things (glass chrome, sheets). No coloured glows.
abstract final class MyExShadows {
  static Color _t(int alpha) => MyExColors.palette.shadowTint.withAlpha(alpha);
  static List<BoxShadow> get glass => [
    BoxShadow(color: _t(0x1A), blurRadius: 24, offset: const Offset(0, 8)),
    BoxShadow(color: _t(0x0F), blurRadius: 2, offset: const Offset(0, 1)),
  ];
  static const sheet = [
    BoxShadow(color: Color(0x4014040C), blurRadius: 60, offset: Offset(0, 20)),
  ];
  static List<BoxShadow> get pushEdge => [
    BoxShadow(color: _t(0x1A), blurRadius: 30, offset: const Offset(-10, 0)),
  ];
}

import 'package:flutter/material.dart';

import 'navigation.dart';
import 'tokens.dart';
import 'typography.dart';

/// Material theme derived ONLY from tokens + typography.
/// No fontFamily: UI text uses the platform system font (SF Pro on iOS).
abstract final class MyExTheme {
  /// Theme for the ACTIVE palette ([MyExColors.palette]).
  static ThemeData light() => current();

  static ThemeData current() {
    final scheme = ColorScheme.fromSeed(
      seedColor: MyExColors.accent,
      brightness: MyExColors.palette.brightness,
      primary: MyExColors.accent,
      onPrimary: MyExColors.onAccent,
      error: MyExColors.danger,
      surface: MyExColors.bgElev,
      onSurface: MyExColors.ink,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: MyExColors.palette.brightness,
      platform: TargetPlatform.iOS,
      colorScheme: scheme,
      scaffoldBackgroundColor: MyExColors.bg,
      splashFactory: NoSplash.splashFactory,
      highlightColor: MyExColors.fill,
      dividerColor: MyExColors.sep,
      textTheme: TextTheme(
        displayLarge: MyExType.display,
        headlineLarge: MyExType.largeTitle,
        headlineMedium: MyExType.title1,
        headlineSmall: MyExType.title2,
        titleLarge: MyExType.title3,
        titleMedium: MyExType.headline,
        bodyLarge: MyExType.body,
        bodyMedium: MyExType.subheadline,
        bodySmall: MyExType.footnote,
        labelLarge: MyExType.button,
        labelSmall: MyExType.caption2,
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: MyExColors.accent,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: InputBorder.none,
        hintStyle: MyExType.body.copyWith(color: MyExColors.ink2),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.iOS: MyExPageTransitionsBuilder(),
          TargetPlatform.android: MyExPageTransitionsBuilder(),
        },
      ),
    );
  }
}

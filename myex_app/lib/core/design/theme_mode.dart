import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../supabase/supabase_providers.dart';
import 'tokens.dart';

/// Appearance chosen in Me › Appearance. Saved on this device only.
enum AppearanceMode { system, light, dark }

class AppearanceController extends Notifier<AppearanceMode> {
  static const _key = 'appearance_mode';

  @override
  AppearanceMode build() {
    final raw = ref.read(sharedPreferencesProvider).getString(_key);
    return AppearanceMode.values.firstWhere(
      (m) => m.name == raw,
      // Rose night is the identity; light is a choice in Me › Appearance.
      orElse: () => AppearanceMode.dark,
    );
  }

  Future<void> set(AppearanceMode mode) async {
    state = mode;
    await ref.read(sharedPreferencesProvider).setString(_key, mode.name);
  }
}

final appearanceProvider =
    NotifierProvider<AppearanceController, AppearanceMode>(
      AppearanceController.new,
    );

/// Pure rule (unit tested): which palette a mode + system brightness gives.
MyExPalette paletteFor(AppearanceMode mode, Brightness system) =>
    switch (mode) {
      AppearanceMode.light => MyExPalette.light,
      AppearanceMode.dark => MyExPalette.night,
      AppearanceMode.system =>
        system == Brightness.dark ? MyExPalette.night : MyExPalette.light,
    };

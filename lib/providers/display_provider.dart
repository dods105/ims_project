import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DisplaySettings {
  final ThemeMode themeMode;
  final double fontScale;
  final String fontFamily;

  const DisplaySettings({
    this.themeMode = ThemeMode.light,
    this.fontScale = 0.88,
    this.fontFamily = 'Roboto',
  });

  DisplaySettings copyWith({
    ThemeMode? themeMode,
    double? fontScale,
    String? fontFamily,
  }) => DisplaySettings(
    themeMode: themeMode ?? this.themeMode,
    fontScale: fontScale ?? this.fontScale,
    fontFamily: fontFamily ?? this.fontFamily,
  );
}

//  Keys
const _kThemeMode = 'display_theme_mode';
const _kFontScale = 'display_font_scale';
const _kFontFamily = 'display_font_family';

//  Notifier
class DisplayNotifier extends AsyncNotifier<DisplaySettings> {
  @override
  Future<DisplaySettings> build() async {
    final prefs = await SharedPreferences.getInstance();
    final modeStr = prefs.getString(_kThemeMode) ?? 'light';
    final scale = prefs.getDouble(_kFontScale) ?? 0.88;
    final font = prefs.getString(_kFontFamily) ?? 'Roboto';

    return DisplaySettings(
      themeMode: _modeFromString(modeStr),
      fontScale: scale,
      fontFamily: font,
    );
  }

  //  Setters
  Future<void> setThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kThemeMode, _modeToString(mode));
    state = AsyncData(
      (state.value ?? const DisplaySettings()).copyWith(themeMode: mode),
    );
  }

  Future<void> setFontScale(double scale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_kFontScale, scale);
    state = AsyncData(
      (state.value ?? const DisplaySettings()).copyWith(fontScale: scale),
    );
  }

  Future<void> setFontFamily(String family) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kFontFamily, family);
    state = AsyncData(
      (state.value ?? const DisplaySettings()).copyWith(fontFamily: family),
    );
  }

  //  Helpers
  static ThemeMode _modeFromString(String s) => switch (s) {
    'dark' => ThemeMode.dark,
    'system' => ThemeMode.system,
    _ => ThemeMode.light,
  };

  static String _modeToString(ThemeMode m) => switch (m) {
    ThemeMode.dark => 'dark',
    ThemeMode.system => 'system',
    _ => 'light',
  };
}

//  Provider
final displayProvider = AsyncNotifierProvider<DisplayNotifier, DisplaySettings>(
  DisplayNotifier.new,
);

final displaySettingsProvider = Provider<DisplaySettings>((ref) {
  return ref
      .watch(displayProvider)
      .maybeWhen(data: (s) => s, orElse: () => const DisplaySettings());
});

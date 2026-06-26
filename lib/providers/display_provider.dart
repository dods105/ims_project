import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DisplaySettings {
  final ThemeMode themeMode; // light, dark mode
  final double fontScale; // font size
  final String fontFamily; // font Family, always Roboto

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

const _kThemeMode = 'display_theme_mode';
const _kFontScale = 'display_font_scale';

//  Notifier
// reads and load last display preferences
class DisplayNotifier extends AsyncNotifier<DisplaySettings> {
  @override
  Future<DisplaySettings> build() async {
    final prefs = await SharedPreferences.getInstance();
    final modeStr = prefs.getString(_kThemeMode) ?? 'light';
    final scale = prefs.getDouble(_kFontScale) ?? 0.88;
    final font = 'Roboto';

    return DisplaySettings(
      themeMode: _modeFromString(modeStr),
      fontScale: scale,
      fontFamily: font,
    );
  }

  // when theme is changed, update the UI and save to SharedPreferences
  Future<void> setThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kThemeMode, _modeToString(mode));
    state = AsyncData(
      (state.value ?? const DisplaySettings()).copyWith(themeMode: mode),
    );
  }

  // scale values to labels: 0.78 = Small, 0.88 = Medium, 1.02 = Large
  Future<void> setFontScale(double scale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_kFontScale, scale);
    state = AsyncData(
      (state.value ?? const DisplaySettings()).copyWith(fontScale: scale),
    );
  }

  // converts the string to type Thememode
  static ThemeMode _modeFromString(String s) => switch (s) {
    'dark' => ThemeMode.dark,
    'system' => ThemeMode.system,
    _ => ThemeMode.light, // default to light if not found
  };

  // converts ThemeMode to string for storage and retrieval from SharedPreferences
  static String _modeToString(ThemeMode m) => switch (m) {
    ThemeMode.dark => 'dark',
    ThemeMode.system => 'system',
    _ => 'light',
  };
}

// provider
final displayProvider = AsyncNotifierProvider<DisplayNotifier, DisplaySettings>(
  DisplayNotifier.new,
);

final displaySettingsProvider = Provider<DisplaySettings>((ref) {
  return ref
      .watch(displayProvider)
      .maybeWhen(data: (s) => s, orElse: () => const DisplaySettings());
});

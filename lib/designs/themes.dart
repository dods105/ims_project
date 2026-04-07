import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static const Color primaryBlue = Color(0xFF1565C0);

  static const Color white = Color(0xFFFFFFFF);
  static const Color offWhite = Color(0xFFF5F7FA);
  static const Color surfaceLight = Color(0xFFECF2FF);
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey700 = Color(0xFF616161);
  static const Color grey900 = Color(0xFF212121);

  static const Color success = Color(0xFF2E7D32);
  static const Color successLight = Color(0xFFA5D6A7);
  static const Color warning = Color(0xFFF57F17);
  static const Color error = Color(0xFFC62828);

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1565C0), Color(0xFF1E88E5), Color(0xFF42A5F5)],
    stops: [0.0, 0.55, 1.0],
  );

  static const LinearGradient surfaceGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFF5F7FA), Color(0xFFECF2FF)],
  );

  static const LinearGradient drawerHighlight = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF00BCD4), Color(0xFF1E88E5)],
  );

  static const LinearGradient drawerHighlightNight = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF1565C0), Color(0xFF1E88E5)],
  );

  static const LinearGradient drawerGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0D1B2E), Color(0xFF0A1628), Color(0xFF061020)],
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient drawerGradientBlue = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color.fromARGB(255, 44, 90, 154),
      Color.fromARGB(255, 35, 77, 139),
      Color.fromARGB(255, 24, 63, 127),
    ],
    stops: [0.0, 0.5, 1.0],
  );

  static const TextStyle drawerText = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.normal,
    color: offWhite,
    letterSpacing: 1,
  );

  static const TextStyle displayLarge = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w900,
    letterSpacing: -0.5,
    height: 1.1,
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.3,
    height: 1.2,
  );

  static const TextStyle titleLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
    height: 1.4,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.4,
  );

  static const TextStyle titleSmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.0,
    height: 1.4,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.15,
    height: 1.6,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.2,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.3,
    height: 1.5,
  );

  static TextStyle get pageTitleLight => displayMedium.copyWith(color: white);
  static TextStyle get pageTitleDark => displayMedium.copyWith(color: grey900);
  static TextStyle get subtitleLight =>
      bodyMedium.copyWith(color: white.withOpacity(0.7));
}

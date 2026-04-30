import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  static const Color brandBlue = Color(0xFF2563EB);
  static const Color brandBlueHover = Color(0xFF1D4ED8);
  static const Color brandBlueDeep = Color(0xFF1565C0);

  //  Light Mode Backgrounds
  static const Color appBackground = Color(0xFFF5F7FA);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color inputBackground = Color(0xFFF9FAFB);
  static const Color keyBackground = Color(0xFFF3F4F6);
  static const Color blueLight = Color(0xFFEFF6FF);
  static const Color cancelIconBg = Color(0xFFFFF7ED);
  static const Color deleteKeyBg = Color(0xFFFEF2F2);

  //  Dark Mode Backgrounds
  static const Color nightBlue = Color.fromARGB(255, 76, 128, 240);
  static const Color darkBackground = Color(0xFF0D1B2E);
  static const Color darkSurface = Color(0xFF162032);
  static const Color darkCard = Color(0xFF1C2B3F);
  static const Color darkInput = Color(0xFF243447);
  static const Color darkBorder = Color(0xFF2D3F55);

  //  Light Mode Text
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF374151);
  static const Color textMuted = Color(0xFF6B7280);
  static const Color textPlaceholder = Color(0xFF9CA3AF);
  static const Color textVeryLight = Color(0xFFD1D5DB);
  static const Color textBlueBrand = Color(0xFF1D4ED8);
  static const Color textBlueAccent = Color(0xFF2563EB);
  static const Color textBlueOnDark = Color(0xFFBFDBFE);
  static const Color textBlueLight = Color(0xFFDBEAFE);
  static const Color textRed = Color(0xFFEF4444);
  static const Color textOrange = Color(0xFFF97316);
  static const Color textGreen = Color(0xFF22C55E);

  //  Dark Mode Text white-ish
  static const Color darkTextPrimary = Color(0xFFF1F5F9);
  static const Color darkTextSecondary = Color(0xFFCBD5E1);
  static const Color darkTextMuted = Color(0xFF94A3B8);

  //  Borders
  static const Color borderDefault = Color(0xFFE5E7EB);
  static const Color borderBlue = Color(0xFF93C5FD);
  static const Color borderReceipt = Color(0xFFD1D5DB);

  //  Compat aliases
  static const Color primaryBlue = brandBlue;
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

  //  Gradients
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

  //  Base Text Styles
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
    fontSize: 20,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.15,
    height: 1.4,
  );
  static const TextStyle titleMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
    height: 1.4,
  );
  static const TextStyle titleSmall = TextStyle(
    fontSize: 13,
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

  // drawerText dark blue bg white
  static const TextStyle drawerText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: offWhite,
    letterSpacing: 1.2,
  );

  static TextStyle get pageTitleLight => displayMedium.copyWith(color: white);
  static TextStyle get pageTitleDark => displayMedium.copyWith(color: grey900);
  static TextStyle get subtitleLight =>
      bodyMedium.copyWith(color: white.withOpacity(0.7));

  //  LIGHT ThemeData
  static ThemeData lightTheme({
    String fontFamily = 'Roboto',
    double fontScale = 1.0,
  }) {
    final base = _buildTextTheme(fontFamily, fontScale, Brightness.light);
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: brandBlue,
        onPrimary: white,
        primaryContainer: Color(0xFFDBEAFE),
        onPrimaryContainer: Color(0xFF1D4ED8),
        secondary: brandBlueHover,
        onSecondary: white,
        secondaryContainer: Color(0xFFEFF6FF),
        onSecondaryContainer: brandBlue,
        tertiary: Color(0xFF42A5F5),
        onTertiary: white,
        tertiaryContainer: Color(0xFFE3F2FD),
        onTertiaryContainer: brandBlueDeep,
        error: textRed,
        onError: white,
        errorContainer: Color(0xFFFEF2F2),
        onErrorContainer: textRed,
        background: appBackground,
        onBackground: textPrimary,
        surface: cardBackground,
        onSurface: textPrimary,
        surfaceVariant: inputBackground,
        onSurfaceVariant: textSecondary,
        outline: borderDefault,
        outlineVariant: borderBlue,
        shadow: Color(0xFF000000),
        scrim: Color(0xFF000000),
        inverseSurface: Color(0xFF1C2B3F),
        onInverseSurface: Color(0xFFF1F5F9),
        inversePrimary: Color(0xFF93C5FD),
      ),
      scaffoldBackgroundColor: appBackground,
      textTheme: base,
      appBarTheme: AppBarTheme(
        backgroundColor: brandBlue,
        foregroundColor: white,
        elevation: 0,
        titleTextStyle: base.titleLarge?.copyWith(
          color: white,
          fontWeight: FontWeight.w800,
          letterSpacing: 1,
        ),
        iconTheme: const IconThemeData(color: white),
      ),
      cardTheme: CardThemeData(
        color: cardBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: borderDefault),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith(
          (s) => s.contains(MaterialState.selected) ? white : grey500,
        ),
        trackColor: MaterialStateProperty.resolveWith(
          (s) => s.contains(MaterialState.selected) ? brandBlue : grey300,
        ),
      ),
      dividerColor: borderDefault,
    );
  }

  //  DARK ThemeData
  static ThemeData darkTheme({
    String fontFamily = 'Roboto',
    double fontScale = 1.0,
  }) {
    final base = _buildTextTheme(fontFamily, fontScale, Brightness.dark);
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: brandBlue,
        onPrimary: white,
        primaryContainer: Color(0xFF1D4ED8),
        onPrimaryContainer: Color(0xFFDBEAFE),
        secondary: Color(0xFF42A5F5),
        onSecondary: white,
        secondaryContainer: Color(0xFF1565C0),
        onSecondaryContainer: Color(0xFFBFDBFE),
        tertiary: Color(0xFF93C5FD),
        onTertiary: Color(0xFF0D1B2E),
        tertiaryContainer: Color(0xFF162032),
        onTertiaryContainer: Color(0xFFDBEAFE),
        error: Color(0xFFEF4444),
        onError: white,
        errorContainer: Color(0xFF7F1D1D),
        onErrorContainer: Color(0xFFFECACA),
        background: darkBackground,
        onBackground: darkTextPrimary, // WHITE
        surface: darkCard,
        onSurface: darkTextPrimary, // WHITE
        surfaceVariant: darkSurface,
        onSurfaceVariant: darkTextSecondary, // light grey-blue
        outline: darkBorder,
        outlineVariant: Color(0xFF1E3A5F),
        shadow: Color(0xFF000000),
        scrim: Color(0xFF000000),
        inverseSurface: cardBackground,
        onInverseSurface: textPrimary,
        inversePrimary: brandBlue,
      ),
      scaffoldBackgroundColor: darkBackground,
      textTheme: base,
      appBarTheme: AppBarTheme(
        backgroundColor: nightBlue,
        foregroundColor: darkTextPrimary,
        elevation: 0,
        titleTextStyle: base.titleLarge?.copyWith(
          color: darkSurface,
          fontWeight: FontWeight.w800,
          letterSpacing: 1,
        ),
        iconTheme: const IconThemeData(color: darkSurface),
      ),
      cardTheme: CardThemeData(
        color: darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: darkBorder),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith(
          (s) => s.contains(MaterialState.selected) ? white : grey500,
        ),
        trackColor: MaterialStateProperty.resolveWith(
          (s) => s.contains(MaterialState.selected) ? brandBlue : grey700,
        ),
      ),
      dividerColor: darkBorder,
    );
  }

  //  TextTheme builder
  static TextTheme _buildTextTheme(
    String fontFamily,
    double scale,
    Brightness brightness,
  ) {
    final color = brightness == Brightness.light
        ? textPrimary
        : darkTextPrimary;
    final gf = _googleFontsName(fontFamily);

    TextStyle apply(TextStyle base) {
      final sized = base.copyWith(
        fontSize: (base.fontSize ?? 14) * scale,
        color: color,
      );
      try {
        return GoogleFonts.getFont(gf, textStyle: sized);
      } catch (_) {
        return sized;
      }
    }

    return TextTheme(
      displayLarge: apply(displayLarge),
      displayMedium: apply(displayMedium),
      titleLarge: apply(titleLarge),
      titleMedium: apply(titleMedium),
      titleSmall: apply(titleSmall),
      bodyLarge: apply(bodyLarge),
      bodyMedium: apply(bodyMedium),
      bodySmall: apply(bodySmall),
    );
  }

  //GoogleFonts TextStyle names for switching
  static String _googleFontsName(String name) => switch (name) {
    'Roboto' => 'Roboto',
    'Lato' => 'Lato',
    'Open Sans' => 'Open Sans',
    'Poppins' => 'Poppins',
    'Merriweather' => 'Merriweather',
    'Playfair Display' => 'Playfair Display',
    _ => 'Roboto',
  };

  // Fonts shown in Display
  static const List<String> availableFonts = [
    'Roboto',
    'Lato',
    'Open Sans',
    'Poppins',
    'Merriweather',
    'Playfair Display',
  ];
}

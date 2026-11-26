import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Palette et constantes partagées par tout le design system de l'app.
class AppColors {
  AppColors._();

  static const primary = Color(0xFF16215C); // bleu profond (logo)
  static const primaryDark = Color(0xFF0A1238);
  static const secondary = Color(0xFFE23B3B); // rouge du ruban du logo
  static const gold = Color(0xFFD4AF37); // or, couleur d'accent
  static const goldSoft = Color(0xFFF3E7C4);

  static const placeholder = Color(0xFFE9EBF5);
  static const backgroundLight = Color(0xFFF6F7FC);
  static const surfaceLight = Color(0xFFFFFFFF);
  static const backgroundDark = Color(0xFF0B0E1A);
  static const surfaceDark = Color(0xFF161A2C);

  static const gradientHero = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, Color(0xFF2A3B8F), Color(0xFF3E2E7A)],
  );

  static const gradientGold = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE8C766), gold],
  );
}

/// Rayons et espacements cohérents pour toutes les cartes/boutons.
class AppRadius {
  AppRadius._();
  static const sm = 12.0;
  static const md = 18.0;
  static const lg = 24.0;
  static const pill = 999.0;
}

class AppSpacing {
  AppSpacing._();
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
}

class AppTheme {
  AppTheme._();

  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final background = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final surface = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;

    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: brightness,
      primary: AppColors.primary,
      secondary: AppColors.gold,
      surface: surface,
    );

    final base = ThemeData(useMaterial3: true, brightness: brightness, colorScheme: colorScheme);
    final textTheme = GoogleFonts.interTextTheme(isDark ? base.textTheme.apply(bodyColor: Colors.white, displayColor: Colors.white) : base.textTheme);

    return base.copyWith(
      scaffoldBackgroundColor: background,
      textTheme: textTheme,
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? Colors.white : AppColors.primary,
        elevation: 0,
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.playfairDisplay(
          color: isDark ? Colors.white : AppColors.primary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide.none,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.primary,
        contentTextStyle: const TextStyle(color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
      ),
      colorScheme: colorScheme,
    );
  }
}

/// Dégradé de fond "hero" utilisé en tête de certains écrans.
extension AppThemeContext on BuildContext {
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
}

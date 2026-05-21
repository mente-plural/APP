import 'package:flutter/material.dart';

class AppColors {
  // --- MODO CLARO ---
  static const Color primaryClaro = Color(0xFF16A34A);
  static const Color bgClaro = Color(0xFFFAFAF9);
  static const Color surfaceClaro = Color(0xFFFFFFFF);
  static const Color textPrimaryClaro = Color(0xFF1C1917);
  static const Color textMutedClaro = Color(0xFF57534E);
  static const Color borderClaro = Color(0xFFE7E5E4);

  // --- MODO ESCURO ---
  static const Color primaryEscuro = Color(0xFF01BBA6);
  static const Color bgEscuro = Color(0xFF020618);
  static const Color surfaceEscuro = Color(0xFF0F172A);
  static const Color textAccentEscuro = Color(0xFFFFFFFF);
  static const Color textSecundarioEscuro = Color(0xFF9fb1d1);
  static const Color borderEscuro = Color(0xFF1E293B);

  // --- CORES DE PREFERÊNCIA ---
  static const Color verde = Color(0xFF16A34A);
  static const Color azul = Color(0xFF3B82F6);
  static const Color roxo = Color(0xFF8B5CF6);
  static const Color laranja = Color(0xFFF59E0B);
}

class AppSizes {
  static const double radiusLG = 16.0;
}

class AppTheme {
  static Color getPrimaryColor(String? colorName, {bool isDark = true}) {
    switch (colorName) {
      case 'Verde': return AppColors.verde;
      case 'Azul': return AppColors.azul;
      case 'Roxo': return AppColors.roxo;
      case 'Laranja': return AppColors.laranja;
      default: return isDark ? AppColors.primaryEscuro : AppColors.primaryClaro;
    }
  }

  // --- TEMA CLARO ---
  static ThemeData lightTheme({String? preferredColor, double fontSizeMultiplier = 1.0}) {
    final primary = getPrimaryColor(preferredColor, isDark: false);
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: primary,
        surface: AppColors.surfaceClaro,
        onPrimary: Colors.white,
        onSurface: AppColors.textPrimaryClaro,
        outline: AppColors.borderClaro,
      ),
      scaffoldBackgroundColor: AppColors.bgClaro,
      dividerColor: AppColors.borderClaro,
      disabledColor: AppColors.textMutedClaro.withValues(alpha: 0.5),
      textTheme: TextTheme(
        bodyLarge: TextStyle(color: AppColors.textPrimaryClaro, fontSize: 16 * fontSizeMultiplier),
        headlineMedium: TextStyle(
          color: AppColors.textPrimaryClaro,
          fontWeight: FontWeight.bold,
          fontSize: 20 * fontSizeMultiplier,
        ),
        bodyMedium: TextStyle(
          color: AppColors.textMutedClaro,
          fontSize: 14 * fontSizeMultiplier,
        ),
      ),
      elevatedButtonTheme: _buttonTheme(primary, Colors.white, fontSizeMultiplier),
    );
  }

  // --- TEMA ESCURO ---
  static ThemeData darkTheme({String? preferredColor, double fontSizeMultiplier = 1.0}) {
    final primary = getPrimaryColor(preferredColor, isDark: true);
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: primary,
        surface: AppColors.surfaceEscuro,
        onPrimary: Colors.white,
        onSurface: AppColors.textAccentEscuro,
        outline: AppColors.borderEscuro,
      ),
      scaffoldBackgroundColor: AppColors.bgEscuro,
      dividerColor: AppColors.borderEscuro,
      disabledColor: AppColors.textSecundarioEscuro.withValues(alpha: 0.5),
      textTheme: TextTheme(
        bodyLarge: TextStyle(color: AppColors.textAccentEscuro, fontSize: 16 * fontSizeMultiplier),
        headlineMedium: TextStyle(
          color: AppColors.textAccentEscuro,
          fontWeight: FontWeight.bold,
          fontSize: 20 * fontSizeMultiplier,
        ),
        bodyMedium: TextStyle(
          color: AppColors.textSecundarioEscuro,
          fontSize: 14 * fontSizeMultiplier,
        ),
      ),
      elevatedButtonTheme: _buttonTheme(primary, Colors.white, fontSizeMultiplier),
    );
  }

  static ElevatedButtonThemeData _buttonTheme(Color bg, Color text, double fontSizeMultiplier) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: bg,
        foregroundColor: text,
        elevation: 0,
        textStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16 * fontSizeMultiplier),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      ),
    );
  }

  // --- TEMA ALTO CONTRASTE ---
  static ThemeData highContrastTheme({double fontSizeMultiplier = 1.0}) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: Colors.yellow,
        surface: Colors.black,
        onPrimary: Colors.black,
        onSurface: Colors.white,
        outline: Colors.white,
      ),
      scaffoldBackgroundColor: Colors.black,
      dividerColor: Colors.white,
      disabledColor: Colors.white.withValues(alpha: 0.5),
      textTheme: TextTheme(
        bodyLarge: TextStyle(
          color: Colors.white,
          fontSize: 18 * fontSizeMultiplier,
          fontWeight: FontWeight.w500,
        ),
        headlineMedium: TextStyle(
          color: Colors.yellow,
          fontWeight: FontWeight.bold,
          fontSize: 24 * fontSizeMultiplier,
        ),
        bodyMedium: TextStyle(
          color: Colors.white,
          fontSize: 16 * fontSizeMultiplier,
        ),
      ),
      elevatedButtonTheme: _buttonTheme(Colors.yellow, Colors.black, fontSizeMultiplier),
    );
  }
}

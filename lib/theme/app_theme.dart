import 'package:flutter/material.dart';

class AppColors {
  // --- MODO CLARO ---
  static const Color primaryClaro = Color(0xFF16A34A);
  static const Color bgClaro = Color(0xFFFAFAF9);
  static const Color surfaceClaro = Color(0xFFFFFFFF);
  static const Color textPrimaryClaro = Color(0xFF1C1917);
  static const Color textMutedClaro = Color(0xFF57534E);

  // --- MODO ESCURO ---
  static const Color primaryEscuro = Color(0xFF01BBA6);
  static const Color bgEscuro = Color(0xFF020618);
  static const Color surfaceEscuro = Color(0xFF0F172A);
  static const Color textAccentEscuro = Color(0xFFFFFFFF);
  static const Color textSecundarioEscuro = Color(0xFF9fb1d1);
  static const Color borderEscuro = Color(0xFF1E293B);
}

class AppSizes {
  static const double radiusLG = 16.0;
}

class AppTheme {
  // --- TEMA CLARO ---
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryClaro,
        surface: AppColors.surfaceClaro,
        onPrimary: Colors.white,
        onSurface: AppColors.textPrimaryClaro,
      ),
      scaffoldBackgroundColor: AppColors.bgClaro,
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: AppColors.textPrimaryClaro),
        bodyMedium: TextStyle(color: AppColors.textMutedClaro),
      ),
      elevatedButtonTheme: _buttonTheme(AppColors.primaryClaro, Colors.white),
    );
  }

  // --- TEMA ESCURO ---
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryEscuro,
        surface: AppColors.surfaceEscuro,
        onPrimary: Colors.white,
        onSurface: AppColors.textAccentEscuro,
      ),
      scaffoldBackgroundColor: AppColors.bgEscuro,
      dividerColor: AppColors.borderEscuro,
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: AppColors.textAccentEscuro, fontSize: 16),
        headlineMedium: TextStyle(
          color: AppColors.textAccentEscuro,
          fontWeight: FontWeight.bold,
        ),
        bodyMedium: TextStyle(
          color: AppColors.textSecundarioEscuro,
          fontSize: 14,
        ),
      ),
      elevatedButtonTheme: _buttonTheme(AppColors.primaryEscuro, Colors.white),
    );
  }

  static ElevatedButtonThemeData _buttonTheme(Color bg, Color text) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: bg,
        foregroundColor: text,
        elevation: 0,
        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      ),
    );
  }
}

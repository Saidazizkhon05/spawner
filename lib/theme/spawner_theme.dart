import 'package:flutter/material.dart';

import 'package:spawner/theme/spawner_colors.dart';

class SpawnerTheme {
  SpawnerTheme._();

  static ThemeData get dark {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: SpawnerColors.background,
      colorScheme: const ColorScheme.dark(
        primary: SpawnerColors.primary,
        secondary: SpawnerColors.accent,
        surface: SpawnerColors.surface,
        error: SpawnerColors.danger,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: SpawnerColors.textPrimary,
        onError: Colors.white,
      ),
      fontFamily: '.SF Pro Text',
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: SpawnerColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
        iconTheme: IconThemeData(color: SpawnerColors.textSecondary),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: SpawnerColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: SpawnerColors.surfaceBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: SpawnerColors.surfaceBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: SpawnerColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: SpawnerColors.danger),
        ),
        labelStyle: const TextStyle(color: SpawnerColors.textMuted, fontSize: 14),
        hintStyle: const TextStyle(color: SpawnerColors.textMuted, fontSize: 14),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: SpawnerColors.textPrimary,
          fontSize: 28,
          fontWeight: FontWeight.w800,
          letterSpacing: -1,
        ),
        headlineSmall: TextStyle(
          color: SpawnerColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
        titleMedium: TextStyle(
          color: SpawnerColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        bodyMedium: TextStyle(color: SpawnerColors.textSecondary, fontSize: 14),
        bodySmall: TextStyle(color: SpawnerColors.textMuted, fontSize: 12),
      ),
    );
  }
}

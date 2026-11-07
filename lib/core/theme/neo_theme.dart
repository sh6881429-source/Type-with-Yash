import 'package:flutter/material.dart';

import 'neo_colors.dart';

class NeoTheme {
  NeoTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: NeoColors.background,
      fontFamily: 'Segoe UI',
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: NeoColors.yellow,
        onPrimary: NeoColors.textPrimary,
        secondary: NeoColors.purple,
        onSecondary: NeoColors.textOnDark,
        error: NeoColors.coral,
        onError: NeoColors.textPrimary,
        surface: NeoColors.surface,
        onSurface: NeoColors.textPrimary,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 34,
          fontWeight: FontWeight.w900,
          color: NeoColors.textPrimary,
          letterSpacing: -0.5,
        ),
        displayMedium: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w800,
          color: NeoColors.textPrimary,
          letterSpacing: -0.3,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: NeoColors.textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: NeoColors.textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: NeoColors.textPrimary,
          height: 1.4,
        ),
        bodyMedium: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: NeoColors.textSecondary,
          height: 1.4,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

/// Centralized Neo-Brutalism Color Palette
class NeoColors {
  NeoColors._();

  // Primary Canvas & Surfaces
  static const Color background = Color(0xFFFFF8E8); // Warm cream
  static const Color surface = Color(0xFFFFFFFF); // Pure white card surface
  static const Color surfaceSubtle = Color(0xFFF9F5EC); // Muted cream surface

  // Brand Accent Palette
  static const Color yellow = Color(0xFFFFE45C); // Bright yellow primary CTA
  static const Color lavender = Color(0xFFD9C8FF); // Lavender accent
  static const Color purple = Color(0xFF8062D6); // Deep vibrant purple
  static const Color mint = Color(0xFFB9F3D0); // Mint green accent
  static const Color coral = Color(0xFFFF986B); // Coral orange accent
  static const Color pink = Color(0xFFFFB8D0); // Soft pink accent

  // High-contrast Outlines and Text
  static const Color border = Color(
    0xFF171717,
  ); // Near-black 2-3px solid outlines
  static const Color shadow = Color(0xFF171717); // Hard solid black drop shadow
  static const Color textPrimary = Color(0xFF171717); // High contrast body text
  static const Color textSecondary = Color(0xFF525252); // Muted secondary text
  static const Color textOnDark = Color(
    0xFFFFFFFF,
  ); // Text on dark purple buttons

  // Interactive states
  static const Color yellowHover = Color(0xFFFFDA33);
  static const Color lavenderHover = Color(0xFFC8B3FF);
}

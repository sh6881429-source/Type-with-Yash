import 'package:flutter/material.dart';

import 'neo_colors.dart';

/// Neo-Brutalism Zero-Blur Hard Drop Shadows
class NeoShadows {
  NeoShadows._();

  /// Standard card hard drop shadow (Offset 5, 5)
  static const List<BoxShadow> card = [
    BoxShadow(
      color: NeoColors.shadow,
      offset: Offset(5, 5),
      blurRadius: 0,
      spreadRadius: 0,
    ),
  ];

  /// Prominent hero element hard drop shadow (Offset 7, 7)
  static const List<BoxShadow> hero = [
    BoxShadow(
      color: NeoColors.shadow,
      offset: Offset(7, 7),
      blurRadius: 0,
      spreadRadius: 0,
    ),
  ];

  /// Interactive button normal state shadow (Offset 4, 4)
  static const List<BoxShadow> button = [
    BoxShadow(
      color: NeoColors.shadow,
      offset: Offset(4, 4),
      blurRadius: 0,
      spreadRadius: 0,
    ),
  ];

  /// Interactive button pressed state shadow (Offset 1, 1)
  static const List<BoxShadow> buttonPressed = [
    BoxShadow(
      color: NeoColors.shadow,
      offset: Offset(1, 1),
      blurRadius: 0,
      spreadRadius: 0,
    ),
  ];

  /// Subtle badge/pill shadow (Offset 2, 2)
  static const List<BoxShadow> badge = [
    BoxShadow(
      color: NeoColors.shadow,
      offset: Offset(2, 2),
      blurRadius: 0,
      spreadRadius: 0,
    ),
  ];
}

import 'package:flutter/material.dart';

import '../../core/theme/neo_colors.dart';

/// Reusable Neo-Brutalist container box with thick solid outline and hard shadow
class NeoBox extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;
  final Color borderColor;
  final Color shadowColor;
  final double borderWidth;
  final double borderRadius;
  final Offset shadowOffset;
  final EdgeInsetsGeometry padding;
  final double? width;
  final double? height;
  final AlignmentGeometry? alignment;

  const NeoBox({
    super.key,
    required this.child,
    this.backgroundColor = NeoColors.surface,
    this.borderColor = NeoColors.border,
    this.shadowColor = NeoColors.shadow,
    this.borderWidth = 2.5,
    this.borderRadius = 12.0,
    this.shadowOffset = const Offset(4.0, 4.0),
    this.padding = const EdgeInsets.all(16.0),
    this.width,
    this.height,
    this.alignment,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      alignment: alignment,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: borderColor, width: borderWidth),
        boxShadow: shadowOffset == Offset.zero
            ? null
            : [
                BoxShadow(
                  color: shadowColor,
                  offset: shadowOffset,
                  blurRadius: 0,
                  spreadRadius: 0,
                ),
              ],
      ),
      padding: padding,
      child: child,
    );
  }
}

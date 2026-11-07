import 'package:flutter/material.dart';

import '../../core/theme/neo_colors.dart';
import 'neo_box.dart';

/// Distinctive Neo-Brutalist feature card with icon container, title, and body
class NeoCard extends StatelessWidget {
  final Widget icon;
  final String title;
  final String description;
  final Color cardColor;
  final Color? iconContainerColor;
  final VoidCallback? onTap;
  final double? width;
  final double? minHeight;

  const NeoCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.cardColor = NeoColors.lavender,
    this.iconContainerColor,
    this.onTap,
    this.width,
    this.minHeight,
  });

  @override
  Widget build(BuildContext context) {
    Widget cardContent = Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Icon container box with hard outline
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            color: iconContainerColor ?? Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: NeoColors.border, width: 2.5),
            boxShadow: const [
              BoxShadow(
                color: NeoColors.shadow,
                offset: Offset(3, 3),
                blurRadius: 0,
              ),
            ],
          ),
          child: Center(child: icon),
        ),
        const SizedBox(height: 16),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: NeoColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6.0),
          child: Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: NeoColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
        ),
      ],
    );

    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: minHeight ?? 0.0),
      child: NeoBox(
        width: width,
        backgroundColor: cardColor,
        borderRadius: 14,
        borderWidth: 2.5,
        shadowOffset: const Offset(5, 5),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 14),
        child: cardContent,
      ),
    );
  }
}

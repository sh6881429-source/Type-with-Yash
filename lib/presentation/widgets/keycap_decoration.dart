import 'package:flutter/material.dart';

import '../../core/theme/neo_colors.dart';

/// Decorative Neo-Brutalist keycaps (A-S-D cluster) matching Reference Image 2
class KeycapDecoration extends StatelessWidget {
  final double scale;

  const KeycapDecoration({super.key, this.scale = 1.0});

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: scale,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: NeoColors.purple.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: NeoColors.border, width: 2.2),
          boxShadow: const [
            BoxShadow(
              color: NeoColors.shadow,
              offset: Offset(3, 3),
              blurRadius: 0,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildKeycap('A', NeoColors.yellow),
            const SizedBox(width: 8),
            _buildKeycap('S', NeoColors.mint),
            const SizedBox(width: 8),
            _buildKeycap('D', NeoColors.pink),
          ],
        ),
      ),
    );
  }

  Widget _buildKeycap(String letter, Color color) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: NeoColors.border, width: 2.2),
        boxShadow: const [
          BoxShadow(
            color: NeoColors.shadow,
            offset: Offset(2.5, 2.5),
            blurRadius: 0,
          ),
        ],
      ),
      child: Center(
        child: Text(
          letter,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: NeoColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

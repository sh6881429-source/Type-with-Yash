import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/neo_colors.dart';

/// Mechanical keyboard brand emblem and wordmark for "Type with Yash"
class AppLogo extends StatelessWidget {
  final double size;
  final bool showWordmark;
  final bool showTagline;
  final bool compact;

  const AppLogo({
    super.key,
    this.size = 64.0,
    this.showWordmark = true,
    this.showTagline = false,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget emblem = SizedBox(
      width: size,
      height: size,
      child: Image.asset(
        AppConstants.iconAsset,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => CustomPaint(
          size: Size(size, size),
          painter: _VectorKeyboardPainter(),
        ),
      ),
    );

    if (!showWordmark) {
      return emblem;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        emblem,
        SizedBox(width: compact ? 10 : 14),
        Flexible(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 4,
                children: [
                  Text(
                    'Type with ',
                    style: TextStyle(
                      fontFamily: 'Segoe UI',
                      fontSize: compact ? 17 : 22,
                      fontWeight: FontWeight.w900,
                      color: NeoColors.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: NeoColors.lavender,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: NeoColors.border, width: 2),
                      boxShadow: const [
                        BoxShadow(
                          color: NeoColors.shadow,
                          offset: Offset(2, 2),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: Text(
                      'Yash',
                      style: TextStyle(
                        fontFamily: 'Segoe UI',
                        fontSize: compact ? 17 : 22,
                        fontWeight: FontWeight.w900,
                        color: NeoColors.purple,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                ],
              ),
              if (showTagline) ...[
                const SizedBox(height: 3),
                const Text(
                  AppConstants.appTagline,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(
                    fontFamily: 'Segoe UI',
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: NeoColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Fallback vector mechanical keyboard painter with Neo-Brutalist keycaps
class _VectorKeyboardPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final borderPaint = Paint()
      ..color = NeoColors.border
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final bodyPaint = Paint()
      ..color = NeoColors.purple
      ..style = PaintingStyle.fill;

    // Keyboard body
    final bodyRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, size.height * 0.15, size.width, size.height * 0.7),
      const Radius.circular(6),
    );
    canvas.drawRRect(bodyRRect, bodyPaint);
    canvas.drawRRect(bodyRRect, borderPaint);

    // Keycaps colors
    final colors = [
      NeoColors.yellow,
      NeoColors.pink,
      NeoColors.mint,
      NeoColors.lavender,
      Colors.white,
    ];

    final double keyW = size.width / 5.5;
    final double keyH = size.height * 0.22;

    for (int row = 0; row < 2; row++) {
      for (int col = 0; col < 4; col++) {
        final keyPaint = Paint()
          ..color = colors[(col + row * 2) % colors.length]
          ..style = PaintingStyle.fill;

        final keyRect = RRect.fromRectAndRadius(
          Rect.fromLTWH(
            size.width * 0.08 + col * (keyW + 2.0),
            size.height * 0.25 + row * (keyH + 2.5),
            keyW,
            keyH,
          ),
          const Radius.circular(2.5),
        );
        canvas.drawRRect(keyRect, keyPaint);
        canvas.drawRRect(keyRect, borderPaint..strokeWidth = 1.2);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

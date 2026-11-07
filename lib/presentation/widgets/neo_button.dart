import 'package:flutter/material.dart';

import '../../core/theme/neo_colors.dart';

/// Tactile Neo-Brutalist interactive button with realistic physical push feedback
class NeoButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final String label;
  final Widget? icon;
  final Color backgroundColor;
  final Color textColor;
  final Color borderColor;
  final double borderWidth;
  final double borderRadius;
  final double height;
  final EdgeInsetsGeometry padding;
  final bool isFullWidth;
  final TextStyle? textStyle;

  const NeoButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.icon,
    this.backgroundColor = NeoColors.yellow,
    this.textColor = NeoColors.textPrimary,
    this.borderColor = NeoColors.border,
    this.borderWidth = 2.5,
    this.borderRadius = 10.0,
    this.height = 48.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 20.0),
    this.isFullWidth = false,
    this.textStyle,
  });

  @override
  State<NeoButton> createState() => _NeoButtonState();
}

class _NeoButtonState extends State<NeoButton> {
  bool _isPressed = false;
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = widget.onPressed != null;
    final double offsetAmount = _isPressed ? 1.0 : (_isHovered ? 5.0 : 4.0);

    Widget content = Row(
      mainAxisSize: widget.isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.icon != null) ...[widget.icon!, const SizedBox(width: 8)],
        Flexible(
          child: Text(
            widget.label,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style:
                widget.textStyle ??
                TextStyle(
                  color: isEnabled ? widget.textColor : NeoColors.textSecondary,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.2,
                ),
          ),
        ),
      ],
    );

    return MouseRegion(
      cursor: isEnabled
          ? SystemMouseCursors.click
          : SystemMouseCursors.forbidden,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() {
        _isHovered = false;
        _isPressed = false;
      }),
      child: GestureDetector(
        onTapDown: isEnabled ? (_) => setState(() => _isPressed = true) : null,
        onTapUp: isEnabled
            ? (_) {
                setState(() => _isPressed = false);
                widget.onPressed?.call();
              }
            : null,
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 60),
          transform: Matrix4.translationValues(
            _isPressed ? 3.0 : 0.0,
            _isPressed ? 3.0 : 0.0,
            0.0,
          ),
          width: widget.isFullWidth ? double.infinity : null,
          height: widget.height,
          padding: widget.padding,
          decoration: BoxDecoration(
            color: isEnabled ? widget.backgroundColor : const Color(0xFFE5E5E5),
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: Border.all(
              color: widget.borderColor,
              width: widget.borderWidth,
            ),
            boxShadow: [
              BoxShadow(
                color: NeoColors.shadow,
                offset: Offset(offsetAmount, offsetAmount),
                blurRadius: 0,
                spreadRadius: 0,
              ),
            ],
          ),
          alignment: Alignment.center,
          child: content,
        ),
      ),
    );
  }
}

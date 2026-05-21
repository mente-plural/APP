import 'package:flutter/material.dart';

import '../../app_theme.dart';

class BaseButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color hoverColor;
  final bool isGhost;

  const BaseButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.hoverColor,
    this.isGhost = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.hovered) || states.contains(WidgetState.pressed)) {
            return hoverColor;
          }
          return backgroundColor;
        }),
        foregroundColor: WidgetStateProperty.all(foregroundColor),
        elevation: WidgetStateProperty.all(0),
        shadowColor: WidgetStateProperty.all(Colors.transparent),
        overlayColor: WidgetStateProperty.all(
            hoverColor.withValues(alpha: 0.1)),
        minimumSize: WidgetStateProperty.all(const Size(double.infinity, 56)),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusLG),
            side: isGhost ? BorderSide.none : BorderSide.none,
          ),
        ),
      ),
      child: isLoading
          ? SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 24),
                  const SizedBox(width: 12),
                ],
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: foregroundColor,
                  ),
                ),
              ],
            ),
    );
  }
}

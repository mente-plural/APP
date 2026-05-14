import 'package:flutter/material.dart';
import 'base_button.dart';

class SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;

  const SecondaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return BaseButton(
      label: label,
      onPressed: onPressed,
      isLoading: isLoading,
      icon: icon,
      backgroundColor: const Color(0xFF1E293B),
      foregroundColor: const Color(0xFFF1F5F9), // Slate 100
      hoverColor: const Color(0xFF334155),
    );
  }
}

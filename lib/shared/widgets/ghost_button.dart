import 'package:flutter/material.dart';
import 'base_button.dart';

class GhostButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;

  const GhostButton({
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
      backgroundColor: Colors.transparent,
      foregroundColor: const Color(0xFF2DD4BF), // Teal 400
      hoverColor: const Color(0xFF1E293B),
      isGhost: true,
    );
  }
}

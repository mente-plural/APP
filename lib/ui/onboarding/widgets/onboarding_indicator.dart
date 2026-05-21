import 'package:flutter/material.dart';

import '../../../app_theme.dart';

class OnboardingIndicator extends StatelessWidget {
  final int itemCount;
  final int currentIndex;

  const OnboardingIndicator({
    super.key,
    required this.itemCount,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        itemCount,
        (index) => _buildDot(index, theme),
      ),
    );
  }

  Widget _buildDot(int index, ThemeData theme) {
    final isSelected = currentIndex == index;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: isSelected ? 24 : 8,
      decoration: BoxDecoration(
        color: isSelected
            ? theme.colorScheme.primary
            : theme.dividerColor.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../app_theme.dart';

class FixedOnboardingTitle extends StatelessWidget {
  final String title;

  const FixedOnboardingTitle({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;
    
    return SafeArea(
      child: IgnorePointer(
        child: Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: EdgeInsets.only(top: isTablet ? AppSizes.radiusLG * 4 : AppSizes.radiusLG * 2),
            child: Text(
              title,
              style: (isTablet ? theme.textTheme.displaySmall : theme.textTheme.headlineLarge)?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

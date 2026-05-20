import 'package:flutter/material.dart';
import '../../../app_theme.dart';
import '../models/onboarding_data.dart';

class OnboardingPageContent extends StatelessWidget {
  final OnboardingData data;

  const OnboardingPageContent({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final bgColor = theme.scaffoldBackgroundColor;
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Container(
      color: bgColor,
      width: double.infinity,
      height: double.infinity,
      child: SingleChildScrollView(
        child: Container(
          constraints: BoxConstraints(minHeight: size.height),
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? size.width * 0.15 : AppSizes.radiusLG * 1.5,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: isTablet ? 140 : 100), // Espaço para o título fixo
              Icon(
                data.icon,
                size: isTablet ? 180 : 120,
                color: primaryColor,
              ),
              SizedBox(height: isTablet ? AppSizes.radiusLG * 4 : AppSizes.radiusLG * 2),
              Text(
                data.title,
                style: (isTablet ? theme.textTheme.displaySmall : theme.textTheme.headlineLarge)?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSizes.radiusLG),
              Text(
                data.description,
                style: (isTablet ? theme.textTheme.headlineSmall : theme.textTheme.bodyLarge)?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.normal,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: isTablet ? 200 : 140), // Espaço para os controles inferiores
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../app_theme.dart';
import './onboarding_indicator.dart';

class OnboardingNavigation extends StatelessWidget {
  final int itemCount;
  final int currentIndex;
  final VoidCallback onNext;
  final String nextButtonLabel;

  const OnboardingNavigation({
    super.key,
    required this.itemCount,
    required this.currentIndex,
    required this.onNext,
    required this.nextButtonLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Positioned(
      bottom: isTablet ? AppSizes.radiusLG * 4 : AppSizes.radiusLG * 2.5,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: isTablet ? 450 : double.infinity),
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.radiusLG),
          child: Column(
            children: [
              OnboardingIndicator(
                itemCount: itemCount,
                currentIndex: currentIndex,
              ),
              const SizedBox(height: AppSizes.radiusLG * 2),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  key: ValueKey('onboarding_btn_$currentIndex'),
                  onPressed: onNext,
                  child: Text(
                    nextButtonLabel,
                    style: TextStyle(fontSize: isTablet ? 18 : 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

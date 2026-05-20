import 'package:flutter/material.dart';
import '../../../app_theme.dart';

class ProfileSelectionHeader extends StatelessWidget {
  final int currentStep;
  final String title;

  const ProfileSelectionHeader({
    super.key,
    required this.currentStep,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: AppColors.textAccentEscuro,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Text(
              "$currentStep de 4",
              style: const TextStyle(
                color: AppColors.primaryEscuro,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          height: 6,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.surfaceEscuro,
            borderRadius: BorderRadius.circular(10),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: currentStep / 4,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.primaryEscuro,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

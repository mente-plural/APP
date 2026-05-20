import 'package:flutter/material.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/secondary_button.dart';

class ProfileSelectionFooter extends StatelessWidget {
  final int currentStep;
  final VoidCallback onNext;
  final VoidCallback onPrevious;

  const ProfileSelectionFooter({
    super.key,
    required this.currentStep,
    required this.onNext,
    required this.onPrevious,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (currentStep > 1)
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: SecondaryButton(
                label: "Voltar",
                onPressed: onPrevious,
              ),
            ),
          ),
        Expanded(
          flex: 2,
          child: PrimaryButton(
            label: currentStep < 4 ? "Continuar" : "Finalizar",
            onPressed: onNext,
          ),
        ),
      ],
    );
  }
}

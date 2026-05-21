import 'package:flutter/material.dart';
import '../../../shared/widgets/page_header.dart';

class RegisterHeader extends StatelessWidget {
  const RegisterHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        PageHeader(
          title: 'Criar Conta',
          leading: BackButton(
            color: theme.colorScheme.onSurface,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Preencha seus dados para começar',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha:0.6),
          ),
        ),
      ],
    );
  }
}

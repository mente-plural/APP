import 'package:flutter/material.dart';
import '../../../shared/widgets/page_header.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const PageHeader(title: 'Entrar', center: true),
        const SizedBox(height: 8),
        Text(
          'Bem-vindo de volta!',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha:0.6),
          ),
        ),
      ],
    );
  }
}

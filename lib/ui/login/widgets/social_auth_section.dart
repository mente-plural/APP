import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../../../app_theme.dart';

class SocialAuthSection extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onGoogleSignIn;
  final VoidCallback onAppleSignIn;

  const SocialAuthSection({
    super.key,
    required this.isLoading,
    required this.onGoogleSignIn,
    required this.onAppleSignIn,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isAppleVisible = kIsWeb || Platform.isIOS || Platform.isMacOS;

    return Column(
      children: [
        Text('ou continue com', style: theme.textTheme.bodyMedium),
        const SizedBox(height: 24),
        _SocialAuthButton(
          icon: Icons.g_mobiledata,
          label: 'Continuar com Google',
          onPressed: onGoogleSignIn,
          isLoading: isLoading,
        ),
        if (isAppleVisible) ...[
          const SizedBox(height: 12),
          _SocialAuthButton(
            icon: Icons.apple,
            label: 'Continuar com Apple',
            onPressed: onAppleSignIn,
            isLoading: isLoading,
          ),
        ],
      ],
    );
  }
}

class _SocialAuthButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool isLoading;

  const _SocialAuthButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return OutlinedButton.icon(
      onPressed: isLoading ? null : onPressed,
      icon: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(icon, color: theme.colorScheme.onSurface),
      label: Text(
        label,
        style: TextStyle(
          color: theme.colorScheme.onSurface.withValues(alpha:
            isLoading ? 0.5 : 1.0,
          ),
        ),
      ),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 56),
        side: BorderSide(color: theme.dividerColor),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        ),
      ),
    );
  }
}

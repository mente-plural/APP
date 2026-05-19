import 'dart:io' show Platform;

import 'package:app/ui/profile_selection/profile_selection_page.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app_theme.dart';
import '../../core/auth/auth_service.dart';
import '../../shared/utils/ui_utils.dart';
import '../../shared/widgets/custom_text_field.dart';
import '../../shared/widgets/primary_button.dart';
import '../../shared/widgets/page_header.dart';
import '../home/home_page.dart';
import '../register/register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _authService = AuthService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleEmailSignIn() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      UiUtils.showSnackBar(context, "Por favor, preencha todos os campos.", isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      debugPrint("LoginPage: Iniciando login para $email");
      await _authService.loginWithEmail(email, password);
      debugPrint("LoginPage: loginWithEmail concluído");

      if (mounted) {
        UiUtils.showSnackBar(context, "Login realizado com sucesso!");
      }
    } catch (e) {
      if (mounted) {
        final errorMsg = e.toString().replaceAll('Exception: ', '');
        debugPrint(e.toString());
        UiUtils.showSnackBar(context, errorMsg, isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);

    try {
      final success = await _authService.loginWithGoogle();
      if (mounted) {
        if (success) {
          UiUtils.showSnackBar(context, "Login social realizado com sucesso!");
        } else {
          UiUtils.showSnackBar(context, "Login cancelado.", isError: true);
        }
      }
    } catch (e) {
      if (mounted) {
        final errorStr = e.toString().toLowerCase();
        if (errorStr.contains('canceled') || errorStr.contains('cancelled')) {
          UiUtils.showSnackBar(context, "Login cancelado.", isError: true);
        } else {
          UiUtils.showSnackBar(context, "Erro no Google Login: $e", isError: true);
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const PageHeader(title: 'Entrar'),
              const SizedBox(height: 8),
              Text(
                'Bem-vindo de volta!',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 48),

            CustomTextField(
              label: 'Email',
              hint: 'seu@email.com',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 24),

            CustomTextField(
              label: 'Senha',
              hint: '********',
              controller: _passwordController,
              isPassword: true,
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: 32),

            PrimaryButton(
              label: 'Entrar',
              onPressed: _handleEmailSignIn,
              isLoading: _isLoading,
            ),

            const SizedBox(height: 24),
            Text('ou continue com', style: theme.textTheme.bodyMedium),
            const SizedBox(height: 24),

            _SocialAuthButton(
              icon: Icons.g_mobiledata,
              label: 'Continuar com Google',
              onPressed: _handleGoogleSignIn,
              isLoading: _isLoading,
            ),

            if (!kIsWeb && Platform.isIOS) ...[
              const SizedBox(height: 12),
              _SocialAuthButton(
                icon: Icons.apple,
                label: 'Continuar com Apple',
                onPressed: () {},
                isLoading: _isLoading,
              ),
            ],

            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Ainda não tem conta? '),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const RegisterPage()),
                    );
                  },
                  child: const Text(
                    'Criar conta',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ));
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
          color: theme.colorScheme.onSurface.withOpacity(
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

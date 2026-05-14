import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../../app_theme.dart';
import '../../core/auth_service.dart';
import '../../core/providers/profile_provider.dart';
import '../../shared/utils/ui_utils.dart';
import '../../shared/widgets/custom_text_field.dart';
import '../../shared/widgets/primary_button.dart';
import '../../shared/widgets/secondary_button.dart';
import '../../shared/widgets/ghost_button.dart';
import '../home/home_page.dart';
import '../register/register.dart';

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

    final profileProvider = Provider.of<ProfileProvider>(
        context, listen: false);
    final profileId = profileProvider.selectedProfile?.id;

    setState(() => _isLoading = true);

    try {
      await _authService.loginWithEmail(email, password, profile: profileId);

      if (mounted) {
        UiUtils.showSnackBar(context, "Login realizado com sucesso!");
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomePage()),
              (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        final errorMsg = e.toString().replaceAll('Exception: ', '');
        UiUtils.showSnackBar(context, errorMsg, isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    final profileProvider = Provider.of<ProfileProvider>(
        context, listen: false);
    final profileId = profileProvider.selectedProfile?.id;

    setState(() => _isLoading = true);

    try {
      await _authService.loginWithGoogle(profile: profileId);
      if (mounted) {
        UiUtils.showSnackBar(context, "Login social realizado com sucesso!");
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomePage()),
              (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        UiUtils.showSnackBar(context, "Erro no Google Login: $e", isError: true);
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
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.all(AppSizes.radiusLG),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 80),
            Icon(
              Icons.app_registration,
              color: theme.colorScheme.primary,
              size: 80,
            ),
            const SizedBox(height: 20),
            Text(
              'Bem-vindo(a)',
              style: theme.textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Acesse sua conta para continuar',
              style: theme.textTheme.bodyLarge
            ),
            const SizedBox(height: 48),

            CustomTextField(
              label: 'E-mail',
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

            GhostButton(
              label: 'Criar nova conta',
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const RegisterPage()),
                );
              },
            ),
            const SizedBox(height: 24),

            Text('ou continue com', style: theme.textTheme.bodyMedium),
            const SizedBox(height: 32),

            SecondaryButton(
              icon: Icons.mail_outline_rounded,
              label: 'Google',
              onPressed: _handleGoogleSignIn,
              isLoading: _isLoading,
            ),

            // if (!kIsWeb && Platform.isIOS) ...[
              const SizedBox(height: 12),
              SecondaryButton(
                icon: Icons.apple_rounded,
                label: 'Apple',
                onPressed: () {},
                isLoading: _isLoading,
              ),
            // ],


          ],
        ),
      ),
    );
  }
}

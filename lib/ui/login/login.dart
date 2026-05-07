import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'login_controller.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final LoginController _controller;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = LoginController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, child) {
          return SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.all(AppSizes.radiusLG * 1.5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 100),
                Text(
                  'Entrar',
                  style: theme.textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Bem-vindo de volta!',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 48),

                _buildTextField(
                  context,
                  label: 'Email',
                  hint: 'seu@email.com',
                  controller: _emailController,
                ),
                const SizedBox(height: 24),

                _buildTextField(
                  context,
                  label: 'Senha',
                  hint: '********',
                  controller: _passwordController,
                  obscureText: true,
                ),
                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _controller.isLoading
                        ? null
                        : () async {
                      try {
                        await _controller.signInWithEmail(
                          _emailController.text.trim(),
                          _passwordController.text.trim(),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Erro ao entrar: $e")),
                        );
                      }
                    },
                    child: _controller.isLoading
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                        : const Text('Entrar'),
                  ),
                ),

                const SizedBox(height: 24),
                Text(
                  'ou continue com',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),

                _buildSocialButton(
                  context,
                  icon: Icons.g_mobiledata,
                  label: 'Continuar com Google',
                  onPressed: _controller.isLoading
                      ? () {}
                      : () async {
                    final success = await _controller.signInWithGoogle();
                    if (!success && mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(_controller.errorMessage ?? "Erro ao entrar")),
                      );
                    }
                  },
                ),

                const SizedBox(height: 12),

                _buildSocialButton(
                  context,
                  icon: Icons.apple,
                  label: 'Continuar com Apple',
                  onPressed: _controller.isLoading
                      ? () {}
                      : () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Login com Apple estará disponível em breve.")),
                    );
                  },
                ),

                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Ainda não tem conta? ',
                      style: TextStyle(color: colorScheme.onSurface),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        'Criar conta',
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField(BuildContext context,
      {required String label,
        required String hint,
        required TextEditingController controller,
        bool obscureText = false}) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscureText,
          style: TextStyle(color: theme.colorScheme.onSurface),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.4)),
            filled: true,
            fillColor: theme.colorScheme.surface,
            contentPadding: const EdgeInsets.all(16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusLG),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusLG),
              borderSide: BorderSide(color: theme.dividerColor.withOpacity(0.1)),
            ),
          ),
        ),
      ],
    );
  }
  Widget _buildSocialButton(BuildContext context,
      {required IconData icon, required String label, required VoidCallback onPressed}) {
    final theme = Theme.of(context);
    final isBusy = _controller.isLoading;

    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: isBusy
          ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2)
      )
          : Icon(icon, color: theme.colorScheme.onSurface),
      label: Text(
        label,
        style: TextStyle(
            color: theme.colorScheme.onSurface.withOpacity(isBusy ? 0.5 : 1.0)
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
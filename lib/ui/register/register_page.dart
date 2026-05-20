import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app_theme.dart';
import '../../core/auth/auth_service.dart';
import '../../shared/utils/ui_utils.dart';
import '../../shared/widgets/custom_text_field.dart';
import '../../shared/widgets/primary_button.dart';
import '../../shared/widgets/page_header.dart';
import '../login/login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();
  
  final _authService = AuthService();
  bool _isLoading = false;

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _telefoneController.dispose();
    _senhaController.dispose();
    _confirmarSenhaController.dispose();
    super.dispose();
  }

  Future<void> _handleEmailSignUp() async {
    final nome = _nomeController.text.trim();
    final email = _emailController.text.trim();
    final telefone = _telefoneController.text.trim();
    final senha = _senhaController.text.trim();
    final confirmarSenha = _confirmarSenhaController.text.trim();

    if (nome.isEmpty || email.isEmpty || telefone.isEmpty || senha.isEmpty) {
      UiUtils.showSnackBar(context, "Por favor, preencha todos os campos.", isError: true);
      return;
    }

    if (senha != confirmarSenha) {
      UiUtils.showSnackBar(context, "As senhas não coincidem.", isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authService.registerWithEmail(
        email: email,
        password: senha,
        name: nome,
        phone: telefone
      );

      if (mounted) {
        UiUtils.showSnackBar(
            context, "Conta criada com sucesso!");
        Navigator.of(context).pop();
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
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 40),

            CustomTextField(
              label: 'Nome Completo',
              hint: 'Digite seu nome completo',
              controller: _nomeController,
              icon: Icons.person_outline,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 20),

            CustomTextField(
              label: 'Email',
              hint: 'seu@email.com',
              controller: _emailController,
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 20),

            CustomTextField(
              label: 'Telefone',
              hint: '(00) 0 0000-0000',
              controller: _telefoneController,
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 20),

            CustomTextField(
              label: 'Senha',
              hint: '********',
              controller: _senhaController,
              icon: Icons.lock_outline,
              isPassword: true,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 20),

            CustomTextField(
              label: 'Confirmar Senha',
              hint: '********',
              controller: _confirmarSenhaController,
              icon: Icons.lock_reset_outlined,
              isPassword: true,
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: 40),

            PrimaryButton(
              label: 'Criar Conta',
              onPressed: _handleEmailSignUp,
              isLoading: _isLoading,
            ),

            const SizedBox(height: 32),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Já tem uma conta? '),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'Fazer login',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    ),
  );
}
}

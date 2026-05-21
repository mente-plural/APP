import 'package:flutter/material.dart';

import '../../core/auth/auth_service.dart';
import '../../shared/utils/ui_utils.dart';
import '../../shared/widgets/primary_button.dart';
import './widgets/register_header.dart';
import './widgets/register_form.dart';
import './widgets/register_footer.dart';

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
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const RegisterHeader(),
                  const SizedBox(height: 40),
                  RegisterForm(
                    nomeController: _nomeController,
                    emailController: _emailController,
                    telefoneController: _telefoneController,
                    senhaController: _senhaController,
                    confirmarSenhaController: _confirmarSenhaController,
                  ),
                  const SizedBox(height: 40),
                  PrimaryButton(
                    label: 'Criar Conta',
                    onPressed: _handleEmailSignUp,
                    isLoading: _isLoading,
                  ),
                  const SizedBox(height: 32),
                  RegisterFooter(
                    onLoginPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../core/auth/auth_service.dart';
import '../../shared/utils/ui_utils.dart';
import '../../shared/widgets/primary_button.dart';
import '../register/register_page.dart';
import './widgets/login_header.dart';
import './widgets/login_form.dart';
import './widgets/social_auth_section.dart';
import './widgets/login_footer.dart';

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

  void _showForgotPasswordDialog() {
    final emailController = TextEditingController(text: _emailController.text);
    final codeController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    bool isSending = false;
    bool emailSent = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: StatefulBuilder(
            builder: (context, setDialogState) => AlertDialog(
              title: Text(emailSent ? 'Redefinir Senha' : 'Recuperar Senha'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!emailSent) ...[
                      const Text(
                        'Informe seu e-mail para receber as instruções de recuperação.',
                        style: TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        decoration: const InputDecoration(labelText: 'E-mail', hintText: 'seu@email.com'),
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                      ),
                    ] else ...[
                      const Text(
                        'Informe o código recebido por e-mail e sua nova senha.',
                        style: TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        decoration: const InputDecoration(labelText: 'Código', hintText: 'Código de 32 caracteres'),
                        controller: codeController,
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        decoration: const InputDecoration(labelText: 'Nova Senha', hintText: '********'),
                        controller: newPasswordController,
                        obscureText: true,
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        decoration: const InputDecoration(labelText: 'Confirmar Nova Senha', hintText: '********'),
                        controller: confirmPasswordController,
                        obscureText: true,
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSending ? null : () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: isSending
                      ? null
                      : () async {
                          if (!emailSent) {
                            final email = emailController.text.trim();
                            if (email.isEmpty) {
                              UiUtils.showSnackBar(context, "Informe seu e-mail.", isError: true);
                              return;
                            }

                            setDialogState(() => isSending = true);
                            try {
                              await _authService.sendPasswordResetEmail(email);
                              if (context.mounted) {
                                setDialogState(() {
                                  isSending = false;
                                  emailSent = true;
                                });
                                UiUtils.showSnackBar(
                                  context,
                                  "Se o e-mail existir, um código de recuperação foi enviado.",
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                setDialogState(() => isSending = false);
                                UiUtils.showSnackBar(
                                  context,
                                  e.toString().replaceAll('Exception: ', ''),
                                  isError: true,
                                );
                              }
                            }
                          } else {
                            final code = codeController.text.trim();
                            final newPass = newPasswordController.text;
                            final confirmPass = confirmPasswordController.text;

                            if (code.isEmpty || newPass.isEmpty || confirmPass.isEmpty) {
                              UiUtils.showSnackBar(context, "Preencha todos os campos.", isError: true);
                              return;
                            }

                            if (newPass != confirmPass) {
                              UiUtils.showSnackBar(context, "As senhas não coincidem.", isError: true);
                              return;
                            }

                            if (newPass.length < 6) {
                              UiUtils.showSnackBar(context, "A senha deve ter pelo menos 6 caracteres.", isError: true);
                              return;
                            }

                            setDialogState(() => isSending = true);
                            try {
                              await _authService.resetPassword(code, newPass);
                              if (context.mounted) {
                                Navigator.pop(context);
                                UiUtils.showSnackBar(context, "Senha alterada com sucesso!");
                              }
                            } catch (e) {
                              if (context.mounted) {
                                setDialogState(() => isSending = false);
                                UiUtils.showSnackBar(
                                  context,
                                  e.toString().replaceAll('Exception: ', ''),
                                  isError: true,
                                );
                              }
                            }
                          }
                        },
                  child: isSending
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text(emailSent ? 'Redefinir' : 'Enviar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
                  const LoginHeader(),
                  const SizedBox(height: 48),
                  LoginForm(
                    emailController: _emailController,
                    passwordController: _passwordController,
                    onForgotPassword: _showForgotPasswordDialog,
                  ),
                  const SizedBox(height: 16),
                  PrimaryButton(
                    label: 'Entrar',
                    onPressed: _handleEmailSignIn,
                    isLoading: _isLoading,
                  ),
                  const SizedBox(height: 24),
                  SocialAuthSection(
                    isLoading: _isLoading,
                    onGoogleSignIn: _handleGoogleSignIn,
                    onAppleSignIn: () {},
                  ),
                  const SizedBox(height: 32),
                  LoginFooter(
                    onCreateAccount: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const RegisterPage()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


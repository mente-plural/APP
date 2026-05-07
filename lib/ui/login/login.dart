import 'package:flutter/material.dart';
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

  Future<void> _handleAction(Future<bool> Function() action) async {
    final success = await action();
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_controller.errorMessage ?? 'Erro desconhecido')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, child) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_controller.isLoading)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 16.0),
                    child: LinearProgressIndicator(),
                  ),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  enabled: !_controller.isLoading,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Senha',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  enabled: !_controller.isLoading,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: _controller.isLoading
                          ? null
                          : () => _handleAction(() => _controller.signInWithEmail(
                                _emailController.text.trim(),
                                _passwordController.text.trim(),
                              )),
                      child: const Text('Entrar'),
                    ),
                    OutlinedButton(
                      onPressed: _controller.isLoading
                          ? null
                          : () => _handleAction(() => _controller.signUpWithEmail(
                                _emailController.text.trim(),
                                _passwordController.text.trim(),
                              )),
                      child: const Text('Cadastrar'),
                    ),
                  ],
                ),
                const Divider(height: 40),
                ElevatedButton.icon(
                  onPressed: _controller.isLoading
                      ? null
                      : () => _handleAction(_controller.signInWithGoogle),
                  icon: const Icon(Icons.login),
                  label: const Text('Entrar com Google'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 1. Mudamos a cor de fundo para o Dark do layout
      backgroundColor: const Color(0xFF000510),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, child) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 2. Títulos "Entrar" e "Bem-vindo"
                const Text(
                  'Entrar',
                  style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Bem-vindo de volta!',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
                const SizedBox(height: 48),

                // 3. Campo de Email Estilizado
                _buildTextField(
                  label: 'Email',
                  hint: 'seu@email.com',
                  controller: _emailController,
                ),
                const SizedBox(height: 24),

                // 4. Campo de Senha Estilizado
                _buildTextField(
                  label: 'Senha',
                  hint: '********',
                  controller: _passwordController,
                  obscureText: true,
                ),
                const SizedBox(height: 32),

                // 5. Botão "Entrar" Principal (Verde Água)
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {}, // Sua lógica de login aqui
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00CBB0),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Entrar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),

                const SizedBox(height: 24),
                const Text('ou continue com', style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 24),

                // 6. Botões Sociais (Google e Apple)
                _buildSocialButton(icon: Icons.g_mobiledata, label: 'Continuar com Google'),
                const SizedBox(height: 12),
                _buildSocialButton(icon: Icons.apple, label: 'Continuar com Apple'),

                const SizedBox(height: 32),
                // 7. Rodapé "Criar conta"
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Ainda não tem conta? ', style: TextStyle(color: Colors.white)),
                    TextButton(
                      onPressed: () {},
                      child: const Text('Criar conta', style: TextStyle(color: Color(0xFF00CBB0))),
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

  // Função auxiliar para não repetir código de TextField
  Widget _buildTextField({required String label, required String hint, required TextEditingController controller, bool obscureText = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscureText,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.grey),
            filled: true,
            fillColor: const Color(0xFF0B1220),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }

  // Função auxiliar para os botões do Google/Apple
  Widget _buildSocialButton({required IconData icon, required String label}) {
    return OutlinedButton.icon(
      onPressed: () {},
      icon: Icon(icon, color: Colors.white),
      label: Text(label, style: const TextStyle(color: Colors.white)),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 56),
        side: const BorderSide(color: Color(0xFF1E2737)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
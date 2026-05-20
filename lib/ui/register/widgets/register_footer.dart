import 'package:flutter/material.dart';

class RegisterFooter extends StatelessWidget {
  final VoidCallback onLoginPressed;

  const RegisterFooter({
    super.key,
    required this.onLoginPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Já tem uma conta? '),
        TextButton(
          onPressed: onLoginPressed,
          child: const Text(
            'Fazer login',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

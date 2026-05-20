import 'package:flutter/material.dart';

class LoginFooter extends StatelessWidget {
  final VoidCallback onCreateAccount;

  const LoginFooter({
    super.key,
    required this.onCreateAccount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Ainda não tem conta? '),
        TextButton(
          onPressed: onCreateAccount,
          child: const Text(
            'Criar conta',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

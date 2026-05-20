import 'package:flutter/material.dart';
import '../../../shared/widgets/custom_text_field.dart';

class RegisterForm extends StatelessWidget {
  final TextEditingController nomeController;
  final TextEditingController emailController;
  final TextEditingController telefoneController;
  final TextEditingController senhaController;
  final TextEditingController confirmarSenhaController;

  const RegisterForm({
    super.key,
    required this.nomeController,
    required this.emailController,
    required this.telefoneController,
    required this.senhaController,
    required this.confirmarSenhaController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomTextField(
          label: 'Nome Completo',
          hint: 'Digite seu nome completo',
          controller: nomeController,
          icon: Icons.person_outline,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 20),
        CustomTextField(
          label: 'Email',
          hint: 'seu@email.com',
          controller: emailController,
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 20),
        CustomTextField(
          label: 'Telefone',
          hint: '(00) 0 0000-0000',
          controller: telefoneController,
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 20),
        CustomTextField(
          label: 'Senha',
          hint: '********',
          controller: senhaController,
          icon: Icons.lock_outline,
          isPassword: true,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 20),
        CustomTextField(
          label: 'Confirmar Senha',
          hint: '********',
          controller: confirmarSenhaController,
          icon: Icons.lock_reset_outlined,
          isPassword: true,
          textInputAction: TextInputAction.done,
        ),
      ],
    );
  }
}

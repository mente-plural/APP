import 'package:flutter/material.dart';

import '../../core/auth_service.dart';
import '../login/login.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authService.logout();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: Center(
        child: StreamBuilder(
          stream: authService.userStream,
          builder: (context, snapshot) {
            final user = snapshot.data;
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (user?.photoUrl != null)
                  CircleAvatar(
                    backgroundImage: NetworkImage(user!.photoUrl!),
                    radius: 40,
                  ),
                const SizedBox(height: 16),
                Text(
                  'Bem-vindo, ${user?.name ?? user?.email ?? "Usuário"}!',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                const Text('Você está logado com sucesso.'),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () async {
                    await authService.logout();
                    if (context.mounted) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                        (route) => false,
                      );
                    }
                  },
                  child: const Text('Sair da Conta'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

import 'package:app/core/providers/profile_provider.dart';
import 'package:app/ui/profile_selection/profile_selection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user_model.dart';
import 'auth_service.dart';
import '../ui/home/home_page.dart';
import '../ui/login/login.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final profileProvider = Provider.of<ProfileProvider>(context);

    return StreamBuilder<UserModel?>(
      stream: authService.userStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          if (profileProvider.selectedProfile == null) {
            return const ProfileSelectionPage();
          }
          return const HomePage();
        }

        return const LoginPage();
      },
    );
  }
}

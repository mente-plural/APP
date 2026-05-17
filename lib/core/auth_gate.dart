import 'package:app/ui/profile_selection/profile_selection_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user_model.dart';
import 'auth_service.dart';
import '../ui/home/home_page.dart';
import '../ui/login/login_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return StreamBuilder<UserModel?>(
      stream: authService.userStream,
      initialData: authService.currentUser,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          final user = snapshot.data!;
          final profileType = user.preferences.profileType;
          
          // Verifica se o perfil existe e não é uma string "null" ou vazia
          final hasProfile = profileType != null && 
                            profileType != 'null' && 
                            profileType.isNotEmpty;
          
          if (!hasProfile) {
            return const ProfileSelectionPage();
          }
          return const HomePage();
        }


        if (snapshot.connectionState == ConnectionState.waiting && snapshot.data == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(color: Colors.white)),
          );
        }


        return const LoginPage();
      },
    );
  }
}

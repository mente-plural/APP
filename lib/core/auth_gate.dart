import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../models/user_model.dart';
import '../ui/home/home_page.dart';
import '../ui/login/login_page.dart';
import '../ui/profile_selection/profile_selection_page.dart';
import 'auth/auth_service.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  void initState() {
    super.initState();
    debugPrint("AuthGate: Widget Inicializado");
  }

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return StreamBuilder<UserModel?>(
      stream: authService.userStream,
      initialData: authService.currentUser,
      builder: (context, snapshot) {
        final user = snapshot.data;
        final connectionState = snapshot.connectionState;

        debugPrint("AuthGate REBUILD: state=$connectionState, user=${user?.email}, id=${user?.id}");

        // 1. Fluxo de Não Autenticado
        if (user == null) {
          return const LoginPage();
        }

        // 2. Fluxo de Autenticado - Verificação de Perfil (Onboarding)
        if (_isProfileIncomplete(user)) {
          debugPrint("AuthGate: Redirecionando para ProfileSelection");
          return const ProfileSelectionPage();
        }

        // 3. Fluxo Principal
        debugPrint("AuthGate: Redirecionando para HomePage");
        return const HomePage();
      },
    );
  }

  bool _isProfileIncomplete(UserModel user) {
    final profileType = user.preferences.profileType?.toString().trim().toLowerCase();
    if (profileType == null || profileType == 'null' || profileType.isEmpty) {
      return true;
    }
    return false;
  }
}

/// Tela de loading padronizada para o processo de autenticação.
class _AuthLoadingScreen extends StatelessWidget {
  const _AuthLoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.bgEscuro,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: AppColors.primaryEscuro,
              strokeWidth: 3,
            ),
            SizedBox(height: 24),
            Text(
              "Preparando seu ambiente...",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

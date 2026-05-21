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

        if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
          return const _AuthLoadingScreen();
        }

        final user = snapshot.data;
        final connectionState = snapshot.connectionState;

        debugPrint("AuthGate REBUILD: state=$connectionState, user=${user?.email}, id=${user?.id}");


        if (user == null) {
          return const LoginPage();
        }


        if (_isProfileIncomplete(user)) {
          debugPrint("AuthGate: Redirecionando para ProfileSelection");
          return const ProfileSelectionPage();
        }


        debugPrint("AuthGate: Redirecionando para HomePage");
        return const HomePage();
      },
    );
  }

  bool _isProfileIncomplete(UserModel user) {
    final preferences = user.preferences;
    final profileType = preferences.profileType?.toString().trim();
    
    debugPrint("AuthGate: Verificando Perfil - ID: ${user.id}, Type: $profileType, Name: ${user.name}");


    if (profileType == null || profileType.isEmpty || profileType == 'null') {
      return true;
    }
    
    if (user.name == null || user.name!.isEmpty || user.name == 'null') {
      return true;
    }

    return false;
  }
}


class _AuthLoadingScreen extends StatelessWidget {
  const _AuthLoadingScreen();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgEscuro : AppColors.bgClaro,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: isDark ? AppColors.primaryEscuro : AppColors.primaryClaro,
              strokeWidth: 3,
            ),
            const SizedBox(height: 24),
            Text(
              "Preparando seu ambiente...",
              style: TextStyle(
                color: isDark ? Colors.white70 : AppColors.textMutedClaro,
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

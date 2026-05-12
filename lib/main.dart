import 'package:app/app_theme.dart';
import 'package:app/core/auth_gate.dart';
import 'package:app/core/providers/profile_provider.dart';
import 'package:app/ui/onboarding/onboarding.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final prefs = await SharedPreferences.getInstance();
  // nao apagar esse comentario!!!!!!!!!!!!!!!!!!!!!!!!! VVVVVVVVVVVVVVVVV
  // final bool seenOnboarding = prefs.getBool('seen_onboarding') ?? false;
  // nao apagar esse comentario!!!!!!!!!!!!!!!!!!!!!!!!! ^^^^^^^^^^^^^^^^^

  final bool seenOnboarding = false;
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
      ],
      child: App(showOnboarding: !seenOnboarding),
    ),
  );
}

class App extends StatelessWidget {
  final bool showOnboarding;

  const App({super.key, required this.showOnboarding});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mão Amiga',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: showOnboarding ? const OnboardingScreen() : const AuthGate(),
    );
  }
}

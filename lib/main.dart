import 'package:app/core/providers/focus_provider.dart';
import 'package:app/core/auth_gate.dart';
import 'package:app/core/providers/navigation_provider.dart';
import 'package:app/core/providers/theme_provider.dart';
import 'package:app/ui/onboarding/onboarding_page.dart';
import 'package:app/ui/qr/qr_page.dart';
import 'package:app/ui/home/home_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // await FirebaseAuth.instance.signOut();
  // await AuthService().logout();
  final prefs = await SharedPreferences.getInstance();
  final bool seenOnboarding = prefs.getBool('seen_onboarding') ?? false;
  // final bool seenOnboarding = false;


  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(create: (_) => FocusProvider()),
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
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'NeuroGuia',
          debugShowCheckedModeBanner: false,
          theme: themeProvider.currentTheme,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('pt', 'BR'),
          ],
          home: showOnboarding ? const OnboardingScreen() : const AuthGate(),
          routes: {
            '/home': (context) => const HomePage(),
            '/qr': (context) => const QrPage(),
          },
        );
      },
    );
  }
}

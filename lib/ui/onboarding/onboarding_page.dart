import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/auth_gate.dart';
import './models/onboarding_data.dart';
import './widgets/fixed_onboarding_title.dart';
import './widgets/onboarding_navigation.dart';
import './widgets/onboarding_page_content.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _currentPage = 0;

  final List<OnboardingData> _pagesData = const [
    OnboardingData(
      title: "Bem-vindo",
      description: "Um espaço pensado para o seu ritmo. Simples, calmo e acolhedor.",
      icon: Icons.auto_awesome,
    ),
    OnboardingData(
      title: "Foco e Organização",
      description: "Ferramentas para ajudar no dia a dia, com baixo estímulo visual.",
      icon: Icons.event_note,
    ),
    OnboardingData(
      title: "Apoio Constante",
      description: "Para você e quem cuida de você. Vamos descobrir juntos?",
      icon: Icons.check_circle_outline,
    ),
  ];

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seen_onboarding', true);

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AuthGate()),
      );
    }
  }

  void _nextPage() {
    if (_currentPage < _pagesData.length - 1) {
      setState(() => _currentPage++);
    } else {
      _completeOnboarding();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      setState(() => _currentPage--);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: GestureDetector(
            onHorizontalDragEnd: (details) {
              if (details.primaryVelocity! < 0) {
                _nextPage();
              } else if (details.primaryVelocity! > 0) {
                _previousPage();
              }
            },
            child: Stack(
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 600),
                  child: OnboardingPageContent(
                    key: ValueKey<int>(_currentPage),
                    data: _pagesData[_currentPage],
                  ),
                ),
                const FixedOnboardingTitle(title: 'NeuroGuia'),
                OnboardingNavigation(
                  itemCount: _pagesData.length,
                  currentIndex: _currentPage,
                  onNext: _nextPage,
                  nextButtonLabel: _currentPage == _pagesData.length - 1 
                      ? "Começar" 
                      : "Próximo",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

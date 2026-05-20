import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app_theme.dart';
import '../../core/auth_gate.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _currentPage = 0;

  final List<Map<String, dynamic>> _pagesData = [
    {
      "title": "Bem-vindo",
      "description": "Um espaço pensado para o seu ritmo. Simples, calmo e acolhedor.",
      "icon": Icons.auto_awesome,
    },
    {
      "title": "Foco e Organização",
      "description": "Ferramentas para ajudar no dia a dia, com baixo estímulo visual.",
      "icon": Icons.event_note,
    },
    {
      "title": "Apoio Constante",
      "description": "Para você e quem cuida de você. Vamos descobrir juntos?",
      "icon": Icons.check_circle_outline,
    },
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
    final theme = Theme.of(context);

    return Scaffold(
      body: GestureDetector(
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
              child: OnboardingPage(
                key: ValueKey<int>(_currentPage),
                title: _pagesData[_currentPage]["title"],
                description: _pagesData[_currentPage]["description"],
                icon: _pagesData[_currentPage]["icon"],
              ),
            ),
            // Título fixo no topo
            SafeArea(
              child: IgnorePointer(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(top: AppSizes.radiusLG * 2),
                    child: Text(
                      'Mão Amiga',
                      style: theme.textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: AppSizes.radiusLG * 2.5,
              left: AppSizes.radiusLG,
              right: AppSizes.radiusLG,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pagesData.length,
                      (index) => _buildIndicator(index, theme),
                    ),
                  ),
                  const SizedBox(height: AppSizes.radiusLG * 2),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      key: ValueKey('onboarding_btn_$_currentPage'),
                      onPressed: _nextPage,
                      child: Text(
                        _currentPage == _pagesData.length - 1
                            ? "Começar"
                            : "Próximo",
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIndicator(int index, ThemeData theme) {
    final isSelected = _currentPage == index;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: isSelected ? 24 : 8,
      decoration: BoxDecoration(
        color: isSelected
            ? theme.colorScheme.primary
            : theme.dividerColor.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
      ),
    );
  }
}

class OnboardingPage extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;

  const OnboardingPage({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final bgColor = theme.scaffoldBackgroundColor;
    return Container(
      color: bgColor,
      padding: const EdgeInsets.all(AppSizes.radiusLG * 1.5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 80), // Espaço para não sobrepor o título fixo
          Icon(icon, size: 100, color: primaryColor),
          const SizedBox(height: AppSizes.radiusLG * 2),
          Text(
            title,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSizes.radiusLG),
          Text(
            description,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 120), // Espaço para os indicadores e botões inferiores
        ],
      ),
    );
  }
}

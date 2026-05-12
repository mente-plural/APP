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
  final PageController _controller = PageController();
  int _currentPage = 0;

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seen_onboarding', true);

    if (mounted) {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const AuthGate()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _controller,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            children: const [
              OnboardingPage(
                title: "Bem-vindo",
                description:
                    "Um espaço pensado para o seu ritmo. Simples, calmo e acolhedor.",
                icon: Icons.auto_awesome,
              ),
              OnboardingPage(
                title: "Foco e Organização",
                description:
                    "Ferramentas para ajudar no dia a dia, com baixo estímulo visual.",
                icon: Icons.event_note,
              ),
              OnboardingPage(
                title: "Apoio Constante",
                description:
                    "Para você e quem cuida de você. Vamos descobrir juntos?",
                icon: Icons.check_circle_outline,
              ),
            ],
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
                    3,
                    (index) => _buildIndicator(index, theme),
                  ),
                ),
                const SizedBox(height: AppSizes.radiusLG * 2),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    key: ValueKey('onboarding_btn_$_currentPage'),
                    onPressed: () {
                      if (_currentPage < 2) {
                        _controller.nextPage(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeOutCubic,
                        );
                      } else {
                        _completeOnboarding();
                      }
                    },
                    child: Text(_currentPage == 2 ? "Começar" : "Próximo"),
                  ),
                ),
              ],
            ),
          ),
        ],
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
            : theme.dividerColor.withOpacity(0.3),
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
          Icon(icon, size: 100, color: primaryColor),
          const SizedBox(height: AppSizes.radiusLG * 1.5),
          Text(
            title,
            style: theme.textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSizes.radiusLG),
          Text(
            description,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(1),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

import 'package:app/ui/login/login.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app_theme.dart';
import '../../shared/widgets/primary_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {

  final PageController _pageController = PageController();
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

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pagesData.length - 1) {
      _pageController.nextPage(duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutQuart,);
    } else {
      _completeOnboarding();
    }
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seen_onboarding', true);
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(body: Stack(children: [
      PageView.builder(controller: _pageController, onPageChanged: (int page) {
        setState(() => _currentPage = page);
      }, itemCount: _pagesData.length,

        itemBuilder: (context, index) {
          return OnboardingPage(title: _pagesData[index]["title"],
            description: _pagesData[index]["description"],
            icon: _pagesData[index]["icon"],);
        },),


      Positioned(bottom: AppSizes.radiusLG * 2.5,
        left: AppSizes.radiusLG,
        right: AppSizes.radiusLG,
        child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _pagesData.length, (index) => _buildIndicator(index, theme),),),
          const SizedBox(height: AppSizes.radiusLG * 2),
          SizedBox(width: double.infinity,
            child: PrimaryButton(
              onPressed: _nextPage,
              label: _currentPage == _pagesData.length - 1
                  ? "Começar"
                  : "Próximo",
            ),
          ),
        ],),),
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
        color: isSelected ? theme.colorScheme.primary : theme.dividerColor
            .withOpacity(0.3),
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
    return Padding(padding: const EdgeInsets.all(AppSizes.radiusLG * 2),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 120, color: theme.colorScheme.primary),
          const SizedBox(height: 40),
          Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            description,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(fontSize: 18),
          ),
        ],
      ),
    );
  }
}
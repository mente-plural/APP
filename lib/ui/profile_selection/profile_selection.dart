import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app_theme.dart';
import '../../core/providers/profile_provider.dart';
import '../home/home_page.dart';

class ProfileSelectionPage extends StatelessWidget {
  const ProfileSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgEscuro,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 448),
            padding: const EdgeInsets.all(24.0),
            // Deslocamento de -64px para cima conforme solicitado
            transform: Matrix4.translationValues(0, -64, 0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const _Header(),
                const SizedBox(height: 32),
                _ProfileCard(
                  title: "Para Mim",
                  description: "Ferramentas de foco e rotina",
                  icon: Icons.account_circle,
                  profile: UserProfile.paraMim,
                  delay: 0,
                ),
                const SizedBox(height: 20),
                _ProfileCard(
                  title: "Sou Tutor ou Familiar",
                  description: "Dicas e acompanhamento",
                  icon: Icons.volunteer_activism,
                  profile: UserProfile.tutorFamiliar,
                  delay: 100,
                ),
                const SizedBox(height: 20),
                _ProfileCard(
                  title: "Aprender Mais",
                  description: "Informações sobre neurodiversidade",
                  icon: Icons.groups,
                  profile: UserProfile.aprenderMais,
                  delay: 200,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "Como você quer usar?",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 30,
            color: AppColors.textAccentEscuro,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          "Escolha o perfil que melhor descreve você para personalizarmos a sua experiência.",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            color: AppColors.textSecundarioEscuro,
          ),
        ),
      ],
    );
  }
}

class _ProfileCard extends StatefulWidget {
  final String title;
  final String description;
  final IconData icon;
  final UserProfile profile;
  final int delay;

  const _ProfileCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.profile,
    required this.delay,
  });

  @override
  State<_ProfileCard> createState() => _ProfileCardState();
}

class _ProfileCardState extends State<_ProfileCard> with SingleTickerProviderStateMixin {
  late AnimationController _entranceController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isHovered = false;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOut),
    );

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _entranceController.forward();
    });
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const teal400 = Color(0xFF5EEAD4);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTapDown: (_) => setState(() => _isPressed = true),
            onTapUp: (_) {
              setState(() => _isPressed = false);
              _handleSelect(context);
            },
            onTapCancel: () => setState(() => _isPressed = false),
            child: AnimatedScale(
              scale: _isPressed ? 0.98 : 1.0,
              duration: const Duration(milliseconds: 100),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surfaceEscuro,
                  borderRadius: BorderRadius.circular(AppSizes.radiusLG),
                  border: Border.all(
                    color: _isHovered ? teal400 : AppColors.borderEscuro,
                    width: 2,
                  ),
                  boxShadow: _isHovered
                      ? [
                          BoxShadow(
                            color: teal400.withOpacity(0.1),
                            blurRadius: 10,
                            spreadRadius: 2,
                          )
                        ]
                      : [],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF14B8A6).withOpacity(0.4),
                      ),
                      child: Center(
                        child: Icon(
                          widget.icon,
                          size: 32,
                          color: teal400,
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: TextStyle(
                              fontSize: 20,
                              color: AppColors.textAccentEscuro,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.description,
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.textSecundarioEscuro,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleSelect(BuildContext context) {
    final provider = Provider.of<ProfileProvider>(context, listen: false);
    provider.setProfile(widget.profile);
    
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomePage()),
      (route) => false,
    );
  }
}

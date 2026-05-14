import 'package:flutter/material.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});


  final Color bgColor = const Color(0xFF030712);
  final Color cardColor = const Color(0xFF111827);
  final Color tealAccent = const Color(0xFF00D4C8);
  final Color indigoAccent = const Color(0xFF818CF8);
  final Color textSecondary = const Color(0xFF94A3B8);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Padding(
              padding: EdgeInsets.fromLTRB(24, 40, 24, 24),
              child: Text(
                "Ajuda & Educação",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),


            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildEducationCard(
                    icon: Icons.menu_book_outlined,
                    iconColor: tealAccent,
                    title: "Guia da Condição",
                    description: "Informações detalhadas sobre neurodivergências, mitos e verdades.",
                  ),
                  const SizedBox(height: 16),
                  _buildEducationCard(
                    icon: Icons.shield_outlined,
                    iconColor: indigoAccent,
                    title: "Apoio para Tutores",
                    description: "Estratégias de manejo, comunicação assertiva e redução de danos.",
                  ),
                  const SizedBox(height: 16),
                  _buildEducationCard(
                    icon: Icons.access_time_rounded,
                    iconColor: tealAccent,
                    title: "Gestão de Tempo",
                    description: "Como utilizar as ferramentas do app para melhorar sua organização.",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEducationCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF1F2937),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Icon(
            icon,
            color: iconColor,
            size: 32,
          ),
          const SizedBox(width: 20),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 16,
                    color: textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
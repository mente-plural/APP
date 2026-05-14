import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});


  final Color bgColor = const Color(0xFF030712); // Fundo bem escuro
  final Color cardColor = const Color(0xFF111827); // Fundo dos cards
  final Color tealAccent = const Color(0xFF0D9488); // Verde/Teal
  final Color textSecondary = const Color(0xFF94A3B8); // Cinza claro

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 32),
              _buildMomentoFocoCard(),
              const SizedBox(height: 32),
              _buildProximoRotinaSection(),
              const SizedBox(height: 32),
              _buildDicaTdahSection(),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Olá, André",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Row(
          children: [
            _buildIconButton(Icons.qr_code_scanner),
            const SizedBox(width: 12),
            _buildIconButton(Icons.notifications_none),
          ],
        )
      ],
    );
  }

  Widget _buildIconButton(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: cardColor,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.white, size: 20),
    );
  }


  Widget _buildMomentoFocoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: tealAccent,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Momento de Foco",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            "Vamos iniciar uma sessão\nde Pomodoro?",
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {

            },
            icon: const Icon(Icons.play_arrow, color: Colors.white),
            label: const Text(
              "Iniciar",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: bgColor, // Botão escuro
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildProximoRotinaSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Próximo na Rotina",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              "Ver tudo",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: tealAccent,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(

            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(color: tealAccent, width: 4),
              ),
            ),
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    "10:00",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Pausa Consciente",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "15 min de alongamento",
                      style: TextStyle(
                        color: textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }


  Widget _buildDicaTdahSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Dica para TDAH",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline,
                color: tealAccent,
                size: 24,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  "Divida grandes tarefas em passos menores. Isso ajuda a reduzir a ansiedade e dá uma sensação de progresso constante.",
                  style: TextStyle(
                    color: textSecondary,
                    fontSize: 14,
                    height: 1.5, 
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
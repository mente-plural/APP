import 'package:flutter/material.dart';

const Color bgColor = Color(0xFF020617);
const Color cardBgColor = Color(0xFF0B1426);
const Color cyanAccent = Color(0xFF00D4C8);
const Color darkCyan = Color(0xFF003D39);
const Color buttonDark = Color(0xFF132236);
const Color textMuted = Color(0xFF64748B);
const Color textMutedLight = Color(0xFF94A3B8);

class TempoFocoPage extends StatelessWidget {
  const TempoFocoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      bottomNavigationBar: const BottomNav(),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildHeader(),
              const SizedBox(height: 32),
              _buildTopBadge(),
              const SizedBox(height: 16),
              const Text(
                "Concentre-se em uma única tarefa por vez.",
                style: TextStyle(color: textMutedLight, fontSize: 15),
              ),
              const SizedBox(height: 24),
              const FocusCard(),
              const SizedBox(height: 40),
              const TimerSection(),
              const SizedBox(height: 40),
              _buildActionButtons(),
              const SizedBox(height: 24),
              _buildCurrentFocusCard(),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: const BoxDecoration(
            color: buttonDark,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 16),
        const Text(
          "Tempo de Foco",
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }


  Widget _buildTopBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: buttonDark, width: 1.5),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.menu_book_outlined, color: cyanAccent, size: 18),
          SizedBox(width: 8),
          Text(
            "Sessão de Foco",
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildActionButtons() {
    return Column(
      children: [

        Container(
          width: double.infinity,
          height: 60,
          decoration: BoxDecoration(
            color: buttonDark,
            borderRadius: BorderRadius.circular(30),
          ),
          child: const Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.all(Radius.circular(30)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.refresh, color: textMutedLight, size: 24),
                  SizedBox(width: 12),
                  Text(
                    "Recomeçar Tempo",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        Container(
          width: double.infinity,
          height: 60,
          decoration: BoxDecoration(
            color: cyanAccent,
            borderRadius: BorderRadius.circular(30),
          ),
          child: const Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.all(Radius.circular(30)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.play_arrow, color: bgColor, size: 28),
                  SizedBox(width: 8),
                  Text(
                    "Iniciar",
                    style: TextStyle(
                      color: bgColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }


  Widget _buildCurrentFocusCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: buttonDark, width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: buttonDark,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.menu_book_outlined, color: cyanAccent, size: 24),
          ),
          const SizedBox(width: 16),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "FOCO ATUAL",
                style: TextStyle(
                  color: textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
              SizedBox(height: 4),
              Text(
                "Estudo e Leitura",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


class FocusCard extends StatelessWidget {
  const FocusCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: buttonDark, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            "CICLO POMODORO",
            style: TextStyle(
              color: textMutedLight,
              fontSize: 13,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              StepPomodoro(number: "1", label: "Foco", time: "25 min", isActive: true),
              StepPomodoro(number: "2", label: "Pausa\nCurta", time: "5 min", isActive: false),
              StepPomodoro(number: "3", label: "Foco", time: "25 min", isActive: false),
              StepPomodoro(number: "4", label: "Pausa\nCurta", time: "5 min", isActive: false),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Repita 4 vezes",
                style: TextStyle(color: textMuted, fontSize: 13, fontStyle: FontStyle.italic),
              ),
              const SizedBox(width: 8),
              _buildDot(isActive: true),
              _buildDot(isActive: false),
              _buildDot(isActive: false),
              _buildDot(isActive: false),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(color: buttonDark, thickness: 1, height: 1),
          const SizedBox(height: 24),
          const Text(
            "PAUSA LONGA",
            style: TextStyle(
              color: textMutedLight,
              fontSize: 13,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Após 4 ciclos, faça uma pausa longa.",
            style: TextStyle(color: textMuted, fontSize: 14),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            decoration: BoxDecoration(
              color: darkCyan,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              "15–30 min",
              style: TextStyle(
                color: cyanAccent,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot({required bool isActive}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 3),
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        color: isActive ? textMutedLight : buttonDark,
        shape: BoxShape.circle,
      ),
    );
  }
}


class StepPomodoro extends StatelessWidget {
  final String number;
  final String label;
  final String time;
  final bool isActive;

  const StepPomodoro({
    super.key,
    required this.number,
    required this.label,
    required this.time,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            color: isActive ? cyanAccent : buttonDark,
            shape: BoxShape.circle,
            boxShadow: isActive
                ? [BoxShadow(color: cyanAccent.withOpacity(0.3), blurRadius: 15, spreadRadius: 2)]
                : null,
          ),
          child: Center(
            child: Text(
              number,
              style: TextStyle(
                color: isActive ? bgColor : textMutedLight,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isActive ? cyanAccent : textMutedLight,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          time,
          style: const TextStyle(
            color: textMuted,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}


class TimerSection extends StatelessWidget {
  const TimerSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      height: 320,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: buttonDark, width: 6),
      ),
      child: const Center(
        child: Text(
          "25:00",
          style: TextStyle(
            color: Color(0xFFF1F5F9),
            fontSize: 84,
            fontWeight: FontWeight.bold,
            letterSpacing: -2.0,
          ),
        ),
      ),
    );
  }
}


class BottomNav extends StatelessWidget {
  const BottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: buttonDark, width: 1)),
      ),
      child: BottomNavigationBar(
        backgroundColor: bgColor,
        type: BottomNavigationBarType.fixed,
        currentIndex: 2, // Foco ativo
        selectedItemColor: cyanAccent,
        unselectedItemColor: textMuted,
        showUnselectedLabels: true,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        elevation: 0,
        items: const [
          BottomNavigationBarItem(icon: Padding(padding: EdgeInsets.only(bottom: 6), child: Icon(Icons.home_outlined)), label: 'Início'),
          BottomNavigationBarItem(icon: Padding(padding: EdgeInsets.only(bottom: 6), child: Icon(Icons.calendar_today_outlined)), label: 'Rotina'),
          BottomNavigationBarItem(icon: Padding(padding: EdgeInsets.only(bottom: 6), child: Icon(Icons.timer_outlined)), label: 'Foco'),
          BottomNavigationBarItem(icon: Padding(padding: EdgeInsets.only(bottom: 6), child: Icon(Icons.person_outline)), label: 'Perfil'),
          BottomNavigationBarItem(icon: Padding(padding: EdgeInsets.only(bottom: 6), child: Icon(Icons.help_outline)), label: 'Ajuda'),
        ],
      ),
    );
  }
}
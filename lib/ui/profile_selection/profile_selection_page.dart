import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../app_theme.dart';
import '../../core/auth/auth_service.dart';
import './widgets/selection_card.dart';
import './widgets/profile_selection_header.dart';
import './widgets/profile_selection_footer.dart';

class ProfileSelectionPage extends StatefulWidget {
  const ProfileSelectionPage({super.key});

  @override
  State<ProfileSelectionPage> createState() => _ProfileSelectionPageState();
}

class _ProfileSelectionPageState extends State<ProfileSelectionPage> {
  int currentStep = 1;
  final TextEditingController _nameController = TextEditingController();
  String? selectedRole;
  String? selectedColor;
  final Set<String> selectedNeuro = {};

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> nextStep() async {
    if (currentStep < 4) {
      if (currentStep == 1 && _nameController.text.trim().isEmpty) {
        _showError("Por favor, informe seu nome.");
        return;
      }
      if (currentStep == 2 && selectedRole == null) {
        _showError("Por favor, selecione um perfil.");
        return;
      }
      if (currentStep == 3 && selectedColor == null) {
        _showError("Por favor, selecione uma preferência de cor.");
        return;
      }
      setState(() => currentStep++);
    } else {
      if (selectedNeuro.isEmpty) {
        _showError("Por favor, selecione ao menos uma opção.");
        return;
      }

      debugPrint("Finalizando Onboarding. Enviando Perfil: $selectedRole, Cor: $selectedColor");

      try {
        await AuthService().updateUserProfile(
          name: _nameController.text.trim(),
          profileType: selectedRole,
          preferredColor: selectedColor,
          neurodivergencies: selectedNeuro.toList(),
        );

        if (mounted) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('seen_onboarding', true);
        }
      } catch (e) {
        if (mounted) {
          _showError("Erro ao salvar perfil: $e");
        }
      }
    }
  }

  void previousStep() {
    if (currentStep > 1) {
      setState(() => currentStep--);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgEscuro,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProfileSelectionHeader(
                currentStep: currentStep,
                title: _getHeaderTitle(),
              ),
              const SizedBox(height: 40),
              Expanded(
                child: SingleChildScrollView(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _buildCurrentStepContent(),
                  ),
                ),
              ),
              ProfileSelectionFooter(
                currentStep: currentStep,
                onNext: nextStep,
                onPrevious: previousStep,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getHeaderTitle() {
    switch (currentStep) {
      case 1: return "Como podemos te chamar?";
      case 2: return "Quem é você?";
      case 3: return "Como você prefere as cores?";
      case 4: return "Sua identificação";
      default: return "";
    }
  }

  Widget _buildCurrentStepContent() {
    switch (currentStep) {
      case 1: return _stepName();
      case 2: return _stepRole();
      case 3: return _stepColor();
      case 4: return _stepNeuro();
      default: return const SizedBox.shrink();
    }
  }

  Widget _stepName() {
    return Column(
      key: const ValueKey(1),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Qual o seu nome ou apelido?",
          style: TextStyle(color: AppColors.textSecundarioEscuro, fontSize: 16),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _nameController,
          style: const TextStyle(color: Colors.white, fontSize: 18),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.surfaceEscuro,
            hintText: "Digite seu nome",
            hintStyle: const TextStyle(color: AppColors.textSecundarioEscuro),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.primaryEscuro, width: 2),
            ),
            contentPadding: const EdgeInsets.all(20),
          ),
        ),
      ],
    );
  }

  Widget _stepRole() {
    final options = [
      {'label': 'Paciente', 'value': 'FOR_ME'},
      {'label': 'Tutor', 'value': 'TUTOR'},
      {'label': 'Usuário geral', 'value': 'LEARN_MORE'},
    ];

    return Column(
      key: const ValueKey(2),
      children: options.map((opt) {
        final String value = opt['value'] as String;
        final bool isPaciente = value == 'FOR_ME';

        return SelectionCard(
          title: opt['label'] as String,
          isSelected: selectedRole == value,
          isDevelopment: !isPaciente,
          onTap: () {
            if (isPaciente) {
              setState(() => selectedRole = value);
            }
          },
        );
      }).toList(),
    );
  }

  Widget _stepColor() {
    final options = [
      'Tema Claro',
      'Tema Escuro',
      'Alto Contraste',
      'Cores Suaves/Tons Pastéis'
    ];

    return Column(
      key: const ValueKey(3),
      children: options.map((opt) {
        final bool isTemaPronto =
            opt == 'Tema Claro' || opt == 'Tema Escuro' || opt == 'Alto Contraste';

        return SelectionCard(
          title: opt,
          isSelected: selectedColor == opt,
          isDevelopment: !isTemaPronto,
          onTap: () {
            if (isTemaPronto) {
              setState(() => selectedColor = opt);
            }
          },
        );
      }).toList(),
    );
  }

  Widget _stepNeuro() {
    final options = [
      'Autismo (TEA)',
      'TDAH',
      'Dislexia',
      'Discalculia',
      'Dispraxia',
      'Outro',
      'Prefiro não dizer'
    ];
    return Column(
      key: const ValueKey(4),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Você se identifica com qual(is) destas neurodivergências? (Pode marcar mais de uma)",
          style: TextStyle(color: AppColors.textSecundarioEscuro, fontSize: 16),
        ),
        const SizedBox(height: 20),
        ...options.map((opt) => SelectionCard(
              title: opt,
              isSelected: selectedNeuro.contains(opt),
              onTap: () {
                setState(() {
                  if (selectedNeuro.contains(opt)) {
                    selectedNeuro.remove(opt);
                  } else {
                    selectedNeuro.add(opt);
                  }
                });
              },
              isMulti: true,
            )),
      ],
    );
  }
}

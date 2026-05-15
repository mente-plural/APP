import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../app_theme.dart';
import '../../core/auth_service.dart';
import '../../shared/widgets/primary_button.dart';
import '../../shared/widgets/secondary_button.dart';

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
  bool _isLoading = false;

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

      setState(() => _isLoading = true);
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
          // A navegação agora é feita automaticamente pelo AuthGate
          // pois o ProfileProvider irá reagir à mudança do usuário.
        }
      } catch (e) {
        if (mounted) {
          _showError("Erro ao salvar perfil: $e");
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
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
              _buildHeader(),
              const SizedBox(height: 12),
              _buildProgressBar(),
              const SizedBox(height: 40),
              Expanded(
                child: SingleChildScrollView(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _buildCurrentStepContent(),
                  ),
                ),
              ),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    String title = "";
    if (currentStep == 1) title = "Como podemos te chamar?";
    if (currentStep == 2) title = "Quem é você?";
    if (currentStep == 3) title = "Como você prefere as cores?";
    if (currentStep == 4) title = "Sua identificação";

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: AppColors.textAccentEscuro,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Text(
          "$currentStep de 4",
          style: const TextStyle(
            color: AppColors.primaryEscuro,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar() {
    return Container(
      height: 6,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surfaceEscuro,
        borderRadius: BorderRadius.circular(10),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: currentStep / 4,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.primaryEscuro,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentStepContent() {
    if (currentStep == 1) return _stepName();
    if (currentStep == 2) return _stepRole();
    if (currentStep == 3) return _stepColor();
    return _stepNeuro();
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
      children: options
          .map((opt) => _selectionCard(
                title: opt['label'] as String,
                isSelected: selectedRole == opt['value'],
                onTap: () => setState(() => selectedRole = opt['value'] as String),
              ))
          .toList(),
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
      children: options
          .map((opt) => _selectionCard(
                title: opt,
                isSelected: selectedColor == opt,
                onTap: () => setState(() => selectedColor = opt),
              ))
          .toList(),
    );
  }

  Widget _stepNeuro() {
    final options = [
      'Autismo (TEA)',
      'TDAH',
      'Dislexia',
      'Discalculia',
      'Dispraxia',
      'Síndrome de Tourette',
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
        ...options.map((opt) => _selectionCard(
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

  Widget _selectionCard({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
    bool isMulti = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryEscuro.withValues(alpha: 0.1)
              : AppColors.surfaceEscuro,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? AppColors.primaryEscuro : AppColors.borderEscuro,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textSecundarioEscuro,
                  fontSize: 18,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                isMulti ? Icons.check_box : Icons.check_circle,
                color: AppColors.primaryEscuro,
              ),
            if (!isSelected && isMulti)
              Icon(
                Icons.check_box_outline_blank,
                color: AppColors.textSecundarioEscuro.withValues(alpha: 0.5),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Row(
      children: [
        if (currentStep > 1)
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: SecondaryButton(
                label: "Voltar",
                onPressed: previousStep,
              ),
            ),
          ),
        Expanded(
          flex: 2,
          child: PrimaryButton(
            label: currentStep < 4 ? "Continuar" : "Finalizar",
            onPressed: nextStep,
          ),
        ),
      ],
    );
  }
}

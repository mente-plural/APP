import 'package:flutter/material.dart';
import '../../app_theme.dart';
import '../../core/auth_service.dart';
import '../../models/user_model.dart';
import '../../shared/widgets/page_header.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();

  late TextEditingController _nameController;
  late TextEditingController _phoneController;

  bool _isSaving = false;
  bool _hasChanges = false;

  // Opções de tipo de perfil
  final List<Map<String, String>> _profileTypes = [
    {'value': 'FOR_ME', 'label': 'Para Mim'},
    {'value': 'TUTOR', 'label': 'Tutor ou Familiar'},
    {'value': 'LEARN_MORE', 'label': 'Aprender Mais'},
  ];

  // Opções de neurodivergências disponíveis
  final List<String> _availableNeurodivergencies = [
    'TDAH',
    'Autismo (TEA)',
    'Dislexia',
    'Discalculia',
    'Dispraxia',
    'Síndrome de Tourette',
    'Altas Habilidades',
    'Outro',
  ];

  String? _selectedProfileType;
  List<String> _selectedNeurodivergencies = [];
  UserModel? _originalUser;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();

    _authService.userStream.first.then((user) {
      if (user != null && mounted) {
        setState(() {
          _originalUser = user;
          _nameController.text = user.name ?? '';
          _phoneController.text = user.phone ?? '';
          _selectedProfileType = user.preferences.profileType;
          _selectedNeurodivergencies =
              List<String>.from(user.preferences.neurodivergencies);
        });
      }
    });

    _nameController.addListener(_onFieldChanged);
    _phoneController.addListener(_onFieldChanged);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _onFieldChanged() {
    if (!_hasChanges) {
      setState(() => _hasChanges = true);
    }
  }

  void _onSelectionChanged() {
    setState(() => _hasChanges = true);
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      // Aqui você chama o método de atualização do AuthService/UserRepository
      // Exemplo:
      // await _authService.updateProfile(
      //   name: _nameController.text.trim(),
      //   phone: _phoneController.text.trim(),
      //   profileType: _selectedProfileType,
      //   neurodivergencies: _selectedNeurodivergencies,
      // );

      // Simula delay de rede
      await Future.delayed(const Duration(milliseconds: 800));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text('Perfil atualizado com sucesso!'),
              ],
            ),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
        Navigator.of(context).pop(true); // retorna true para indicar sucesso
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar: ${e.toString()}'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<bool> _onWillPop() async {
    if (!_hasChanges) return true;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceEscuro,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Descartar alterações?',
            style:
                TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text('As alterações não salvas serão perdidas.',
            style: TextStyle(color: AppColors.textSecundarioEscuro)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Continuar editando',
                style: TextStyle(color: AppColors.textSecundarioEscuro)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Descartar',
                style: TextStyle(
                    color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    return confirm ?? false;
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'O nome não pode estar vazio';
    }
    if (value.trim().length < 2) {
      return 'Nome muito curto';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) return null; // campo opcional
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.isNotEmpty && digits.length < 10) {
      return 'Telefone inválido';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PopScope(
      canPop: !_hasChanges,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop) {
          final should = await _onWillPop();
          if (should && context.mounted) Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24.0, vertical: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(theme),
                        const SizedBox(height: 32),
                        _buildAvatarSection(theme),
                        const SizedBox(height: 24),
                        _buildPersonalInfoCard(theme),
                        const SizedBox(height: 16),
                        _buildProfileTypeCard(theme),
                        const SizedBox(height: 16),
                        _buildNeurodivergenciesCard(theme),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
                _buildBottomBar(theme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return PageHeader(
      title: "Editar Perfil",
      actions: [
        HeaderActionIcon(
          icon: Icons.close,
          tooltip: 'Cancelar',
          onTap: () async {
            final should = await _onWillPop();
            if (should && mounted) Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  Widget _buildAvatarSection(ThemeData theme) {
    final initials = _originalUser != null
        ? (_nameController.text.isNotEmpty
            ? _nameController.text[0].toUpperCase()
            : _originalUser!.email.isNotEmpty
                ? _originalUser!.email[0].toUpperCase()
                : '?')
        : '?';

    return Center(
      child: Stack(
        children: [
          if (_originalUser?.photoUrl != null &&
              _originalUser!.photoUrl!.isNotEmpty)
            CircleAvatar(
              radius: 44,
              backgroundImage: NetworkImage(_originalUser!.photoUrl!),
            )
          else
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  initials,
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
              ),
            ),
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: () {
                // TODO: implementar picker de foto
              },
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: theme.scaffoldBackgroundColor, width: 2),
                ),
                child: Icon(Icons.camera_alt,
                    size: 15, color: theme.colorScheme.onPrimary),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoCard(ThemeData theme) {
    return _buildCard(
      theme,
      title: 'Informações Pessoais',
      child: Column(
        children: [
          _buildFieldLabel(theme, 'Nome completo'),
          const SizedBox(height: 6),
          _buildTextField(
            theme,
            controller: _nameController,
            hint: 'Seu nome',
            icon: Icons.person_outline,
            validator: _validateName,
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 16),
          _buildFieldLabel(theme, 'Email'),
          const SizedBox(height: 6),
          _buildTextField(
            theme,
            initialValue: _originalUser?.email ?? '',
            hint: 'seu@email.com',
            icon: Icons.email_outlined,
            enabled: false, // email não editável
          ),
          const SizedBox(height: 16),
          _buildFieldLabel(theme, 'Telefone'),
          const SizedBox(height: 6),
          _buildTextField(
            theme,
            controller: _phoneController,
            hint: '(00) 00000-0000',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            validator: _validatePhone,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileTypeCard(ThemeData theme) {
    return _buildCard(
      theme,
      title: 'Tipo de Perfil',
      child: Column(
        children: _profileTypes.map((type) {
          final isSelected = _selectedProfileType == type['value'];
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedProfileType = type['value'];
                _hasChanges = true;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(bottom: 8),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colorScheme.primary.withOpacity(0.10)
                    : theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected
                      ? theme.colorScheme.primary.withOpacity(0.50)
                      : theme.dividerColor,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isSelected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    size: 20,
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.textTheme.bodyMedium?.color,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    type['label']!,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildNeurodivergenciesCard(ThemeData theme) {
    return _buildCard(
      theme,
      title: 'Condições / Neurodivergências',
      subtitle: 'Selecione todas que se aplicam',
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _availableNeurodivergencies.map((item) {
          final isSelected = _selectedNeurodivergencies.contains(item);
          return GestureDetector(
            onTap: () {
              setState(() {
                if (isSelected) {
                  _selectedNeurodivergencies.remove(item);
                } else {
                  _selectedNeurodivergencies.add(item);
                }
                _hasChanges = true;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colorScheme.primary.withOpacity(0.12)
                    : theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? theme.colorScheme.primary.withOpacity(0.50)
                      : theme.dividerColor,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isSelected) ...[
                    Icon(Icons.check,
                        size: 13, color: theme.colorScheme.primary),
                    const SizedBox(width: 4),
                  ],
                  Text(
                    item,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBottomBar(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(top: BorderSide(color: theme.dividerColor)),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: _isSaving ? null : _saveProfile,
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            disabledBackgroundColor:
                theme.colorScheme.primary.withOpacity(0.5),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            elevation: 0,
          ),
          child: _isSaving
              ? SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: theme.colorScheme.onPrimary,
                  ),
                )
              : const Text(
                  'Salvar Alterações',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
        ),
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  Widget _buildCard(ThemeData theme,
      {required String title, String? subtitle, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: theme.textTheme.bodyMedium?.color,
              ),
            ),
          ],
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildFieldLabel(ThemeData theme, String label) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: theme.textTheme.bodyMedium?.color,
        ),
      ),
    );
  }

  Widget _buildTextField(
    ThemeData theme, {
    TextEditingController? controller,
    String? initialValue,
    required String hint,
    required IconData icon,
    bool enabled = true,
    TextInputType keyboardType = TextInputType.text,
    TextCapitalization textCapitalization = TextCapitalization.none,
    String? Function(String?)? validator,
  }) {
    final inputDecoration = InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
          color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
          fontSize: 14),
      prefixIcon: Padding(
        padding: const EdgeInsets.only(left: 14, right: 8),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: enabled
                ? theme.colorScheme.primary.withOpacity(0.10)
                : theme.dividerColor.withOpacity(0.3),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon,
              size: 17,
              color: enabled
                  ? theme.colorScheme.primary
                  : theme.textTheme.bodyMedium?.color),
        ),
      ),
      prefixIconConstraints:
          const BoxConstraints(minWidth: 0, minHeight: 0),
      filled: true,
      fillColor: enabled
          ? theme.colorScheme.surface
          : theme.dividerColor.withOpacity(0.15),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: theme.dividerColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: theme.dividerColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
            color: theme.colorScheme.primary.withOpacity(0.6), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide:
            const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide:
            const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: theme.dividerColor.withOpacity(0.5)),
      ),
    );

    if (controller != null) {
      return TextFormField(
        controller: controller,
        enabled: enabled,
        keyboardType: keyboardType,
        textCapitalization: textCapitalization,
        validator: validator,
        style: TextStyle(
            fontSize: 14,
            color: enabled
                ? theme.colorScheme.onSurface
                : theme.textTheme.bodyMedium?.color),
        decoration: inputDecoration,
      );
    }

    return TextFormField(
      initialValue: initialValue,
      enabled: enabled,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      validator: validator,
      style: TextStyle(
          fontSize: 14,
          color: enabled
              ? theme.colorScheme.onSurface
              : theme.textTheme.bodyMedium?.color),
      decoration: inputDecoration,
    );
  }
}

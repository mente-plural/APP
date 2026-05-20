import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../app_theme.dart';
import '../../core/auth/auth_service.dart';
import '../../models/user_model.dart';
import '../../shared/utils/ui_utils.dart';
import '../../shared/widgets/page_header.dart';
import '../../shared/widgets/custom_text_field.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with SingleTickerProviderStateMixin {
  final _authService = AuthService();
  bool _isEditing = false;
  bool _isSaving = false;
  bool _isUploading = false;

  final List<String> _availableColors = [
    'Verde',
    'Azul',
    'Roxo',
    'Laranja',
    'Padrão',
  ];

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  String? _selectedProfileType;
  String? _selectedColor;
  List<String> _selectedNeurodivergencies = [];
  bool _highContrast = false;
  double _fontSizeMultiplier = 1.0;

  final List<Map<String, String>> _profileTypes = [
    {'value': 'FOR_ME', 'label': 'Para Mim'},
    {'value': 'TUTOR', 'label': 'Tutor ou Familiar'},
    {'value': 'LEARN_MORE', 'label': 'Aprender Mais'},
  ];

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

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _startEditing(UserModel user) {
    setState(() {
      _isEditing = true;
      _nameController.text = user.name ?? '';
      _phoneController.text = user.phone ?? '';
      _selectedProfileType = user.preferences.profileType;
      _selectedColor = user.preferences.preferredColor;
      _selectedNeurodivergencies = List<String>.from(user.preferences.neurodivergencies);
      _highContrast = user.preferences.highContrast;
      _fontSizeMultiplier = user.preferences.fontSizeMultiplier;
    });
  }

  void _cancelEditing() {
    setState(() => _isEditing = false);
  }

  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);
    try {
      await _authService.updateUserProfile(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        profileType: _selectedProfileType,
        preferredColor: _selectedColor,
        neurodivergencies: _selectedNeurodivergencies,
        highContrast: _highContrast,
        fontSizeMultiplier: _fontSizeMultiplier,
      );
      
      if (mounted) {
        UiUtils.showSnackBar(context, 'Perfil atualizado com sucesso!');
        setState(() => _isEditing = false);
      }
    } catch (e) {
      if (mounted) {
        UiUtils.showSnackBar(context, 'Erro ao salvar: $e', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final XFile? image = await showModalBottomSheet<XFile?>(
      context: context,
      backgroundColor: AppColors.surfaceEscuro,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.white),
              title: const Text('Tirar Foto', style: TextStyle(color: Colors.white)),
              onTap: () async => Navigator.pop(context, await picker.pickImage(source: ImageSource.camera, imageQuality: 70)),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.white),
              title: const Text('Galeria', style: TextStyle(color: Colors.white)),
              onTap: () async => Navigator.pop(context, await picker.pickImage(source: ImageSource.gallery, imageQuality: 70)),
            ),
          ],
        ),
      ),
    );

    if (image != null) {
      setState(() => _isUploading = true);
      try {
        await _authService.uploadProfilePhoto(image.path);
        if (mounted) UiUtils.showSnackBar(context, 'Foto de perfil atualizada!');
      } catch (e) {
        if (mounted) UiUtils.showSnackBar(context, 'Erro ao enviar foto: $e', isError: true);
      } finally {
        if (mounted) setState(() => _isUploading = false);
      }
    }
  }


  Future<void> _confirmLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceEscuro,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Sair da conta?',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text('Você precisará fazer login novamente.',
            style: TextStyle(color: AppColors.textSecundarioEscuro)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar',
                style: TextStyle(color: AppColors.textSecundarioEscuro)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sair',
                style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await _authService.logout();
      // A navegação de volta para a LoginPage será tratada automaticamente pelo AuthGate
      // ao detectar que o fluxo de usuário no AuthService tornou-se null.
    }
  }

  String _getProfileLabel(String? type) {
    switch (type) {
      case 'FOR_ME':
        return 'Para Mim';
      case 'TUTOR':
        return 'Tutor ou Familiar';
      case 'LEARN_MORE':
        return 'Aprender Mais';
      default:
        return 'Perfil do Usuário';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: StreamBuilder<UserModel?>(
          stream: _authService.userStream,
          builder: (context, snapshot) {
            final user = snapshot.data;

            if (user == null) {
              return Center(
                child: CircularProgressIndicator(color: theme.colorScheme.primary),
              );
            }

            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(theme, user),
                        const SizedBox(height: 32),
                        if (!_isEditing) ...[
                          _buildMainCard(user, theme),
                          const SizedBox(height: 24),
                          _buildLogoutButton(theme),
                        ] else ...[
                          _buildEditForm(user, theme),
                        ],
                      ],
                    ),
                  ),
                ),
                if (_isEditing) _buildEditActions(theme),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, UserModel user) {
    return PageHeader(
      title: _isEditing ? "Editar Perfil" : "Meu Perfil",
      actions: _isEditing
          ? [
              HeaderActionIcon(
                icon: Icons.close,
                tooltip: 'Cancelar',
                onTap: _cancelEditing,
              ),
            ]
          : [
              HeaderActionIcon(
                icon: Icons.qr_code_scanner,
                tooltip: 'Meu QR Code',
                iconColor: theme.colorScheme.primary,
                onTap: () => Navigator.pushNamed(context, '/qr'),
              ),
              HeaderActionIcon(
                icon: Icons.edit_outlined,
                tooltip: 'Editar Perfil',
                onTap: () => _startEditing(user),
              ),
            ],
    );
  }

  Widget _buildEditForm(UserModel user, ThemeData theme) {
    return Column(
      children: [
        _buildAvatarEdit(user, theme),
        const SizedBox(height: 24),
        _buildPersonalInfoEdit(user, theme),
        const SizedBox(height: 16),
        _buildProfileTypeEdit(theme),
        const SizedBox(height: 16),
        // _buildColorPreferenceEdit(theme),
        // const SizedBox(height: 16),
        // _buildAccessibilityEdit(theme),
        // const SizedBox(height: 16),
        _buildNeurodivergenciesEdit(theme),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildColorPreferenceEdit(ThemeData theme) {
    return _buildCard(
      theme,
      title: 'Cor Preferida',
      child: Wrap(
        spacing: 12,
        children: _availableColors.map((color) {
          final isSelected = _selectedColor == color || (_selectedColor == null && color == 'Padrão');
          return ChoiceChip(
            label: Text(color),
            selected: isSelected,
            onSelected: (selected) {
              if (selected) setState(() => _selectedColor = color == 'Padrão' ? null : color);
            },
            selectedColor: theme.colorScheme.primary.withOpacity(0.2),
            labelStyle: TextStyle(
              color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAccessibilityEdit(ThemeData theme) {
    return _buildCard(
      theme,
      title: 'Acessibilidade',
      child: Column(
        children: [
          SwitchListTile(
            title: const Text('Alto Contraste'),
            subtitle: const Text('Melhora a visibilidade das cores'),
            value: _highContrast,
            onChanged: (val) => setState(() => _highContrast = val),
            activeColor: theme.colorScheme.primary,
            contentPadding: EdgeInsets.zero,
          ),
          const Divider(),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text('Tamanho da Fonte'),
              const Spacer(),
              Text('${(_fontSizeMultiplier * 100).toInt()}%', style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          Slider(
            value: _fontSizeMultiplier,
            min: 0.8,
            max: 1.5,
            divisions: 7,
            label: '${(_fontSizeMultiplier * 100).toInt()}%',
            onChanged: (val) => setState(() => _fontSizeMultiplier = val),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarEdit(UserModel user, ThemeData theme) {
    final initials = (user.name != null && user.name!.isNotEmpty)
        ? user.name![0].toUpperCase()
        : user.email.isNotEmpty ? user.email[0].toUpperCase() : '?';

    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: theme.colorScheme.primary,
            backgroundImage: (user.photoUrl != null && user.photoUrl!.isNotEmpty)
                ? NetworkImage(user.photoUrl!)
                : null,
            child: (user.photoUrl == null || user.photoUrl!.isEmpty)
                ? Text(
                    initials,
                    style: TextStyle(fontSize: 38, fontWeight: FontWeight.bold, color: theme.colorScheme.onPrimary),
                  )
                : null,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: _isUploading ? null : _pickAndUploadImage,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: theme.scaffoldBackgroundColor, width: 2),
                ),
                child: _isUploading
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.camera_alt, size: 18, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoEdit(UserModel user, ThemeData theme) {
    return _buildCard(
      theme,
      title: 'Informações Pessoais',
      child: Column(
        children: [
          CustomTextField(
            label: 'Nome completo',
            hint: 'Seu nome',
            controller: _nameController,
            icon: Icons.person_outline,
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            label: 'Email',
            hint: 'seu@email.com',
            controller: TextEditingController(text: user.email),
            icon: Icons.email_outlined,
            enabled: false,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            label: 'Telefone',
            hint: '(00) 0 0000-0000',
            controller: _phoneController,
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileTypeEdit(ThemeData theme) {
    return _buildCard(
      theme,
      title: 'Tipo de Perfil',
      child: Column(
        children: _profileTypes.map((type) {
          final isSelected = _selectedProfileType == type['value'];
          final isDevelopment = type['value'] != 'FOR_ME';
          return _buildSelectableTile(
            theme,
            label: type['label']!,
            isSelected: isSelected,
            isDevelopment: isDevelopment,
            onTap: isDevelopment
                ? () {}
                : () {
                    setState(() {
                      _selectedProfileType = type['value'];
                    });
                  },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildNeurodivergenciesEdit(ThemeData theme) {
    return _buildCard(
      theme,
      title: 'Neurodivergências',
      subtitle: 'Selecione as que se aplicam',
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _availableNeurodivergencies.map((item) {
          final isSelected = _selectedNeurodivergencies.contains(item);
          return FilterChip(
            label: Text(
              item,
              style: TextStyle(
                color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface.withOpacity(0.7),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            selected: isSelected,
            onSelected: (val) {
              setState(() {
                val ? _selectedNeurodivergencies.add(item) : _selectedNeurodivergencies.remove(item);
              });
            },
            backgroundColor: theme.colorScheme.surface,
            selectedColor: theme.colorScheme.primary.withOpacity(0.15),
            checkmarkColor: theme.colorScheme.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEditActions(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(top: BorderSide(color: theme.dividerColor)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _isSaving ? null : _cancelEditing,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, 52),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text("Cancelar"),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _isSaving ? null : _saveProfile,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(0, 52),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: _isSaving
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text("Salvar"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(ThemeData theme, {required String title, String? subtitle, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(subtitle, style: theme.textTheme.bodySmall),
          ],
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildSelectableTile(ThemeData theme,
      {required String label, required bool isSelected, required VoidCallback onTap, bool isDevelopment = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: isSelected
                  ? theme.colorScheme.primary
                  : (isDevelopment ? theme.dividerColor.withOpacity(0.3) : theme.dividerColor)),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected
                  ? theme.colorScheme.primary
                  : (isDevelopment ? theme.dividerColor.withOpacity(0.3) : theme.dividerColor),
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: TextStyle(color: isDevelopment ? theme.disabledColor : null),
              ),
            ),
            if (isDevelopment)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "Em breve",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(ThemeData theme) {
    return InkWell(
      onTap: _confirmLogout,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.redAccent.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.redAccent.withOpacity(0.2)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_rounded, color: Colors.redAccent, size: 20),
            SizedBox(width: 8),
            Text(
              "Sair da Conta",
              style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainCard(UserModel user, ThemeData theme) {
    final initials = (user.name != null && user.name!.isNotEmpty)
        ? user.name![0].toUpperCase()
        : user.email.isNotEmpty ? user.email[0].toUpperCase() : '?';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        children: [
          _buildAvatar(user, theme, initials),
          const SizedBox(height: 14),
          Text(
            user.name ?? 'Usuário',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
          ),
          const SizedBox(height: 8),
          _buildBadge(_getProfileLabel(user.preferences.profileType), theme),
          const SizedBox(height: 24),
          Divider(color: theme.dividerColor, height: 1),
          const SizedBox(height: 20),
          _buildInfoRow(theme, Icons.email_outlined, 'Email', user.email),
          const SizedBox(height: 16),
          _buildInfoRow(theme, Icons.phone_outlined, 'Telefone', user.phone ?? 'Não informado'),
          const SizedBox(height: 16),
          _buildInfoRow(theme, Icons.calendar_today_outlined, 'Membro desde', DateFormat('dd/MM/yyyy').format(user.createdAt)),
          if (user.preferences.neurodivergencies.isNotEmpty) ...[
            const SizedBox(height: 20),
            Divider(color: theme.dividerColor, height: 1),
            const SizedBox(height: 16),
            _buildNeurodivergenciesSection(user, theme),
          ],
        ],
      ),
    );
  }

  Widget _buildAvatar(UserModel user, ThemeData theme, String initials) {
    if (user.photoUrl != null && user.photoUrl!.isNotEmpty) {
      return CircleAvatar(radius: 40, backgroundImage: NetworkImage(user.photoUrl!));
    }
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(color: theme.colorScheme.primary, shape: BoxShape.circle),
      child: Center(
        child: Text(initials, style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: theme.colorScheme.onPrimary)),
      ),
    );
  }

  Widget _buildBadge(String label, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.35)),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: theme.colorScheme.primary, letterSpacing: 0.4),
      ),
    );
  }

  Widget _buildAccessibilitySection(UserModel user, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Acessibilidade', style: TextStyle(fontSize: 11, color: theme.textTheme.bodyMedium?.color)),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildSmallInfoCard(
              theme,
              icon: Icons.contrast,
              label: 'Alto Contraste',
              value: user.preferences.highContrast ? 'Ativado' : 'Desativado',
            ),
            const SizedBox(width: 12),
            _buildSmallInfoCard(
              theme,
              icon: Icons.format_size,
              label: 'Tam. Fonte',
              value: '${(user.preferences.fontSizeMultiplier * 100).toInt()}%',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSmallInfoCard(ThemeData theme, {required IconData icon, required String label, required String value}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.dividerColor.withOpacity(0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 16, color: theme.colorScheme.primary),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(fontSize: 10, color: theme.textTheme.bodyMedium?.color)),
            Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildNeurodivergenciesSection(UserModel user, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Condições / Neurodivergências', style: TextStyle(fontSize: 11, color: theme.textTheme.bodyMedium?.color)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: user.preferences.neurodivergencies
              .map((item) => _buildChip(item, color: theme.colorScheme.primary))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildChip(String label, {required Color color, Color? bg}) {
    final bgColor = bg ?? color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: bgColor.withOpacity(0.35)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildInfoRow(ThemeData theme, IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.10),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 18, color: theme.colorScheme.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 11, color: theme.textTheme.bodyMedium?.color),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
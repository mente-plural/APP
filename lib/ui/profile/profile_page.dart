import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../app_theme.dart';
import '../../core/auth/auth_service.dart';
import '../../models/user_model.dart';
import '../../shared/utils/ui_utils.dart';
import '../../shared/widgets/page_header.dart';
import '../../shared/widgets/custom_text_field.dart';
import 'widgets/profile_avatar.dart';
import 'widgets/info_row.dart';
import 'widgets/profile_badge.dart';
import 'widgets/profile_section.dart';
import 'widgets/neurodivergencies_section.dart';
import 'widgets/profile_type_selector.dart';

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
    }
  }

  String _getProfileLabel(String? type) {
    switch (type) {
      case 'FOR_ME': return 'Para Mim';
      case 'TUTOR': return 'Tutor ou Familiar';
      case 'LEARN_MORE': return 'Aprender Mais';
      default: return 'Perfil do Usuário';
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
              return Center(child: CircularProgressIndicator(color: theme.colorScheme.primary));
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
              HeaderActionIcon(icon: Icons.close, tooltip: 'Cancelar', onTap: _cancelEditing),
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
        ProfileAvatar(
          photoUrl: user.photoUrl,
          name: user.name ?? '',
          email: user.email,
          radius: 50,
          isEditing: true,
          isUploading: _isUploading,
          onEditTap: _pickAndUploadImage,
        ),
        const SizedBox(height: 24),
        ProfileSection(
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
        ),
        const SizedBox(height: 16),
        ProfileSection(
          title: 'Tipo de Perfil',
          child: ProfileTypeSelector(
            selectedType: _selectedProfileType,
            options: _profileTypes,
            onTypeSelected: (val) => setState(() => _selectedProfileType = val),
          ),
        ),
        const SizedBox(height: 16),
        ProfileSection(
          title: 'Neurodivergências',
          subtitle: 'Selecione as que se aplicam',
          child: NeurodivergenciesSection(
            neurodivergencies: _selectedNeurodivergencies,
            isEditing: true,
            availableOptions: _availableNeurodivergencies,
            onSelected: (item, val) {
              setState(() {
                val ? _selectedNeurodivergencies.add(item) : _selectedNeurodivergencies.remove(item);
              });
            },
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildMainCard(UserModel user, ThemeData theme) {
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
          ProfileAvatar(photoUrl: user.photoUrl, name: user.name ?? '', email: user.email),
          const SizedBox(height: 14),
          Text(
            user.name ?? 'Usuário',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
          ),
          const SizedBox(height: 8),
          ProfileBadge(label: _getProfileLabel(user.preferences.profileType)),
          const SizedBox(height: 24),
          Divider(color: theme.dividerColor, height: 1),
          const SizedBox(height: 20),
          InfoRow(icon: Icons.email_outlined, label: 'Email', value: user.email),
          const SizedBox(height: 16),
          InfoRow(icon: Icons.phone_outlined, label: 'Telefone', value: user.phone ?? 'Não informado'),
          const SizedBox(height: 16),
          InfoRow(icon: Icons.calendar_today_outlined, label: 'Membro desde', value: DateFormat('dd/MM/yyyy').format(user.createdAt)),
          if (user.preferences.neurodivergencies.isNotEmpty) ...[
            const SizedBox(height: 20),
            Divider(color: theme.dividerColor, height: 1),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text('Condições / Neurodivergências', style: TextStyle(fontSize: 11, color: theme.textTheme.bodyMedium?.color)),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: NeurodivergenciesSection(neurodivergencies: user.preferences.neurodivergencies),
            ),
          ],
        ],
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
}

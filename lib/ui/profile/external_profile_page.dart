import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../../app_theme.dart';
import '../../core/user/user_service.dart';
import '../../models/user_model.dart';
import '../../shared/utils/ui_utils.dart';
import 'widgets/profile_avatar.dart';
import 'widgets/info_row.dart';
import 'widgets/profile_badge.dart';
import 'widgets/profile_section.dart';
import 'widgets/neurodivergencies_section.dart';

class ExternalProfilePage extends StatefulWidget {
  final String userId;
  const ExternalProfilePage({super.key, required this.userId});

  @override
  State<ExternalProfilePage> createState() => _ExternalProfilePageState();
}

class _ExternalProfilePageState extends State<ExternalProfilePage> {
  final _userService = UserService();
  UserModel? _user;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final user = await _userService.getUserProfile(widget.userId);

      if (mounted) {
        if (user != null) {
          setState(() {
            _user = user;
            _isLoading = false;
          });
        } else {
          setState(() {
            _error = 'Usuário não encontrado.';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Erro ao carregar perfil: $e';
          _isLoading = false;
        });
      }
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

  void _copyToClipboard(String value, String label) {
    Clipboard.setData(ClipboardData(text: value));
    UiUtils.showSnackBar(context, '$label copiado com sucesso!');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: _buildBody(theme),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator(color: theme.colorScheme.primary));
    }

    if (_error != null) {
      return _buildErrorState(theme);
    }

    if (_user == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          _buildNavBar(theme),
          _buildProfileHeader(theme, _user!),
          _buildQrOriginBanner(theme),
          _buildContactSection(theme, _user!),
          if (_user!.preferences.neurodivergencies.isNotEmpty)
            _buildNeurodivergenciesSection(theme, _user!),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text(_error!, textAlign: TextAlign.center, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: _loadUser, child: const Text('Tentar novamente')),
          ],
        ),
      ),
    );
  }

  Widget _buildNavBar(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      child: Row(
        children: [
          _CircleButton(
            icon: Icons.arrow_back_rounded,
            onTap: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: Text(
              'Perfil',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          _CircleButton(
            icon: Icons.share_rounded,
            onTap: () {
              if (_user != null) {
                SharePlus.instance.share(
                  ShareParams(
                    text: 'Confira o perfil de ${_user!.name ?? 'Usuário'} no NeuroGuia!\nContato: ${_user!.email}',
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(ThemeData theme, UserModel user) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24, top: 16),
      child: Column(
        children: [
          ProfileAvatar(
            photoUrl: user.photoUrl,
            name: user.name ?? '',
            email: user.email,
            radius: 45,
          ),
          const SizedBox(height: 16),
          Text(user.name ?? 'Usuário', style: theme.textTheme.headlineMedium),
          const SizedBox(height: 8),
          ProfileBadge(label: _getProfileLabel(user.preferences.profileType)),
        ],
      ),
    );
  }

  Widget _buildQrOriginBanner(ThemeData theme) {
    final now = DateTime.now();
    final timeStr = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

    return Container(
      margin: const EdgeInsets.fromLTRB(18, 0, 18, 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        border: Border.all(color: theme.dividerColor, width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.qr_code_scanner_rounded, size: 20, color: theme.colorScheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Acesso via QR Code', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                Text('Visualizado hoje às $timeStr', style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey)),
              ],
            ),
          ),
          const Icon(Icons.check_circle, size: 20, color: Colors.green),
        ],
      ),
    );
  }

  Widget _buildContactSection(ThemeData theme, UserModel user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: ProfileSection(
        title: 'Informações de Contato',
        icon: Icons.alternate_email_rounded,
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            InfoRow(
              icon: Icons.email_outlined,
              label: 'E-mail',
              value: user.email,
              onTap: () => _copyToClipboard(user.email, 'E-mail'),
              trailing: Icon(Icons.copy_all_rounded, size: 18, color: theme.colorScheme.primary.withOpacity(0.5)),
            ),
            if (user.phone != null && user.phone!.isNotEmpty)
              InfoRow(
                icon: Icons.phone_android_rounded,
                label: 'Telefone / WhatsApp',
                value: user.phone!,
                onTap: () => _copyToClipboard(user.phone!, 'Telefone'),
                trailing: Icon(Icons.copy_all_rounded, size: 18, color: theme.colorScheme.primary.withOpacity(0.5)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNeurodivergenciesSection(ThemeData theme, UserModel user) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 0),
      child: ProfileSection(
        title: 'Condições e Neurodivergências',
        icon: Icons.psychology_outlined,
        child: NeurodivergenciesSection(neurodivergencies: user.preferences.neurodivergencies),
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          shape: BoxShape.circle,
          border: Border.all(color: theme.dividerColor, width: 1),
        ),
        child: Icon(icon, size: 20, color: theme.colorScheme.onSurface),
      ),
    );
  }
}

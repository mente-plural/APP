import 'package:flutter/material.dart';
import '../../app_theme.dart';
import '../../core/api_client.dart';
import '../../models/user_model.dart';
import '../../shared/widgets/page_header.dart';

class ExternalProfilePage extends StatefulWidget {
  final String userId;
  const ExternalProfilePage({super.key, required this.userId});

  @override
  State<ExternalProfilePage> createState() => _ExternalProfilePageState();
}

class _ExternalProfilePageState extends State<ExternalProfilePage> {
  final _apiClient = ApiClient();
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
      final response = await _apiClient.fetchUser(widget.userId);
      final userData = response['user'] ?? response['data'] ?? response;
      
      if (userData is Map && userData.isNotEmpty) {
        setState(() {
          _user = UserModel.fromMap(userData.cast<String, dynamic>());
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = "Usuário não encontrado.";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = "Erro ao carregar perfil: $e";
        _isLoading = false;
      });
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
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: PageHeader(
                title: "Perfil",
              ),
            ),
            Expanded(
              child: _buildContent(theme),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(ThemeData theme) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator(color: theme.colorScheme.primary));
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text(_error!, style: TextStyle(color: theme.colorScheme.onSurface)),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: _loadUser, child: const Text("Tentar novamente")),
          ],
        ),
      );
    }

    if (_user == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          _buildMainCard(_user!, theme),
          const SizedBox(height: 24),
          _buildActionButtons(theme),
          const SizedBox(height: 32),
        ],
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
          if (user.photoUrl != null && user.photoUrl!.isNotEmpty)
            CircleAvatar(
              radius: 40,
              backgroundImage: NetworkImage(user.photoUrl!),
            )
          else
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  initials,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
              ),
            ),
          const SizedBox(height: 14),
          Text(
            user.name ?? 'Usuário',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: theme.colorScheme.primary.withOpacity(0.35)),
            ),
            child: Text(
              _getProfileLabel(user.preferences.profileType),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Divider(color: theme.dividerColor, height: 1),
          const SizedBox(height: 20),
          _buildInfoRow(theme, Icons.email_outlined, 'Email', user.email),
          if (user.phone != null && user.phone!.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildInfoRow(theme, Icons.phone_outlined, 'Telefone', user.phone!),
          ],
          if (user.preferences.neurodivergencies.isNotEmpty) ...[
            const SizedBox(height: 20),
            Divider(color: theme.dividerColor, height: 1),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: user.preferences.neurodivergencies
                    .map((item) => _buildChip(item, color: theme.colorScheme.primary))
                    .toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildChip(String label, {required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }

  Widget _buildInfoRow(ThemeData theme, IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 11, color: theme.textTheme.bodyMedium?.color)),
              Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: theme.colorScheme.onSurface)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.chat_bubble_outline),
            label: const Text("Enviar Mensagem"),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
      ],
    );
  }
}

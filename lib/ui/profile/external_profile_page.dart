import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/api_client.dart';
import '../../models/user_model.dart';

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
  String? _toastMessage;

  static const _purple100 = Color(0xFFCECBF6);
  static const _purple200 = Color(0xFFAFA9EC);
  static const _purple400 = Color(0xFF7F77DD);
  static const _purple600 = Color(0xFF534AB7);
  static const _purple900 = Color(0xFF26215C);
  static const _teal400   = Color(0xFF1D9E75);
  static const _bg        = Color(0xFF0F0E14);
  static const _surface   = Color(0xFF1A1825);
  static const _surface2  = Color(0xFF1E1C28);
  static const _divider   = Color(0xFF24222E);
  static const _border    = Color(0xFF2E2C3E);
  static const _textPrimary    = Color(0xFFEEEDFE);
  static const _textSecondary  = Color(0xFFC5C0F0);
  static const _textMuted      = Color(0xFF888888);
  static const _textHint       = Color(0xFF555555);

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      setState(() { _isLoading = true; _error = null; });
      final response = await _apiClient.fetchUser(widget.userId);
      final userData = response['user'] ?? response['data'] ?? response;
      if (userData is Map && userData.isNotEmpty) {
        setState(() {
          _user = UserModel.fromMap(userData.cast<String, dynamic>());
          _isLoading = false;
        });
      } else {
        setState(() { _error = 'Usuário não encontrado.'; _isLoading = false; });
      }
    } catch (e) {
      setState(() { _error = 'Erro ao carregar perfil: $e'; _isLoading = false; });
    }
  }

  String _getProfileLabel(String? type) {
    switch (type) {
      case 'FOR_ME':     return 'Para Mim';
      case 'TUTOR':      return 'Tutor ou Familiar';
      case 'LEARN_MORE': return 'Aprender Mais';
      default:           return 'Perfil do Usuário';
    }
  }

  void _copyToClipboard(String value, String label) {
    Clipboard.setData(ClipboardData(text: value));
    setState(() => _toastMessage = '$label copiado');
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _toastMessage = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Stack(
          children: [
            _buildBody(),
            if (_toastMessage != null)
              Positioned(
                bottom: 24,
                left: 0,
                right: 0,
                child: _buildToast(_toastMessage!),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: _purple400));
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
              const SizedBox(height: 16),
              Text(_error!, textAlign: TextAlign.center,
                  style: const TextStyle(color: _textSecondary)),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadUser,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _purple600,
                  foregroundColor: _purple100,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }
    if (_user == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          _buildNavBar(),
          _buildProfileHeader(_user!),
          _buildQrOriginBanner(),
          _buildContactSection(_user!),
          if (_user!.preferences.neurodivergencies.isNotEmpty)
            _buildNeurodivergenciesSection(_user!),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildNavBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      child: Row(
        children: [
          _CircleButton(icon: Icons.arrow_back_rounded, onTap: () => Navigator.of(context).pop()),
          const Expanded(
            child: Text('Perfil',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: _textSecondary),
            ),
          ),
          _CircleButton(icon: Icons.more_horiz_rounded, onTap: () {}),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(UserModel user) {
    final initials = (user.name?.isNotEmpty == true)
        ? user.name![0].toUpperCase()
        : user.email.isNotEmpty ? user.email[0].toUpperCase() : '?';

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              user.photoUrl?.isNotEmpty == true
                  ? CircleAvatar(
                      radius: 40,
                      backgroundImage: NetworkImage(user.photoUrl!),
                    )
                  : Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: _purple900,
                        shape: BoxShape.circle,
                        border: Border.all(color: _purple600, width: 2.5),
                      ),
                      child: Center(
                        child: Text(initials,
                            style: const TextStyle(
                                fontSize: 28, fontWeight: FontWeight.w500, color: _purple100)),
                      ),
                    ),
              Positioned(
                bottom: 2,
                right: 2,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: _teal400,
                    shape: BoxShape.circle,
                    border: Border.all(color: _bg, width: 2.5),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            user.name ?? 'Usuário',
            style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w500, color: _textPrimary),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: _purple900,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _purple600, width: 0.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.group_outlined, size: 11, color: _purple200),
                const SizedBox(width: 5),
                Text(_getProfileLabel(user.preferences.profileType),
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: _purple200)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQrOriginBanner() {
    final now = TimeOfDay.now();
    final hh = now.hour.toString().padLeft(2, '0');
    final mm = now.minute.toString().padLeft(2, '0');

    return Container(
      margin: const EdgeInsets.fromLTRB(18, 0, 18, 14),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border, width: 0.5),
      ),
      child: Row(
        children: [
          const Icon(Icons.qr_code_rounded, size: 15, color: _purple600),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Perfil escaneado via QR Code',
                    style: TextStyle(fontSize: 11, color: _textMuted)),
                Text('Hoje às $hh:$mm',
                    style: const TextStyle(fontSize: 10, color: _textHint)),
              ],
            ),
          ),
          const Icon(Icons.check_circle_outline_rounded, size: 14, color: _teal400),
        ],
      ),
    );
  }

  Widget _buildContactSection(UserModel user) {
    return _SectionCard(
      icon: Icons.contacts_outlined,
      label: 'Contato',
      items: [
        _InfoItemData(icon: Icons.email_outlined, label: 'Email', value: user.email,
            onTap: () => _copyToClipboard(user.email, 'Email')),
        if (user.phone?.isNotEmpty == true)
          _InfoItemData(icon: Icons.phone_outlined, label: 'Telefone', value: user.phone!,
              onTap: () => _copyToClipboard(user.phone!, 'Telefone')),
      ],
    );
  }

  Widget _buildNeurodivergenciesSection(UserModel user) {
    return Container(
      margin: const EdgeInsets.fromLTRB(18, 0, 18, 12),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(icon: Icons.psychology_outlined, label: 'Condições / Neurodivergências'),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: user.preferences.neurodivergencies
                  .map((item) => _ProfileChip(label: item))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToast(String message) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: _surface2,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _purple600, width: 0.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_outline, size: 14, color: _teal400),
            const SizedBox(width: 6),
            Text(message, style: const TextStyle(fontSize: 12, color: _purple200)),
          ],
        ),
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: const Color(0xFF1E1C28),
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFF2E2C3E), width: 0.5),
        ),
        child: Icon(icon, size: 16, color: Colors.white70),
      ),
    );
  }
}

class _InfoItemData {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;
  const _InfoItemData({required this.icon, required this.label, required this.value, required this.onTap});
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String label;
  const _SectionHeader({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFF24222E), width: 0.5)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 15, color: const Color(0xFF534AB7)),
          const SizedBox(width: 8),
          Text(label.toUpperCase(),
              style: const TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w500,
                  color: Color(0xFF555555), letterSpacing: 0.5)),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final List<_InfoItemData> items;
  const _SectionCard({required this.icon, required this.label, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(18, 0, 18, 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1825),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2E2C3E), width: 0.5),
      ),
      child: Column(
        children: [
          _SectionHeader(icon: icon, label: label),
          ...items.map((item) => _InfoItemWidget(data: item)),
        ],
      ),
    );
  }
}

class _InfoItemWidget extends StatelessWidget {
  final _InfoItemData data;
  const _InfoItemWidget({required this.data});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: data.onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Color(0xFF24222E), width: 0.5)),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF26215C),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(data.icon, size: 14, color: const Color(0xFF7F77DD)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(data.label,
                      style: const TextStyle(fontSize: 10, color: Color(0xFF555555))),
                  const SizedBox(height: 1),
                  Text(data.value,
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w500,
                          color: Color(0xFFC5C0F0)),
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            const Icon(Icons.copy_outlined, size: 13, color: Color(0xFF7F77DD)),
          ],
        ),
      ),
    );
  }
}

class _ProfileChip extends StatelessWidget {
  final String label;
  const _ProfileChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF26215C),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF534AB7), width: 0.5),
      ),
      child: Text(label,
          style: const TextStyle(
              fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFFAFA9EC))),
    );
  }
}

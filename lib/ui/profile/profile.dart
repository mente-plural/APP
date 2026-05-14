import 'package:flutter/material.dart';
import '../../app_theme.dart';
import '../../core/auth_service.dart';
import '../../models/user_model.dart';
import '../../shared/widgets/primary_button.dart';
import '../login/login.dart';
import '../qrpage/qrpage.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with SingleTickerProviderStateMixin {
  bool _showQr = false;
  late AnimationController _qrController;
  late Animation<double> _qrAnimation;
  final _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _qrController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _qrAnimation = CurvedAnimation(
      parent: _qrController,
      curve: Curves.easeInOut,
    );
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
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
            (route) => false,
      );
    }
  }

  void _openPreferencesSheet(UserModel user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PreferencesSheet(user: user),
    );
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
    return Scaffold(
      backgroundColor: AppColors.bgEscuro,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Meu Perfil',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          // QR Code
          IconButton(
            tooltip: 'Meu QR Code',
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: AppColors.surfaceEscuro,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.qr_code_2,
                  size: 16, color: AppColors.primaryEscuro),
            ),
            onPressed: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const qrpage())),
          ),
          // Sair
          IconButton(
            tooltip: 'Sair',
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: AppColors.surfaceEscuro,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.edit, size: 16, color: AppColors.textSecundarioEscuro),
            ),
            onPressed: () {
              // TODO: Implementar edição de perfil
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: StreamBuilder<UserModel?>(
        stream: _authService.userStream,
        builder: (context, snapshot) {
          final user = snapshot.data;

          if (user == null) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryEscuro),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            child: Column(
              children: [
                _buildMainCard(user),
                const SizedBox(height: 16),
                _buildQrToggleButton(),
                _buildQrSection(user),
                const SizedBox(height: 32),
                PrimaryButton(
                  label: 'Sair da Conta',
                  onPressed: () async {
                    await _authService.logout();
                    if (mounted) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                        (route) => false,
                      );
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMainCard(UserModel user) {
    final initials = (user.name != null && user.name!.isNotEmpty)
        ? user.name![0].toUpperCase()
        : user.email.isNotEmpty ? user.email[0].toUpperCase() : '?';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surfaceEscuro,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderEscuro),
      ),
      child: Column(
        children: [
          // Avatar
          if (user.photoUrl != null && user.photoUrl!.isNotEmpty)
            CircleAvatar(
              radius: 40,
              backgroundImage: NetworkImage(user.photoUrl!),
            )
          else
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: AppColors.primaryEscuro,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  initials,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF020617), // Slate 950 para contraste
                  ),
                ),
              ),
            ),
          const SizedBox(height: 14),

          // Nome
          Text(
            user.name ?? 'Usuário',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),

          // Tipo de Perfil (Badge)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primaryEscuro.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.primaryEscuro.withOpacity(0.35)),
            ),
            child: Text(
              _getProfileLabel(user.profileType),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryEscuro,
                letterSpacing: 0.4,
              ),
            ),
          ),

          const SizedBox(height: 24),
          const Divider(color: AppColors.borderEscuro, height: 1),
          const SizedBox(height: 20),

          // Informações de contato
          _buildInfoRow(Icons.email_outlined, 'Email', user.email),
          if (user.phone != null && user.phone!.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildInfoRow(Icons.phone_outlined, 'Telefone', user.phone!),
          ],
        ],
      ),
    );
  }

  Widget _chip(String label, {required Color color, Color? bg}) {
    final bgColor = bg ?? color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: bgColor.withOpacity(0.35)),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
              letterSpacing: 0.3)),
    );
  }

  Widget _infoRow(IconData icon, String label, String value,
      {Color iconColor = AppColors.primaryEscuro,
        Color iconBg = AppColors.primaryEscuro}) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.primaryEscuro.withOpacity(0.10),
            borderRadius: BorderRadius.circular(12),
          ),
          child: new Icon(icon, size: 18, color: AppColors.primaryEscuro),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 11, color: AppColors.textSecundarioEscuro),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQrToggleButton() {
    return GestureDetector(
      onTap: _toggleQr,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.borderEscuro),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _showQr ? Icons.qr_code_2 : Icons.qr_code_scanner,
              color: Colors.white,
              size: 20,
            ),
          ),
          _divider(),

          // Tipo de perfil
          _prefRow(
            icon: Icons.person_outline,
            iconBg: AppColors.primaryEscuro,
            iconColor: AppColors.primaryEscuro,
            label: 'TIPO DE PERFIL',
            child: Text(
              _getProfileLabel(user.profileType),
              style: const TextStyle(
                  color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
            ),
            const SizedBox(width: 8),
            AnimatedRotation(
              turns: _showQr ? 0.5 : 0,
              duration: const Duration(milliseconds: 320),
              child: const Icon(
                Icons.keyboard_arrow_down,
                color: AppColors.textSecundarioEscuro,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQrSection(UserModel user) {
    return SizeTransition(
      sizeFactor: _qrAnimation,
      axisAlignment: -1,
      child: Padding(
        padding: const EdgeInsets.only(top: 16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.surfaceEscuro,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.borderEscuro),
          ),
          child: Column(
            children: [
              Container(
                width: 180,
                height: 180,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Center(
                  child: Icon(
                    Icons.qr_code_2,
                    size: 140,
                    color: AppColors.bgEscuro,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Escaneie para compartilhar seu perfil de saúde',
                style: TextStyle(fontSize: 12, color: AppColors.textSecundarioEscuro),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app_theme.dart';
import '../../core/providers/profile_provider.dart';
import '../login/login.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  bool _showQr = false;
  late AnimationController _qrController;
  late Animation<double> _qrAnimation;

  // Design tokens
  static const Color _bg = Color(0xFF0B0F19);
  static const Color _card = Color(0xFF151A25);
  static const Color _primary = Color(0xFF00C896);
  static const Color _divider = Color(0x1AFFFFFF);

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
    // Busca perfil ao abrir a tela
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().fetchProfile();
    });
  }

  @override
  void dispose() {
    _qrController.dispose();
    super.dispose();
  }

  void _toggleQr() {
    setState(() => _showQr = !_showQr);
    _showQr ? _qrController.forward() : _qrController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Meu Perfil',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: _card, shape: BoxShape.circle),
              child: const Icon(Icons.edit, size: 16, color: Colors.grey),
            ),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer<ProfileProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: _primary),
            );
          }

          if (provider.errorMessage != null) {
            return _buildError(provider);
          }

          final profile = provider.profile;
          if (profile == null) return const SizedBox.shrink();

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            child: Column(
              children: [
                _buildMainCard(profile),
                const SizedBox(height: 16),
                _buildQrToggleButton(),
                _buildQrSection(profile),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Card principal: avatar + nome + infos ──
  Widget _buildMainCard(UserProfile profile) {
    final initials = profile.name.isNotEmpty
        ? profile.name[0].toUpperCase()
        : '?';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _divider),
      ),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: _primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                initials,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Nome
          Text(
            profile.name,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),

          // Role (ex: Paciente)
          Text(
            profile.role,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _primary,
            ),
          ),
          const SizedBox(height: 6),

          // Badge de neurodivergência
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: _primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _primary.withOpacity(0.35)),
            ),
            child: Text(
              profile.neurodivergenceType,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _primary,
                letterSpacing: 0.4,
              ),
            ),
          ),

          const SizedBox(height: 24),
          const Divider(color: _divider, height: 1),
          const SizedBox(height: 20),

          // Informações de contato
          _buildInfoRow(Icons.email_outlined, 'Email', profile.email),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.phone_outlined, 'Telefone', profile.phone),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _primary.withOpacity(0.10),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 18, color: _primary),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
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
      ],
    );
  }

  // ── Botão de toggle do QR ──
  Widget _buildQrToggleButton() {
    return GestureDetector(
      onTap: _toggleQr,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white24),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _showQr ? Icons.qr_code_2 : Icons.qr_code_scanner,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              _showQr ? 'Ocultar QR Code' : 'Mostrar QR Code',
              style: const TextStyle(
                fontSize: 15,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            AnimatedRotation(
              turns: _showQr ? 0.5 : 0,
              duration: const Duration(milliseconds: 320),
              child: const Icon(
                Icons.keyboard_arrow_down,
                color: Colors.white54,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── QR animado (expande/colapsa) ──
  Widget _buildQrSection(UserProfile profile) {
    return SizeTransition(
      sizeFactor: _qrAnimation,
      axisAlignment: -1,
      child: Padding(
        padding: const EdgeInsets.only(top: 16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
          decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: _divider),
          ),
          child: Column(
            children: [
              Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Icon(
                    Icons.qr_code_2,
                    size: 140,
                    color: _bg,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Escaneie para ver informações de suporte',
                style: TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Estado de erro ──
  Widget _buildError(ProfileProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
            const SizedBox(height: 16),
            Text(
              provider.errorMessage!,
              style: const TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: _primary),
              onPressed: () => provider.fetchProfile(),
              child: const Text(
                'Tentar novamente',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
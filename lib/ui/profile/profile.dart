import 'package:flutter/material.dart';
import '../../app_theme.dart';
import '../../core/auth_service.dart';
import '../../models/user_model.dart';
import '../login/login.dart';
import '../qrpage/qr_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _authService = AuthService();

  String _getProfileLabel(String? type) {
    switch (type) {
      case 'FOR_ME':      return 'Para Mim';
      case 'TUTOR':       return 'Tutor ou Familiar';
      case 'LEARN_MORE':  return 'Aprender Mais';
      default:            return 'Perfil do Usuário';
    }
  }

  String _getThemeLabel(String? theme) {
    switch (theme) {
      case 'dark':   return 'Escuro';
      case 'light':  return 'Claro';
      case 'system': return 'Sistema';
      default:       return 'Escuro';
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
                .push(MaterialPageRoute(builder: (_) => const QrPage())),
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
              child: const Icon(Icons.logout_rounded,
                  size: 16, color: Colors.redAccent),
            ),
            onPressed: _confirmLogout,
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
                const SizedBox(height: 12),
                _buildPreferencesCard(user),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Card principal ──
  Widget _buildMainCard(UserModel user) {
    final initials = (user.name?.isNotEmpty == true)
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
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                Column(
                  children: [
                    if (user.photoUrl?.isNotEmpty == true)
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
                          child: Text(initials,
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF020617),
                              )),
                        ),
                      ),
                    const SizedBox(height: 14),
                    Text(
                      user.name ?? 'Usuário',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      alignment: WrapAlignment.center,
                      children: [
                        _chip(_getProfileLabel(user.profileType),
                            color: AppColors.primaryEscuro),
                        if (user.neurodivergenceTypes != null)
                          ...user.neurodivergenceTypes!.map((n) => _chip(n,
                              color: const Color(0xFFa5b4fc),
                              bg: const Color(0xFF6366f1))),
                      ],
                    ),
                  ],
                ),
                // Lápis no canto superior esquerdo
                Positioned(
                  top: 0,
                  left: 0,
                  child: GestureDetector(
                    onTap: () {
                      // TODO: tela de edição de perfil
                    },
                    child: Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: AppColors.bgEscuro.withOpacity(0.85),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.borderEscuro),
                      ),
                      child: const Icon(Icons.edit,
                          size: 14, color: AppColors.textSecundarioEscuro),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: AppColors.borderEscuro, height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            child: Column(
              children: [
                _infoRow(Icons.email_outlined, 'EMAIL', user.email),
                if (user.phone?.isNotEmpty == true) ...[
                  const SizedBox(height: 14),
                  _infoRow(Icons.phone_outlined, 'TELEFONE', user.phone!),
                ],
                const SizedBox(height: 14),
                _infoRow(
                  Icons.calendar_today_outlined,
                  'MEMBRO DESDE',
                  'Janeiro de 2024', // substitua por _formatDate(user.createdAt)
                  iconColor: const Color(0xFFa5b4fc),
                  iconBg: const Color(0xFF6366f1),
                ),
              ],
            ),
          ),
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
            color: iconBg.withOpacity(0.10),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 17, color: iconColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textSecundarioEscuro,
                      letterSpacing: 0.5)),
              const SizedBox(height: 2),
              Text(value,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white)),
            ],
          ),
        ),
      ],
    );
  }

  // ── Card de preferências ──
  Widget _buildPreferencesCard(UserModel user) {
    final neuroList = user.neurodivergenceTypes ?? [];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceEscuro,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderEscuro),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Text(
                'PREFERÊNCIAS',
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.textSecundarioEscuro,
                  letterSpacing: 0.8,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => _openPreferencesSheet(user),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryEscuro.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: AppColors.primaryEscuro.withOpacity(0.25)),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.edit, size: 12, color: AppColors.primaryEscuro),
                      SizedBox(width: 4),
                      Text('Editar',
                          style: TextStyle(
                              fontSize: 11,
                              color: AppColors.primaryEscuro,
                              fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Tema
          _prefRow(
            icon: Icons.dark_mode_outlined,
            iconBg: const Color(0xFF6366f1),
            iconColor: const Color(0xFFa5b4fc),
            label: 'TEMA',
            child: Text(
              _getThemeLabel(user.theme),
              style: const TextStyle(
                  color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
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
          ),
          _divider(),

          // Neurodivergências
          _prefRow(
            icon: Icons.psychology_outlined,
            iconBg: const Color(0xFFfbbf24),
            iconColor: const Color(0xFFfbbf24),
            label: 'NEURODIVERGÊNCIAS',
            child: neuroList.isEmpty
                ? const Text('Nenhuma selecionada',
                style: TextStyle(
                    color: AppColors.textSecundarioEscuro, fontSize: 13))
                : Wrap(
              spacing: 5,
              runSpacing: 5,
              children: neuroList
                  .map((n) => Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primaryEscuro.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color:
                      AppColors.primaryEscuro.withOpacity(0.3)),
                ),
                child: Text(n,
                    style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.primaryEscuro,
                        fontWeight: FontWeight.w500)),
              ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _prefRow({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String label,
    required Widget child,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: iconBg.withOpacity(0.12),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, size: 15, color: iconColor),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textSecundarioEscuro,
                        letterSpacing: 0.4)),
                const SizedBox(height: 5),
                child,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() =>
      const Divider(color: AppColors.borderEscuro, height: 1);
}

class qrpage {
  const qrpage();
}

// ── Bottom Sheet de edição de preferências ──
class _PreferencesSheet extends StatefulWidget {
  final UserModel user;
  const _PreferencesSheet({required this.user});

  @override
  State<_PreferencesSheet> createState() => _PreferencesSheetState();
}

class _PreferencesSheetState extends State<_PreferencesSheet> {
  late String _theme;
  late String _profileType;
  late List<String> _selectedNeuro;

  final _themes = ['dark', 'light', 'system'];
  final _themeLabels = {'dark': 'Escuro', 'light': 'Claro', 'system': 'Sistema'};
  final _profileTypes = ['FOR_ME', 'TUTOR', 'LEARN_MORE'];
  final _profileLabels = {
    'FOR_ME': 'Para Mim',
    'TUTOR': 'Tutor ou Familiar',
    'LEARN_MORE': 'Aprender Mais',
  };
  final _allNeuro = ['TDAH', 'Dislexia', 'TEA', 'Ansiedade', 'Discalculia', 'Dispraxia'];

  @override
  void initState() {
    super.initState();
    _theme = widget.user.theme ?? 'dark';
    _profileType = widget.user.profileType ?? 'FOR_ME';
    _selectedNeuro = List.from(widget.user.neurodivergenceTypes ?? []);
  }

  void _toggleNeuro(String n) {
    setState(() {
      _selectedNeuro.contains(n)
          ? _selectedNeuro.remove(n)
          : _selectedNeuro.add(n);
    });
  }

  Future<void> _save() async {
    // TODO: chamar authService.updatePreferences(theme: _theme, profileType: _profileType, neuro: _selectedNeuro)
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceEscuro,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: AppColors.borderEscuro)),
      ),
      padding: EdgeInsets.fromLTRB(
          20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 32),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: AppColors.borderEscuro,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const Text('Editar preferências',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            // Tema
            _sectionLabel('TEMA'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _themes
                  .map((t) => _OptionChip(
                label: _themeLabels[t]!,
                selected: _theme == t,
                onTap: () => setState(() => _theme = t),
              ))
                  .toList(),
            ),
            const SizedBox(height: 20),

            // Tipo de perfil
            _sectionLabel('TIPO DE PERFIL'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _profileTypes
                  .map((p) => _OptionChip(
                label: _profileLabels[p]!,
                selected: _profileType == p,
                onTap: () => setState(() => _profileType = p),
              ))
                  .toList(),
            ),
            const SizedBox(height: 20),

            // Neurodivergências (multi-select)
            _sectionLabel('NEURODIVERGÊNCIAS'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _allNeuro
                  .map((n) => _OptionChip(
                label: n,
                selected: _selectedNeuro.contains(n),
                onTap: () => _toggleNeuro(n),
                multiSelect: true,
              ))
                  .toList(),
            ),
            const SizedBox(height: 28),

            // Salvar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryEscuro,
                  foregroundColor: const Color(0xFF020617),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: _save,
                child: const Text('Salvar preferências',
                    style:
                    TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) => Text(
    text,
    style: const TextStyle(
        fontSize: 10,
        color: AppColors.textSecundarioEscuro,
        letterSpacing: 0.7,
        fontWeight: FontWeight.w600),
  );
}

class _OptionChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool multiSelect;

  const _OptionChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.multiSelect = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? (multiSelect
              ? const Color(0xFF6366f1).withOpacity(0.12)
              : AppColors.primaryEscuro.withOpacity(0.12))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? (multiSelect
                ? const Color(0xFF6366f1).withOpacity(0.45)
                : AppColors.primaryEscuro.withOpacity(0.45))
                : AppColors.borderEscuro,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: selected
                ? (multiSelect
                ? const Color(0xFFa5b4fc)
                : AppColors.primaryEscuro)
                : AppColors.textSecundarioEscuro,
          ),
        ),
      ),
    );
  }
}
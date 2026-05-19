import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/auth/auth_service.dart';
import '../../models/user_model.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:share_plus/share_plus.dart';
import '../profile/external_profile_page.dart';
import '../../shared/widgets/page_header.dart';


enum _QrMode { myQr, scan }
enum _B { top, bottom, left, right }

class QrPage extends StatefulWidget {
  const QrPage({super.key});

  @override
  State<QrPage> createState() => _QrPageState();
}

class _QrPageState extends State<QrPage> {
  _QrMode _mode = _QrMode.myQr;
  final _authService = AuthService();
  late final MobileScannerController _scannerController;

  @override
  void initState() {
    super.initState();
    _scannerController = MobileScannerController(autoStart: false);
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  void _switchMode(_QrMode mode) {
    if (_mode == mode) return;
    setState(() => _mode = mode);

    if (mode == _QrMode.scan) {
      _scannerController.start();
    } else {
      _scannerController.stop();
    }
  }

  bool _isProcessing = false;

  void _onQrDetected(String uid) {
    if (uid.isEmpty || _isProcessing) return;
    
    setState(() => _isProcessing = true);
    debugPrint("🔍 QR Detectado: $uid");
    
    // Para o scanner imediatamente
    _scannerController.stop();

    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ExternalProfilePage(userId: uid)),
    ).then((_) {
      setState(() => _isProcessing = false);
      // Reinicia o scanner ao voltar, se ainda estiver na aba de scan
      if (_mode == _QrMode.scan) {
        _scannerController.start();
      }
    });
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
                title: _mode == _QrMode.myQr ? 'QR Code' : 'Escanear',
                leading: BackButton(color: theme.colorScheme.onSurface),
              ),
            ),
            _buildToggle(theme),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: _mode == _QrMode.myQr
                    ? _MyQrView(authService: _authService)
                    : _ScanView(
                    onDetected: _onQrDetected,
                    controller: _scannerController
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggle(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        children: [
          _toggleBtn(
            theme,
            icon: Icons.qr_code_2,
            label: 'Meu QR',
            active: _mode == _QrMode.myQr,
            onTap: () => _switchMode(_QrMode.myQr),
          ),
          _toggleBtn(
            theme,
            icon: Icons.qr_code_scanner,
            label: 'Escanear',
            active: _mode == _QrMode.scan,
            onTap: () => _switchMode(_QrMode.scan),
          ),
        ],
      ),
    );
  }

  Widget _toggleBtn(
    ThemeData theme, {
    required IconData icon,
    required String label,
    required bool active,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? theme.colorScheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 18,
                  color: active
                      ? theme.colorScheme.onPrimary
                      : theme.textTheme.bodyMedium?.color),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: active
                      ? theme.colorScheme.onPrimary
                      : theme.textTheme.bodyMedium?.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Aba: Meu QR
class _MyQrView extends StatelessWidget {
  final AuthService authService;
  const _MyQrView({required this.authService});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return StreamBuilder<UserModel?>(
      stream: authService.userStream,
      builder: (context, snapshot) {
        final user = snapshot.data;
        final initials = (user?.name?.isNotEmpty == true)
            ? user!.name![0].toUpperCase()
            : '?';

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(initials,
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onPrimary)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.name ?? 'Usuário',
                          style: TextStyle(
                              color: theme.colorScheme.onSurface,
                              fontSize: 15,
                              fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: theme.dividerColor),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 210,
                      height: 210,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: QrImageView(
                          data: user?.id ?? '',
                          version: QrVersions.auto,
                          size: 182,
                          backgroundColor: Colors.white,
                          // Garante que o QR seja escuro mesmo em tema Dark,
                          // já que o fundo do container é branco.
                          eyeStyle: const QrEyeStyle(
                            eyeShape: QrEyeShape.square,
                            color: Color(0xFF1E1E1E),
                          ),
                          dataModuleStyle: const QrDataModuleStyle(
                            dataModuleShape: QrDataModuleShape.square,
                            color: Color(0xFF1E1E1E),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      user?.id != null && user!.id.length >= 4
                          ? 'USR-${user.id.substring(0, 4).toUpperCase()}'
                          : '---',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.textTheme.bodyMedium?.color,
                        letterSpacing: 1.4,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: theme.dividerColor),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline,
                        size: 15, color: theme.textTheme.bodyMedium?.color),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Peça para outro usuário escanear este código para acessar seu perfil de suporte.',
                        style: TextStyle(
                            fontSize: 12,
                            color: theme.textTheme.bodyMedium?.color,
                            height: 1.5),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  icon: const Icon(Icons.share_rounded, size: 18),
                  label: const Text('Compartilhar meu ID',
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold)),
                  onPressed: () {
                    if (user?.id != null) {
                      Share.share('Olá! Este é meu ID de suporte no NeuroFlow: ${user!.id}');
                    }
                  },
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.colorScheme.onSurface,
                    side: BorderSide(color: theme.dividerColor),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  icon: const Icon(Icons.copy_all_rounded, size: 18),
                  label: const Text('Copiar meu ID',
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600)),
                  onPressed: () {
                    if (user?.id != null) {
                      Clipboard.setData(ClipboardData(text: user!.id));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('ID copiado para a área de transferência')),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

}

class _ScanView extends StatelessWidget {
  final void Function(String uid) onDetected;
  final MobileScannerController controller;

  const _ScanView({
    required this.onDetected,
    required this.controller
  });

  static const _recent = [
    {'name': 'Maria', 'time': 'Hoje, 14:32', 'initial': 'M', 'uid': 'uid-001'},
    {'name': 'Carlos', 'time': 'Ontem, 09:15', 'initial': 'C', 'uid': 'uid-002'},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: AspectRatio(
              aspectRatio: 1,
              child: Stack(
                children: [
                  MobileScanner(
                    controller: controller,
                    onDetect: (capture) {
                      final barcode = capture.barcodes.first;
                      if (barcode.rawValue != null) {
                        onDetected(barcode.rawValue!);
                      }
                    },
                  ),
                  // Overlay de mira
                  Center(
                    child: SizedBox(
                      width: 200,
                      height: 200,
                      child: Stack(
                        children: [
                          _corner(theme, top: 0, left: 0, borders: {_B.top, _B.left}),
                          _corner(theme, top: 0, right: 0, borders: {_B.top, _B.right}),
                          _corner(theme, bottom: 0, left: 0, borders: {_B.bottom, _B.left}),
                          _corner(theme, bottom: 0, right: 0, borders: {_B.bottom, _B.right}),
                          const _ScanLine(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'Aponte a câmera para o QR Code\nde outro usuário do app',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 13,
                  color: theme.textTheme.bodyMedium?.color,
                  height: 1.6),
            ),
          ),
          const SizedBox(height: 24),
          if (_recent.isNotEmpty) ...[
            Text(
              'ESCANEADOS RECENTEMENTE',
              style: TextStyle(
                fontSize: 10,
                color: theme.textTheme.bodyMedium?.color,
                letterSpacing: 0.8,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            ..._recent.map((item) => _recentCard(context, theme, item)),
          ],
        ],
      ),
    );
  }

  Widget _recentCard(BuildContext context, ThemeData theme, Map<String, String> item) {
    return GestureDetector(
      onTap: () => onDetected(item['uid']!),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(item['initial']!,
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onPrimary)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item['name']!,
                      style: TextStyle(
                          color: theme.colorScheme.onSurface,
                          fontSize: 14,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 2),
                  Text(item['time']!,
                      style: TextStyle(
                          color: theme.textTheme.bodyMedium?.color,
                          fontSize: 11)),
                ],
              ),
            ),
            Icon(Icons.chevron_right,
                color: theme.textTheme.bodyMedium?.color, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _corner(
    ThemeData theme, {
    double? top,
    double? bottom,
    double? left,
    double? right,
    required Set<_B> borders,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          border: Border(
            top: borders.contains(_B.top)
                ? BorderSide(color: theme.colorScheme.primary, width: 3)
                : BorderSide.none,
            bottom: borders.contains(_B.bottom)
                ? BorderSide(color: theme.colorScheme.primary, width: 3)
                : BorderSide.none,
            left: borders.contains(_B.left)
                ? BorderSide(color: theme.colorScheme.primary, width: 3)
                : BorderSide.none,
            right: borders.contains(_B.right)
                ? BorderSide(color: theme.colorScheme.primary, width: 3)
                : BorderSide.none,
          ),
          borderRadius: BorderRadius.only(
            topLeft: borders.containsAll({_B.top, _B.left})
                ? const Radius.circular(4)
                : Radius.zero,
            topRight: borders.containsAll({_B.top, _B.right})
                ? const Radius.circular(4)
                : Radius.zero,
            bottomLeft: borders.containsAll({_B.bottom, _B.left})
                ? const Radius.circular(4)
                : Radius.zero,
            bottomRight: borders.containsAll({_B.bottom, _B.right})
                ? const Radius.circular(4)
                : Radius.zero,
          ),
        ),
      ),
    );
  }
}

// Linha de scan animada
class _ScanLine extends StatefulWidget {
  const _ScanLine();

  @override
  State<_ScanLine> createState() => _ScanLineState();
}

class _ScanLineState extends State<_ScanLine>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 2))
      ..repeat();
    _anim = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.linear));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Positioned(
        top: _anim.value * 196,
        left: 0,
        right: 0,
        child: Container(
          height: 2,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.75),
            borderRadius: BorderRadius.circular(1),
          ),
        ),
      ),
    );
  }
}

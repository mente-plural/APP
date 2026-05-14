import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../app_theme.dart';
import '../../core/auth_service.dart';
import '../../models/user_model.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:share_plus/share_plus.dart';

enum _QrMode { myQr, scan }

class QrPage extends StatefulWidget {
  const QrPage({super.key});

  @override
  State<QrPage> createState() => _QrPageState();
}
enum _B { top, bottom, left, right }
class _QrPageState extends State<QrPage> {
  _QrMode _mode = _QrMode.myQr;
  final _authService = AuthService();

  late final MobileScannerController _scannerController;

  @override
  void initState() {
    super.initState();
    _scannerController = MobileScannerController();
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

  void _onQrDetected(String uid) {
    // TODO: buscar usuário por uid na API e navegar para o perfil dele
    // Navigator.of(context).push(
    //    MaterialPageRoute(builder: (_) => UserProfileViewPage(uid: uid)),
    //  );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Usuário encontrado: $uid'),
        backgroundColor: AppColors.surfaceEscuro,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
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
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: AppColors.surfaceEscuro,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back_ios_new,
                size: 14, color: Colors.white),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          _mode == _QrMode.myQr ? 'QR Code' : 'Escanear',
          style: const TextStyle(
              fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          _buildToggle(),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: _mode == _QrMode.myQr
                  ? _MyQrView(authService: _authService)
                  : _ScanView(onDetected: _onQrDetected),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggle() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceEscuro,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderEscuro),
      ),
      child: Row(
        children: [
          _toggleBtn(
            icon: Icons.qr_code_2,
            label: 'Meu QR',
            active: _mode == _QrMode.myQr,
            onTap: () => _switchMode(_QrMode.myQr),
          ),
          _toggleBtn(
            icon: Icons.qr_code_scanner,
            label: 'Escanear',
            active: _mode == _QrMode.scan,
            onTap: () => _switchMode(_QrMode.scan),
          ),
        ],
      ),
    );
  }

  Widget _toggleBtn({
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
            color: active ? AppColors.primaryEscuro : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 18,
                  color: active
                      ? const Color(0xFF020617)
                      : AppColors.textSecundarioEscuro),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: active
                      ? const Color(0xFF020617)
                      : AppColors.textSecundarioEscuro,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Aba: Meu QR ──────────────────────────────
class _MyQrView extends StatelessWidget {
  final AuthService authService;
  const _MyQrView({required this.authService});

  @override
  Widget build(BuildContext context) {
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
              // Identificação do usuário
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryEscuro,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(initials,
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF020617))),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.name ?? 'Usuário',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        if (user?.neurodivergenceTypes != null)
                          Wrap(
                            spacing: 5,
                            children: [
                              _chip(user!.profileType == 'FOR_ME'
                                  ? 'Para Mim'
                                  : user.profileType ?? ''),
                              ...user.neurodivergenceTypes!
                                  .map((n) => _chip(n, purple: true)),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // QR Box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surfaceEscuro,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: AppColors.borderEscuro),
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
                      child: const Center(
                        // Substitua por:
                        // QrImageView(
                        //   data: user?.uid ?? '',
                        //   version: QrVersions.auto,
                        //   size: 182,
                        //   backgroundColor: Colors.white,
                        //   eyeStyle: QrEyeStyle(
                        //     eyeShape: QrEyeShape.square,
                        //     color: AppColors.bgEscuro,
                        //   ),
                        // ),
                        child: Icon(
                          Icons.qr_code_2,
                          size: 182,
                          color: AppColors.bgEscuro,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    // UID formatado
                    Text(
                      user?.id != null
                          ? 'USR-${user!.id.substring(0, 4).toUpperCase()}'
                          : '---',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecundarioEscuro,
                        letterSpacing: 1.4,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Dica
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceEscuro,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.borderEscuro),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Icon(Icons.info_outline,
                        size: 15, color: AppColors.textSecundarioEscuro),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Peça para outro usuário escanear este código para acessar seu perfil de suporte.',
                        style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecundarioEscuro,
                            height: 1.5),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Botão compartilhar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryEscuro,
                    foregroundColor: const Color(0xFF020617),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  icon: const Icon(Icons.share_rounded, size: 18),
                  label: const Text('Compartilhar QR Code',
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold)),
                  onPressed: () {
                    // TODO: Share.shareXFiles([XFile(qrImagePath)]);
                  },
                ),
              ),
              const SizedBox(height: 10),

              // Botão copiar link
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: AppColors.borderEscuro),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  icon: const Icon(Icons.link_rounded, size: 18),
                  label: const Text('Copiar link do perfil',
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600)),
                  onPressed: () {
                    Clipboard.setData(const ClipboardData(
                        text: 'https://seuapp.com/perfil/id'));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Link copiado!'),
                        backgroundColor: AppColors.surfaceEscuro,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _chip(String label, {bool purple = false}) {
    final color =
        purple ? const Color(0xFFa5b4fc) : AppColors.primaryEscuro;
    final bg =
        purple ? const Color(0xFF6366f1) : AppColors.primaryEscuro;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: bg.withOpacity(0.35)),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 10, fontWeight: FontWeight.w600, color: color)),
    );
  }
}

// ── Aba: Escanear ─────────────────────────────
class _ScanView extends StatelessWidget {
  final void Function(String uid) onDetected;
  const _ScanView({required this.onDetected});

  // Mock de histórico recente (substitua por dados reais)
  static const _recent = [
    {'name': 'Maria', 'time': 'Hoje, 14:32', 'initial': 'M', 'uid': 'uid-001'},
    {'name': 'Carlos', 'time': 'Ontem, 09:15', 'initial': 'C', 'uid': 'uid-002'},
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Viewfinder da câmera
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: AspectRatio(
              aspectRatio: 1,
              child: Stack(
                children: [
                  // Substitua por:
                  // MobileScanner(
                  //   controller: scannerController,
                  //   onDetect: (capture) {
                  //     final barcode = capture.barcodes.first;
                  //     if (barcode.rawValue != null) {
                  //       onDetected(barcode.rawValue!);
                  //     }
                  //   },
                  // ),
                  Container(
                    color: AppColors.surfaceEscuro,
                    child: const Center(
                      child: Icon(Icons.camera_alt_outlined,
                          size: 64, color: AppColors.borderEscuro),
                    ),
                  ),

                  // Overlay de mira
                  Center(
                    child: SizedBox(
                      width: 200,
                      height: 200,
                      child: Stack(
                        children: [
                          _corner(top: 0, left: 0,
                              borders: {_B.top, _B.left}),
                          _corner(top: 0, right: 0,
                              borders: {_B.top, _B.right}),
                          _corner(bottom: 0, left: 0,
                              borders: {_B.bottom, _B.left}),
                          _corner(bottom: 0, right: 0,
                              borders: {_B.bottom, _B.right}),
                          // Linha de scan animada
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

          const Center(
            child: Text(
              'Aponte a câmera para o QR Code\nde outro usuário do app',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecundarioEscuro,
                  height: 1.6),
            ),
          ),
          const SizedBox(height: 24),

          // Histórico
          if (_recent.isNotEmpty) ...[
            const Text(
              'ESCANEADOS RECENTEMENTE',
              style: TextStyle(
                fontSize: 10,
                color: AppColors.textSecundarioEscuro,
                letterSpacing: 0.8,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            ..._recent.map((item) => _recentCard(context, item)),
          ],
        ],
      ),
    );
  }

  Widget _recentCard(BuildContext context, Map<String, String> item) {
    return GestureDetector(
      onTap: () => onDetected(item['uid']!),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceEscuro,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderEscuro),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(
                color: AppColors.primaryEscuro,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(item['initial']!,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF020617))),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item['name']!,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 2),
                  Text(item['time']!,
                      style: const TextStyle(
                          color: AppColors.textSecundarioEscuro,
                          fontSize: 11)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right,
                color: AppColors.textSecundarioEscuro, size: 20),
          ],
        ),
      ),
    );
  }

  // Cantos do viewfinder


  Widget _corner({
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
                ? const BorderSide(color: AppColors.primaryEscuro, width: 3)
                : BorderSide.none,
            bottom: borders.contains(_B.bottom)
                ? const BorderSide(color: AppColors.primaryEscuro, width: 3)
                : BorderSide.none,
            left: borders.contains(_B.left)
                ? const BorderSide(color: AppColors.primaryEscuro, width: 3)
                : BorderSide.none,
            right: borders.contains(_B.right)
                ? const BorderSide(color: AppColors.primaryEscuro, width: 3)
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
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Positioned(
        top: _anim.value * 196,
        left: 0,
        right: 0,
        child: Container(
          height: 2,
          decoration: BoxDecoration(
            color: AppColors.primaryEscuro.withOpacity(0.75),
            borderRadius: BorderRadius.circular(1),
          ),
        ),
      ),
    );
  }
}

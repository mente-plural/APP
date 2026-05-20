import 'package:flutter/material.dart';
import '../../core/auth/auth_service.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../profile/external_profile_page.dart';
import '../../shared/widgets/page_header.dart';
import './widgets/my_qr_view.dart';
import './widgets/scan_view.dart';

enum _QrMode { myQr, scan }

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
                    ? MyQrView(authService: _authService)
                    : ScanView(
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

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

enum _B { top, bottom, left, right }

class ScanView extends StatelessWidget {
  final void Function(String uid) onDetected;
  final MobileScannerController controller;

  const ScanView({
    super.key,
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
      builder: (_, v) => Positioned(
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

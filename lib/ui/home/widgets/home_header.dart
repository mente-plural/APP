import 'package:flutter/material.dart';
import '../../../core/auth_service.dart';
import '../../../models/user_model.dart';
import '../../../shared/widgets/page_header.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return StreamBuilder<UserModel?>(
      stream: AuthService().userStream,
      builder: (context, snapshot) {
        final user = snapshot.data;
        final firstName = user?.name?.split(' ').first ?? 'Usuário';

        return PageHeader(
          title: "Olá, $firstName",
          actions: [
            HeaderActionIcon(
              icon: Icons.qr_code_scanner,
              tooltip: 'Escanear QR',
              iconColor: theme.colorScheme.primary,
              onTap: () => Navigator.pushNamed(context, '/qr'),
            ),
            HeaderActionIcon(
              icon: Icons.notifications_none,
              tooltip: 'Notificações',
              onTap: () {},
            ),
          ],
        );
      },
    );
  }
}

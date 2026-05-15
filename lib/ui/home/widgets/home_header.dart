import 'package:flutter/material.dart';
import '../../../core/auth_service.dart';
import '../../../models/user_model.dart';

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

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Olá, $firstName",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            Row(
              children: [
                _buildIconButton(
                  icon: Icons.qr_code_scanner,
                  theme: theme,
                  onTap: () => Navigator.pushNamed(context, '/qr'),
                ),
                const SizedBox(width: 12),
                _buildIconButton(
                  icon: Icons.notifications_none,
                  theme: theme,
                  onTap: () {},
                ),
              ],
            )
          ],
        );
      },
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required ThemeData theme,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: theme.colorScheme.onSurface, size: 20),
      ),
    );
  }
}
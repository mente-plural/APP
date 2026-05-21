import 'package:flutter/material.dart';

class PageHeader extends StatelessWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool center;

  const PageHeader({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.center = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);




    return SizedBox(
      width: double.infinity,
      height: 56,
      child: NavigationToolbar(
        leading: leading,
        middle: Text(
          title,
          textAlign: center ? TextAlign.center : TextAlign.start,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        trailing: (actions != null && actions!.isNotEmpty)
            ? Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: actions!,
              )
            : null,
        centerMiddle: center,
        middleSpacing: 16.0,
      ),
    );
  }
}

class HeaderActionIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;
  final Color? iconColor;

  const HeaderActionIcon({
    super.key,
    required this.icon,
    required this.onTap,
    this.tooltip,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 12),
      child: Tooltip(
        message: tooltip ?? '',
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                shape: BoxShape.circle,
                border: Border.all(
                  color: theme.dividerColor.withOpacity(0.1),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: iconColor ?? theme.colorScheme.onSurface,
                size: 24,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class StepPomodoro extends StatelessWidget {
  final String number;
  final String label;
  final String time;
  final bool isActive;

  const StepPomodoro({
    super.key,
    required this.number,
    required this.label,
    required this.time,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Column(
      children: [
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            color: isActive ? primary : theme.colorScheme.surface,
            shape: BoxShape.circle,
            border: isActive ? null : Border.all(
                color: theme.dividerColor.withValues(alpha: 0.1)),
            boxShadow: isActive
                ? [
              BoxShadow(color: primary.withValues(alpha: 0.3),
                  blurRadius: 15,
                  spreadRadius: 2)
            ]
                : null,
          ),
          child: Center(
            child: Text(
              number,
              style: TextStyle(
                color: isActive ? theme.colorScheme.onPrimary : theme.textTheme.bodyMedium?.color,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isActive ? primary : theme.textTheme.bodyMedium?.color,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          time,
          style: TextStyle(
            color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

class RoutineEmptyState extends StatelessWidget {
  const RoutineEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72, height: 72,
            decoration:
            BoxDecoration(color: theme.colorScheme.primary.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
            child: Icon(Icons.playlist_add_rounded, color: theme.colorScheme.primary, size: 36),
          ),
          const SizedBox(height: 20),
          Text(
            'Nenhuma tarefa ainda',
            style: TextStyle(
                color: theme.colorScheme.onSurface, fontSize: 17, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Toque no + para criar sua primeira tarefa.',
            style: TextStyle(color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7), fontSize: 14),
          ),
        ],
      ),
    );
  }
}

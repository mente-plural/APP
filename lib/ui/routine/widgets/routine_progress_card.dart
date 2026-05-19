import 'package:flutter/material.dart';

class RoutineProgressCard extends StatelessWidget {
  final int completedCount;
  final int totalCount;
  final double progress;

  const RoutineProgressCard({
    super.key,
    required this.completedCount,
    required this.totalCount,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pct = (progress * 100).toInt();
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Progresso do Dia', style: TextStyle(color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7), fontSize: 13)),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                '$pct% concluído',
                style: TextStyle(
                    color: theme.colorScheme.onSurface, fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              RichText(
                text: TextSpan(children: [
                  TextSpan(
                    text: '$completedCount',
                    style: TextStyle(
                        color: theme.colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  TextSpan(
                    text: ' / $totalCount',
                    style: TextStyle(color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7), fontSize: 16),
                  ),
                ]),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: theme.dividerColor.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/focus_provider.dart';

class FocusCard extends StatelessWidget {
  const FocusCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final focusProvider = Provider.of<FocusProvider>(context);

    int currentCycle = (focusProvider.completedCycles % 4) + 1;
    bool isFocus = focusProvider.status == PomodoroStatus.focus;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "CICLO ATUAL",
                    style: TextStyle(
                      color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.5),
                      fontWeight: FontWeight.w800,
                      fontSize: 10,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        "$currentCycle",
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        " / 4",
                        style: TextStyle(
                          color: theme.disabledColor.withValues(alpha: 0.5),
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              _buildModernIndicator(focusProvider, colorScheme),
            ],
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(
                  isFocus ? Icons.lightbulb_outline : Icons.self_improvement,
                  size: 18,
                  color: isFocus ? Colors.orange : colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isFocus 
                      ? "Mantenha o ritmo! Cada minuto conta." 
                      : "Respire fundo e relaxe os ombros.",
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernIndicator(FocusProvider provider, ColorScheme colorScheme) {
    bool isFocus = provider.status == PomodoroStatus.focus;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: (isFocus ? Colors.orange : colorScheme.primary).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Icon(
        isFocus ? Icons.local_fire_department_rounded : Icons.spa_rounded,
        color: isFocus ? Colors.orange : colorScheme.primary,
        size: 32,
      ),
    );
  }
}

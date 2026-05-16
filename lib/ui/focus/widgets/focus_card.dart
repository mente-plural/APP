
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../focus_page.dart';

class FocusCard extends StatelessWidget {
  const FocusCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "CICLO POMODORO",
            style: TextStyle(
              color: textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
              fontSize: 13,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              StepPomodoro(number: "1", label: "Foco", time: "25 min", isActive: true),
              StepPomodoro(number: "2", label: "Pausa\nCurta", time: "5 min", isActive: false),
              StepPomodoro(number: "3", label: "Foco", time: "25 min", isActive: false),
              StepPomodoro(number: "4", label: "Pausa\nCurta", time: "5 min", isActive: false),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Repita 4 vezes",
                style: TextStyle(color: textTheme.bodyMedium?.color?.withValues(alpha: 0.6), fontSize: 13, fontStyle: FontStyle.italic),
              ),
              const SizedBox(width: 8),
              _buildDot(context, isActive: true),
              _buildDot(context, isActive: false),
              _buildDot(context, isActive: false),
              _buildDot(context, isActive: false),
            ],
          ),
          const SizedBox(height: 24),
          Divider(color: theme.dividerColor.withValues(alpha: 0.1), thickness: 1, height: 1),
          const SizedBox(height: 24),
          Text(
            "PAUSA LONGA",
            style: TextStyle(
              color: textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
              fontSize: 13,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Após 4 ciclos, faça uma pausa longa.",
            style: TextStyle(color: textTheme.bodyMedium?.color?.withValues(alpha: 0.6), fontSize: 14),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "15–30 min",
              style: TextStyle(
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(BuildContext context, {required bool isActive}) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 3),
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        color: isActive ? theme.colorScheme.primary : theme.dividerColor.withValues(alpha: 0.2),
        shape: BoxShape.circle,
      ),
    );
  }
}


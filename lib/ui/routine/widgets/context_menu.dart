import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../models/routine_task_model.dart';

class ContextMenu extends StatelessWidget {
  final RoutineTaskModel task;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onDismiss;

  const ContextMenu({
    super.key,
    required this.task,
    required this.onEdit,
    required this.onDelete,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      type: MaterialType.transparency,
      child: GestureDetector(
        onTap: onDismiss,
        behavior: HitTestBehavior.opaque,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: Center(
            child: GestureDetector(
              onTap: () {},
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: theme.dividerColor),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.5),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _ContextOption(
                            icon: Icons.edit_rounded,
                            label: 'Editar tarefa',
                            color: theme.colorScheme.primary,
                            onTap: onEdit,
                            divider: true,
                          ),
                          _ContextOption(
                            icon: Icons.delete_outline_rounded,
                            label: 'Excluir tarefa',
                            color: const Color(0xFFFF6B6B),
                            onTap: onDelete,
                            divider: false,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Transform.scale(
                      scale: 1.04,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: theme.colorScheme.primary, width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: theme.colorScheme.primary.withValues(
                                  alpha: 0.15),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(task.title,
                                      style: TextStyle(
                                          color: theme.colorScheme.onSurface,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16)),
                                  const SizedBox(height: 4),
                                  Text(task.description,
                                      style: TextStyle(
                                          color: theme.textTheme.bodyMedium
                                              ?.color?.withValues(alpha: 0.7),
                                          fontSize: 13)),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                  color: theme.dividerColor.withValues(
                                      alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8)),
                              child: Text(task.time,
                                  style: TextStyle(
                                      color: theme.colorScheme.onSurface,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ContextOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool divider;

  const _ContextOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    required this.divider,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 14),
                Text(label,
                    style: TextStyle(
                        color: color, fontWeight: FontWeight.w600, fontSize: 15)),
                const Spacer(),
                Icon(Icons.chevron_right_rounded,
                    color: color.withValues(alpha: 0.5), size: 20),
              ],
            ),
          ),
        ),
        if (divider) Container(height: 1, color: theme.dividerColor),
      ],
    );
  }
}


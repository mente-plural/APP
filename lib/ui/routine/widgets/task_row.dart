import 'package:flutter/material.dart';
import '../../../models/routine_task_model.dart';
import 'context_menu.dart';

class TaskRow extends StatefulWidget {
  final RoutineTaskModel task;
  final int index;
  final bool isLast;
  final bool isHighlighted;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TaskRow({
    super.key,
    required this.task,
    required this.index,
    required this.isLast,
    this.isHighlighted = false,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<TaskRow> createState() => _TaskRowState();
}

class _TaskRowState extends State<TaskRow> {
  bool _pressed = false;

  void _handleLongPress() {
    setState(() => _pressed = true);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Align(
        alignment: Alignment.bottomCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ContextMenu(
            task:      widget.task,
            onEdit:    () { Navigator.pop(ctx); widget.onEdit(); },
            onDelete:  () { Navigator.pop(ctx); widget.onDelete(); },
            onDismiss: () => Navigator.pop(ctx),
          ),
        ),
      ),
    ).then((_) {
      if (mounted) setState(() => _pressed = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onLongPress: _handleLongPress,
      onTap: widget.onToggle,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildIndicator(theme),
            const SizedBox(width: 14),
            Expanded(child: _buildCard(theme)),
          ],
        ),
      ),
    );
  }

  Widget _buildIndicator(ThemeData theme) {
    return SizedBox(
      width: 36,
      child: Column(
        children: [
          // Linha conectora superior
          Expanded(
            child: Container(
              width: 2,
              color: widget.index == 0 ? Colors.transparent : theme.dividerColor,
            ),
          ),

          // Círculo indicador com o número ou check
          AnimatedScale(
            scale: _pressed ? 1.04 : 1.0,
            duration: const Duration(milliseconds: 180),
            child: GestureDetector(
              onTap: widget.onToggle,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.task.isCompleted
                      ? theme.colorScheme.primary.withOpacity(0.2)
                      : theme.colorScheme.surface,
                  border: Border.all(
                    color: widget.task.isCompleted
                        ? theme.colorScheme.primary
                        : theme.dividerColor,
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: widget.task.isCompleted
                      ? Icon(Icons.check_rounded, size: 16, color: theme.colorScheme.primary)
                      : Text(
                    '${widget.index + 1}',
                    style: TextStyle(
                      color: (theme.textTheme.bodyMedium?.color)?.withOpacity(0.7),
                      fontSize: 13,
                      fontWeight: widget.isHighlighted ? FontWeight.bold : FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Linha conectora inferior dinâmica (absorve o espaço restante perfeitamente)
          Expanded(
            child: Container(
              width: 2,
              color: widget.isLast ? Colors.transparent : theme.dividerColor,
            ),
          ),

          // 💡 O contêiner fixo de 12px foi removido daqui para eliminar o overflow!
        ],
      ),
    );
  }

  Widget _buildCard(ThemeData theme) {
    return Padding(
      padding: EdgeInsets.only(bottom: widget.isLast ? 0 : 12),
      child: AnimatedScale(
        scale: _pressed ? 1.04 : 1.0,
        duration: const Duration(milliseconds: 180),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: widget.isHighlighted ? theme.colorScheme.primary : theme.dividerColor,
              width: widget.isHighlighted ? 1.5 : 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.task.title,
                      style: TextStyle(
                        color: widget.task.isCompleted
                            ? theme.textTheme.bodyMedium?.color?.withOpacity(0.6)
                            : theme.colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        decoration: widget.task.isCompleted ? TextDecoration.lineThrough : null,
                        decorationColor: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.task.description,
                      style: TextStyle(
                        color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // Bloco do Horário (Mantido perfeitamente alinhado)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  widget.task.time,
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

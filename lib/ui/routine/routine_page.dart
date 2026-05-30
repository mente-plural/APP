import 'package:app/shared/utils/responsive.dart';
import 'package:flutter/material.dart';

import '../../core/routine/routine_service.dart';
import '../../models/routine_task_model.dart';
import '../../shared/widgets/page_header.dart';
import 'widgets/routine_empty_state.dart';
import 'widgets/routine_progress_card.dart';
import 'widgets/task_row.dart';
import 'widgets/task_sheet.dart';

class RoutinePage extends StatefulWidget {
  const RoutinePage({super.key});

  @override
  State<RoutinePage> createState() => _RoutinePageState();
}

class _RoutinePageState extends State<RoutinePage> {
  final RoutineService _routineService = RoutineService();
  bool _isActionLoading = false;

  @override
  void initState() {
    super.initState();
    _routineService.loadTodayRoutines();
  }

  void _toggleTask(RoutineTaskModel task) async {
    final newStatus = !task.isCompleted;
    final success = await _routineService.toggleTaskCompletion(task.id, newStatus);

    if (success && newStatus && _routineService.isAllTasksCompleted()) {
      _showCompletionDialog();
    } else if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao atualizar tarefa. Verifique sua conexão.')),
      );
    }
  }

  void _deleteTask(String taskId) async {
    final success = await _routineService.removeTask(taskId);
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao excluir tarefa.')),
      );
    }
  }

  void _openSheet({RoutineTaskModel? editTask}) {
    final titleCtrl = TextEditingController(text: editTask?.title ?? '');
    final descCtrl = TextEditingController(text: editTask?.description ?? '');

    int initHour = 8;
    int initMinute = 0;
    bool isPM = false;

    if (editTask != null && editTask.time.contains(':')) {
      final parts = editTask.time.split(':');
      if (parts.length == 2) {
        final rawHour = int.tryParse(parts[0]) ?? 8;
        initMinute = int.tryParse(parts[1]) ?? 0;
        isPM = rawHour >= 12;
        initHour = rawHour > 12 ? rawHour - 12 : (rawHour == 0 ? 12 : rawHour);
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => Align(
        alignment: Alignment.bottomCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: AnimatedPadding(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            padding: EdgeInsets.only(bottom: MediaQuery.of(sheetCtx).viewInsets.bottom),
            child: TaskSheet(
              titleCtrl: titleCtrl,
              descCtrl: descCtrl,
              isEditMode: editTask != null,
              initialHour: initHour,
              initialMinute: initMinute,
              initialIsPM: isPM,
              priority: editTask?.priority ?? 1,
              onSave: (title, desc, time, priority) async {
                if (title.trim().isEmpty) return;
                Navigator.pop(context);
                setState(() => _isActionLoading = true);

                String convertTo24h(String timeStr) {
                  try {
                    final parts = timeStr.trim().split(' ');
                    if (parts.length != 2) return timeStr;
                    final isPM = parts[1].toUpperCase() == 'PM';
                    final hm = parts[0].split(':');
                    if (hm.length != 2) return timeStr;
                    int hour = int.parse(hm[0]);
                    int minute = int.parse(hm[1]);
                    if (isPM && hour != 12) hour += 12;
                    if (!isPM && hour == 12) hour = 0;
                    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
                  } catch (e) {
                    return timeStr;
                  }
                }

                final String formattedTime = convertTo24h(time);

                try {
                  if (editTask != null) {
                    final updatedTask = editTask.copyWith(
                      title: title.trim(),
                      description: desc.trim(),
                      time: formattedTime,
                      priority: priority,
                    );
                    await _routineService.editTask(editTask.id, updatedTask);
                  } else {
                    final newTaskTemplate = RoutineTaskModel(
                      id: '',
                      title: title.trim(),
                      description: desc.trim(),
                      time: formattedTime,
                      isCompleted: false,
                      priority: priority,
                    );
                    await _routineService.createNewTask(newTaskTemplate);
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erro ao salvar tarefa: $e')),
                    );
                  }
                } finally {
                  if (mounted) setState(() => _isActionLoading = false);
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final horizontalPadding = context.responsiveSize(20.0, tabletSize: 40.0, desktopSize: 60.0);

    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: StreamBuilder<List<RoutineTaskModel>>(
          stream: _routineService.tasksStream,
          initialData: _routineService.cachedTasks,
          builder: (context, snapshot) {
            final tasks = snapshot.data ?? [];
            final allCompleted = _routineService.isAllTasksCompleted();
            final completedCount = tasks.where((t) => t.isCompleted).length;
            final progress = tasks.isEmpty ? 0.0 : completedCount / tasks.length;

            if (tasks.isEmpty && snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator(color: theme.colorScheme.primary));
            }

            return Stack(
              children: [
                Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 16.0),
                      child: PageHeader(
                        title: 'Minha Rotina',
                        actions: [
                          HeaderActionIcon(
                            icon: Icons.add_rounded,
                            tooltip: 'Adicionar Tarefa',
                            iconColor: theme.colorScheme.primary,
                            onTap: () => _openSheet(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                      child: RoutineProgressCard(
                        completedCount: completedCount,
                        totalCount: tasks.length,
                        progress: progress,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Expanded(
                      child: tasks.isEmpty
                          ? const RoutineEmptyState()
                          : ListView.builder(
                              padding: EdgeInsets.fromLTRB(horizontalPadding, 0, horizontalPadding, 32),
                              itemCount: tasks.length + (allCompleted ? 1 : 0),
                              itemBuilder: (_, i) {
                                if (i == tasks.length) {
                                  return _buildCompletionStatus(theme);
                                }
                                final firstIncompleteIndex = tasks.indexWhere((t) => !t.isCompleted);
                                return TaskRow(
                                  task: tasks[i],
                                  index: i,
                                  isLast: i == tasks.length - 1,
                                  isHighlighted: i == firstIncompleteIndex,
                                  onToggle: () => _toggleTask(tasks[i]),
                                  onEdit: () => _openSheet(editTask: tasks[i]),
                                  onDelete: () => _deleteTask(tasks[i].id),
                                );
                              },
                            ),
                    ),
                  ],
                ),
                if (_isActionLoading)
                  Container(
                    color: Colors.black.withValues(alpha: 0.25),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showCompletionDialog() {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            backgroundColor: theme.colorScheme.surface,
            surfaceTintColor: Colors.transparent,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.celebration_rounded, color: theme.colorScheme.primary, size: 40),
                ),
                const SizedBox(height: 24),
                Text(
                  'Tudo concluído!',
                  style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text(
                  'Parabéns! Você finalizou todas as tarefas da sua rotina de hoje.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: theme.textTheme.bodyMedium?.color?.withValues(
                        alpha: 0.7),
                    fontSize: 15,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 32),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: double.infinity,
                    height: 52,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withValues(
                              alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'Continuar',
                        style: TextStyle(color: theme.colorScheme.onPrimary, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompletionStatus(ThemeData theme) {
    final colorScheme = theme.colorScheme;
    final primaryColor = colorScheme.primary;

    return Container(
      margin: const EdgeInsets.only(top: 32, bottom: 8, left: 48, right: 48),
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: BoxDecoration(
        color: primaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryColor.withValues(alpha: 0.1)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.stars_rounded, color: primaryColor, size: 28),
          ),
          const SizedBox(height: 16),
          Text('Rotina Completa!', style: TextStyle(color: colorScheme.onSurface, fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(
            'Você cumpriu todos os seus objetivos para hoje. Bom trabalho!',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: theme.textTheme.bodyMedium?.color?.withValues(
                    alpha: 0.7), fontSize: 16, height: 1.3),
          ),
        ],
      ),
    );
  }
}

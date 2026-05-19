import 'package:flutter/material.dart';
import '../../models/routine_task_model.dart';
import '../../shared/widgets/page_header.dart';
import '../../core/routine/routine_service.dart';
import 'widgets/task_row.dart';
import 'widgets/task_sheet.dart';
import 'widgets/routine_progress_card.dart';
import 'widgets/routine_empty_state.dart';

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
    // Faz a chamada inicial para popular a Stream e o cache do Service
    _routineService.loadTodayRoutines();
  }

  void _toggleTask(RoutineTaskModel task) async {
    final newStatus = !task.isCompleted;

    // O service cuida do estado otimista na hora na Stream
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
    final descCtrl  = TextEditingController(text: editTask?.description ?? '');

    int initHour = 8;
    int initMinute = 0;
    bool isPM = false;

    // Tratamento seguro do formato de 24h retornado pelo backend
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
      barrierColor: Colors.black.withValues(alpha: 0.75),
      builder: (sheetCtx) => AnimatedPadding(
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

            // 1. Função interna para converter a String "HH:MM AM/PM" para "HH:MM" (24h)
            String convertTo24h(String timeStr) {
              try {
                final parts = timeStr.trim().split(' ');
                if (parts.length != 2) return timeStr; // Se já estiver em 24h, mantém

                final isPM = parts[1].toUpperCase() == 'PM';
                final hm = parts[0].split(':');
                if (hm.length != 2) return timeStr;

                int hour = int.parse(hm[0]);
                int minute = int.parse(hm[1]);

                // Regras de conversão de formato 12h para 24h
                if (isPM && hour != 12) hour += 12;
                if (!isPM && hour == 12) hour = 0;

                // Retorna no formato exato esperado pelo Fastify: "HH:MM"
                return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
              } catch (e) {
                debugPrint('⚠️ Erro ao converter formato de hora: $e');
                return timeStr; // Fallback seguro
              }
            }

            // 2. Aplica a conversão antes de montar os modelos
            final String formattedTime = convertTo24h(time);

            try {
              if (editTask != null) {
                final updatedTask = editTask.copyWith(
                  title: title.trim(),
                  description: desc.trim(),
                  time: formattedTime, // <--- String limpa em formato 24h
                  priority: priority,
                );
                await _routineService.editTask(editTask.id, updatedTask);
              } else {
                final newTaskTemplate = RoutineTaskModel(
                  id: '',
                  title: title.trim(),
                  description: desc.trim(),
                  time: formattedTime, // <--- String limpa em formato 24h
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: StreamBuilder<List<RoutineTaskModel>>(
          stream: _routineService.tasksStream,
          initialData: _routineService.cachedTasks,
          builder: (context, snapshot) {
            final tasks = snapshot.data ?? [];
            final allCompleted = _routineService.isAllTasksCompleted();
            final completedCount = tasks.where((t) => t.isCompleted).length;
            final progress = tasks.isEmpty ? 0.0 : completedCount / tasks.length;

            // Exibe loader apenas na primeira busca se o cache estiver vazio
            if (tasks.isEmpty && snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator(color: theme.colorScheme.primary));
            }

            return Stack(
              children: [
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
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
                    RoutineProgressCard(
                      completedCount: completedCount,
                      totalCount: tasks.length,
                      progress: progress,
                    ),
                    const SizedBox(height: 24),
                    Expanded(
                      child: tasks.isEmpty
                          ? const RoutineEmptyState()
                          : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
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
      builder: (context) => AlertDialog(
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
                color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
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
                      color: theme.colorScheme.primary.withValues(alpha: 0.3),
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
            style: TextStyle(color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7), fontSize: 16, height: 1.3),
          ),
        ],
      ),
    );
  }
}
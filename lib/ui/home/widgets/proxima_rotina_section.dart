import 'package:app/core/providers/navigation_provider.dart';
import 'package:app/core/routine/routine_service.dart';
import 'package:app/models/routine_task_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProximoRotinaSection extends StatefulWidget {
  final ThemeData theme;

  const ProximoRotinaSection({super.key, required this.theme});

  @override
  State<ProximoRotinaSection> createState() => _ProximoRotinaSectionState();
}

class _ProximoRotinaSectionState extends State<ProximoRotinaSection> {
  final RoutineService _routineService = RoutineService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

  Future<void> _fetchTasks() async {
    if (_routineService.cachedTasks.isEmpty) {
      setState(() => _isLoading = true);
    }
    await _routineService.loadTodayRoutines();
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  RoutineTaskModel? _getNextTask(List<RoutineTaskModel> tasks) {
    if (tasks.isEmpty) return null;
    // A próxima tarefa é a primeira que não estiver concluída (já vem ordenada por horário)
    final pendingTasks = tasks.where((task) => !task.isCompleted).toList();
    return pendingTasks.isNotEmpty ? pendingTasks.first : null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Próximo na Rotina",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: widget.theme.colorScheme.onSurface,
              ),
            ),
            InkWell(
              onTap: () => Provider.of<NavigationProvider>(context, listen: false).setIndex(1),
              child: Text(
                "Ver tudo",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: widget.theme.colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        StreamBuilder<List<RoutineTaskModel>>(
          stream: _routineService.tasksStream,
          builder: (context, snapshot) {
            final tasks = snapshot.data ?? _routineService.cachedTasks;
            
            if (_isLoading && tasks.isEmpty) {
              return const Center(child: Padding(
                padding: EdgeInsets.all(20.0),
                child: CircularProgressIndicator(),
              ));
            }

            final nextTask = _getNextTask(tasks);
            return _buildCardContent(context, tasks, nextTask);
          },
        ),
      ],
    );
  }

  Widget _buildCardContent(BuildContext context, List<RoutineTaskModel> tasks, RoutineTaskModel? nextTask) {
    if (tasks.isEmpty) {
      return _buildEmptyState(context);
    }

    if (nextTask == null) {
      return _buildAllDoneState(context);
    }

    return _buildTaskCard(context, nextTask);
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: widget.theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: widget.theme.dividerColor),
      ),
      child: Row(
        children: [
          Icon(Icons.calendar_today_outlined, color: widget.theme.colorScheme.primary.withOpacity(0.5)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              "Nenhuma tarefa para hoje",
              style: TextStyle(
                color: widget.theme.textTheme.bodyMedium?.color,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Provider.of<NavigationProvider>(context, listen: false).setIndex(1),
            child: const Text("Criar"),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(BuildContext context, RoutineTaskModel nextTask) {
    return InkWell(
      onTap: () => Provider.of<NavigationProvider>(context, listen: false).setIndex(1),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: widget.theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: widget.theme.dividerColor),
        ),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(color: widget.theme.colorScheme.primary, width: 4),
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: widget.theme.scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  nextTask.time,
                  style: TextStyle(
                    color: widget.theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nextTask.title,
                      style: TextStyle(
                        color: widget.theme.colorScheme.onSurface,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      nextTask.description.isNotEmpty ? nextTask.description : "Sua próxima atividade",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: widget.theme.textTheme.bodyMedium?.color,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: widget.theme.colorScheme.primary.withOpacity(0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAllDoneState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: widget.theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: widget.theme.colorScheme.primary.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline, color: widget.theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "Rotina concluída! Bom trabalho.",
              style: TextStyle(
                color: widget.theme.textTheme.bodyMedium?.color,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
          TextButton(
             onPressed: () => Provider.of<NavigationProvider>(context, listen: false).setIndex(1),
             child: Text(
               "Ver",
               style: TextStyle(
                 color: widget.theme.colorScheme.primary,
                 fontWeight: FontWeight.bold,
               ),
             ),
          )
        ],
      ),
    );
  }
}

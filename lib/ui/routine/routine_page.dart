import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app_theme.dart';
import '../../models/routine/routine_task_model.dart';
import '../../shared/widgets/page_header.dart';

class RoutinePage extends StatefulWidget {

  const RoutinePage({super.key});

  @override
  State<RoutinePage> createState() => _RoutinePageState();
}

class _RoutinePageState extends State<RoutinePage> {
  bool _isLoading = false;
  List<RoutineTaskModel> _tasks = [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() => _isLoading = true);

    await Future.delayed(const Duration(milliseconds: 800));
    
    if (!mounted) return;

    final mockTasks = [
      {
        'id': '1',
        'title': 'Remédio da manhã',
        'time': '08:00',
        'isCompleted': true,
        'icon': 'medication',
        'color': '0xFFF87171',
      },
      {
        'id': '2',
        'title': 'Café da manhã',
        'time': '08:30',
        'isCompleted': false,
        'icon': 'coffee',
        'color': '0xFFFBBF24',
      },
      {
        'id': '3',
        'title': 'Trabalho / Estudo',
        'time': '09:00',
        'isCompleted': false,
        'icon': 'work',
        'color': '0xFF60A5FA',
      },
      {
        'id': '4',
        'title': 'Alongamento',
        'time': '10:30',
        'isCompleted': false,
        'icon': 'fitness_center',
        'color': '0xFF34D399',
      },
    ];

    setState(() {
      _tasks = mockTasks.map((m) => RoutineTaskModel.fromMap(m)).toList();
      _isLoading = false;
    });
  }

  void _toggleTask(int index) {
    setState(() {
      _tasks[index] = _tasks[index].copyWith(isCompleted: !_tasks[index].isCompleted);
    });

  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(theme),
              const SizedBox(height: 32),
              _buildDateHeader(theme),
              const SizedBox(height: 16),
              _buildProgressCard(theme),
              const SizedBox(height: 32),
              const Text(
                "Tarefas de Hoje",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _tasks.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _tasks.length,
                          itemBuilder: (context, index) {
                            return _buildTaskItem(_tasks[index], index, theme);
                          },
                        ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return PageHeader(
      title: "Minha Rotina",
      actions: [
        HeaderActionIcon(
          icon: Icons.add_circle_outline,
          tooltip: 'Nova Tarefa',
          iconColor: theme.colorScheme.primary,
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildDateHeader(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Segunda-feira",
          style: TextStyle(
            color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
            fontSize: 14,
          ),
        ),
        const Text(
          "14 de Maio",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildProgressCard(ThemeData theme) {
    final colorScheme = theme.colorScheme;
    final primary = colorScheme.primary;
    final completed = _tasks.where((t) => t.isCompleted).length;
    final total = _tasks.length;
    final progress = total > 0 ? completed / total : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Seu progresso",
                  style: TextStyle(
                    color: primary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "$completed de $total tarefas concluídas",
                  style: TextStyle(
                    color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: primary.withValues(alpha: 0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(primary),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                "${(progress * 100).toInt()}%",
                style: TextStyle(
                  color: primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskItem(RoutineTaskModel task, int index, ThemeData theme) {
    final colorScheme = theme.colorScheme;
    final taskColor = task.color != null ? Color(int.parse(task.color!)) : colorScheme.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: task.isCompleted 
              ? Colors.transparent 
              : theme.dividerColor.withValues(alpha: 0.1),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: taskColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _getIconData(task.icon),
            color: taskColor,
          ),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
            color: task.isCompleted 
                ? theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.5) 
                : theme.colorScheme.primary,
          ),
        ),
        subtitle: Text(
          task.time.format(context),
          style: TextStyle(color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6)),
        ),
        trailing: Transform.scale(
          scale: 1.2,
          child: Checkbox(
            value: task.isCompleted,
            onChanged: (_) => _toggleTask(index),
            shape: const CircleBorder(),
            activeColor: colorScheme.primary,
          ),
        ),
      ),
    );
  }


  IconData _getIconData(String? iconName) {
    switch (iconName) {
      case 'medication': return Icons.medication_rounded;
      case 'coffee': return Icons.coffee_rounded;
      case 'work': return Icons.work_rounded;
      case 'fitness_center': return Icons.fitness_center_rounded;
      default: return Icons.task_alt_rounded;
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_today_outlined, size: 64, color: Colors.grey.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          const Text("Nenhuma tarefa agendada", style: TextStyle(fontWeight: FontWeight.bold)),
          const Text("Toque no + para começar sua rotina.", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

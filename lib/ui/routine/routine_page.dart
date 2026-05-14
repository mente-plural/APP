import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app_theme.dart';
import '../../core/providers/profile_provider.dart';
import '../../models/routine/routine_task_model.dart';

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
    // Simulação de tarefas
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
    // TODO: Sincronizar com o backend via ApiClient
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgEscuro : AppColors.bgClaro,
      appBar: AppBar(
        title: const Text("Minha Rotina", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () {
              // TODO: Adicionar nova tarefa
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDateHeader(isDark),
          const SizedBox(height: 16),
          _buildProgressCard(primaryColor, isDark),
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 24, 20, 12),
            child: Text(
              "Tarefas de Hoje",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _tasks.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _tasks.length,
                        itemBuilder: (context, index) {
                          return _buildTaskItem(_tasks[index], index, isDark, primaryColor);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateHeader(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Segunda-feira", // Ideal usar Intl para formatar data real
            style: TextStyle(
              color: isDark ? AppColors.textSecundarioEscuro : AppColors.textMutedClaro,
              fontSize: 14,
            ),
          ),
          const Text(
            "14 de Maio",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(Color primary, bool isDark) {
    final completed = _tasks.where((t) => t.isCompleted).length;
    final total = _tasks.length;
    final progress = total > 0 ? completed / total : 0.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primary, primary.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Seu progresso",
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  "$completed de $total tarefas concluídas",
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 13),
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
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
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                "${(progress * 100).toInt()}%",
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskItem(RoutineTaskModel task, int index, bool isDark, Color primary) {
    final taskColor = task.color != null ? Color(int.parse(task.color!)) : primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceEscuro : AppColors.surfaceClaro,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: task.isCompleted 
              ? Colors.transparent 
              : (isDark ? AppColors.borderEscuro : Colors.grey.shade200),
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
            color: task.isCompleted ? Colors.grey : null,
          ),
        ),
        subtitle: Text(
          task.time.format(context),
          style: TextStyle(color: Colors.grey.shade500),
        ),
        trailing: Transform.scale(
          scale: 1.2,
          child: Checkbox(
            value: task.isCompleted,
            onChanged: (_) => _toggleTask(index),
            shape: const CircleBorder(),
            activeColor: primary,
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

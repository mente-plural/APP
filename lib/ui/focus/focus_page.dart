import 'package:app/core/routine/routine_service.dart';
import 'package:app/models/routine_task_model.dart';
import 'package:app/shared/utils/responsive.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/providers/focus_provider.dart';
import '../../shared/widgets/page_header.dart';
import 'widgets/focus_card.dart';
import 'widgets/time_section.dart';

class TempoFocoPage extends StatefulWidget {
  const TempoFocoPage({super.key});

  @override
  State<TempoFocoPage> createState() => _TempoFocoPageState();
}

class _TempoFocoPageState extends State<TempoFocoPage> {
  void _showCompletionDialog(BuildContext context, FocusProvider focusProvider) {
    final task = focusProvider.selectedTask;
    if (task == null) return;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: AlertDialog(
            title: const Text("Sessão de Foco Concluída!"),
            content: Text("Você concluiu um ciclo de foco para '${task.title}'. Deseja marcar esta tarefa como concluída?"),
            actions: [
              TextButton(
                onPressed: () {
                  focusProvider.resetCompletionPrompt();
                  Navigator.pop(context);
                },
                child: const Text("Ainda não"),
              ),
              ElevatedButton(
                onPressed: () async {
                  final routineService = RoutineService();
                  await routineService.toggleTaskCompletion(task.id, true);
                  focusProvider.setSelectedTask(null);
                  focusProvider.resetCompletionPrompt();
                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text("Concluir Tarefa"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSettingsSheet(BuildContext context, FocusProvider focusProvider) {
    final theme = Theme.of(context);

    showModalBottomSheet(context: context,
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),),
      builder: (context) {
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: StatefulBuilder(builder: (context, setModalState) {
              return Container(padding: const EdgeInsets.all(24),
                child: Column(mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Configurar Cronômetro",
                      style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold),),
                    const SizedBox(height: 24),
                    _buildSettingSlider(context, label: "Tempo de Foco",
                      value: focusProvider.focusMinutes.toDouble(),
                      min: 1,
                      max: 60,
                      onChanged: (val) {
                        focusProvider.setFocusMinutes(val.toInt());
                        setModalState(() {});
                      },),
                    const SizedBox(height: 16),
                    _buildSettingSlider(context, label: "Pausa Curta",
                      value: focusProvider.shortBreakMinutes.toDouble(),
                      min: 1,
                      max: 15,
                      onChanged: (val) {
                        focusProvider.setShortBreakMinutes(val.toInt());
                        setModalState(() {});
                      },),
                    const SizedBox(height: 16),
                    _buildSettingSlider(context, label: "Pausa Longa",
                      value: focusProvider.longBreakMinutes.toDouble(),
                      min: 5,
                      max: 45,
                      onChanged: (val) {
                        focusProvider.setLongBreakMinutes(val.toInt());
                        setModalState(() {});
                      },),
                    const SizedBox(height: 24),
                    SizedBox(width: double.infinity,
                      child: ElevatedButton(onPressed: () => Navigator.pop(context),
                        child: const Text("Salvar Configurações"),),),
                  ],),);
            }),
          ),
        );
      },);
  }

  Widget _buildSettingSlider(BuildContext context,
      {required String label, required double value, required double min, required double max, required ValueChanged<double> onChanged}) {
    final theme = Theme.of(context);
    return Column(crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
            Text("${value.toInt()} min", style: TextStyle(
                color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
          ],),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: (max - min).toInt(),
          onChanged: onChanged,),
      ],);
  }

  void _showTaskSelectionSheet(BuildContext context, FocusProvider focusProvider) {
    final theme = Theme.of(context);
    final routineService = RoutineService();

    showModalBottomSheet(context: context,
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),),
      builder: (context) =>
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: StreamBuilder<List<RoutineTaskModel>>(
                stream: routineService.tasksStream,
                initialData: routineService.cachedTasks,
                builder: (context, snapshot) {
                  final tasks = snapshot.data ?? [];

                  return Container(padding: const EdgeInsets.all(24),
                    child: Column(mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Escolha seu foco",
                              style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold),),
                            IconButton(onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.close),),
                          ],),
                        const SizedBox(height: 16),
                        if (tasks.isEmpty)Padding(
                          padding: const EdgeInsets.symmetric(vertical: 32),
                          child: Center(child: Column(children: [
                            Icon(Icons.assignment_late_outlined, size: 48,
                                color: theme.disabledColor),
                            const SizedBox(height: 16),
                            const Text("Nenhuma tarefa encontrada para hoje."),
                          ],),),) else
                          Flexible(child: ListView.separated(shrinkWrap: true,
                            itemCount: tasks.length,
                            separatorBuilder: (_, v) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final task = tasks[index];
                              final isSelected = focusProvider.selectedTask?.id == task.id;

                              return InkWell(onTap: () {
                                focusProvider.setSelectedTask(task);
                                Navigator.pop(context);
                              },
                                borderRadius: BorderRadius.circular(16),
                                child: Container(padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: isSelected ? theme.colorScheme.primary.withValues(alpha:0.1) : theme.colorScheme.surface,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: isSelected ? theme.colorScheme.primary : theme.dividerColor.withValues(alpha:0.1)),),
                                  child: Row(children: [
                                    Icon(isSelected ? Icons.check_circle : Icons.circle_outlined, color: isSelected ? theme.colorScheme.primary : theme.disabledColor),
                                    const SizedBox(width: 12),
                                    Expanded(child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(task.title, style: TextStyle(
                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                          color: theme.colorScheme.onSurface,),),
                                        if (task.time.isNotEmpty)Text(task.time, style: theme.textTheme.bodySmall,),
                                      ],),),
                                  ],),),);
                            },),),
                        const SizedBox(height: 16),
                        if (focusProvider.selectedTask != null)SizedBox(
                          width: double.infinity, child: TextButton(onPressed: () {
                          focusProvider.setSelectedTask(null);
                          Navigator.pop(context);
                        }, child: const Text("Remover tarefa selecionada"),),),
                      ],),);
                },),
            ),
          ),);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final focusProvider = Provider.of<FocusProvider>(context);
    final horizontalPadding = context.responsiveSize(20.0, tabletSize: 40.0, desktopSize: 60.0);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (focusProvider.shouldShowCompletionPrompt) {
        _showCompletionDialog(context, focusProvider);
      }
    });

    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              PageHeader(
                title: "Tempo de Foco",
                actions: [
                  HeaderActionIcon(
                    icon: Icons.settings_outlined,
                    tooltip: 'Configurações',
                    iconColor: theme.colorScheme.primary,
                    onTap: () => _showSettingsSheet(context, focusProvider),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              const FocusCard(),
              const SizedBox(height: 32),
              const TimerSection(),
              const SizedBox(height: 32),
              _buildActionButtons(theme, focusProvider),
              const SizedBox(height: 24),
              _buildCurrentFocusCard(context, theme, focusProvider),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(ThemeData theme, FocusProvider focusProvider) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 60,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: theme.dividerColor.withValues(alpha:0.1)),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(onTap: () => focusProvider.resetTimer(),
              borderRadius: const BorderRadius.all(Radius.circular(30)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.refresh, color: theme.textTheme.bodyMedium?.color?.withValues(alpha:0.7), size: 24),
                  const SizedBox(width: 12),
                  Text(
                    "Recomeçar Tempo",
                    style: TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          height: 60,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(onTap: () => focusProvider.toggleTimer(),
              borderRadius: const BorderRadius.all(Radius.circular(30)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(focusProvider.isRunning ? Icons.pause : Icons.play_arrow,
                    color: theme.colorScheme.onPrimary, size: 28,),
                  const SizedBox(width: 8),
                  Text(focusProvider.isRunning ? "Pausar" : "Iniciar",
                    style: TextStyle(
                      color: theme.colorScheme.onPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentFocusCard(BuildContext context, ThemeData theme,
      FocusProvider focusProvider) {
    final hasTask = focusProvider.selectedTask != null;

    return InkWell(onTap: () => _showTaskSelectionSheet(context, focusProvider),
      borderRadius: BorderRadius.circular(20),
      child: Container(padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: hasTask ? theme.colorScheme.primary.withValues(alpha:0.5) : theme.dividerColor.withValues(alpha:0.1), width: hasTask ? 1.5 : 1),),
        child: Row(children: [
          Container(padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: theme.colorScheme.primary.withValues(alpha:0.1),
              borderRadius: BorderRadius.circular(14),),
            child: Icon(focusProvider.status == PomodoroStatus.focus ? Icons.menu_book_outlined : Icons.self_improvement,
              color: theme.colorScheme.primary, size: 24,),),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(focusProvider.status == PomodoroStatus.focus ? "FOCO ATUAL" : "STATUS", 
                style: TextStyle(color: theme.textTheme.bodyMedium?.color?.withValues(alpha:0.6),
                fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 1.2,),),
              const SizedBox(height: 4),
              Text(focusProvider.status == PomodoroStatus.focus ? (hasTask ? focusProvider.selectedTask!.title : "Toque para escolher uma tarefa") : "Hora de descansar",
                style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 18, fontWeight: FontWeight.w500,),
                maxLines: 1, overflow: TextOverflow.ellipsis,),
            ],),),
          Icon(Icons.chevron_right, color: theme.disabledColor),
        ],),
      ),
    );
  }
}

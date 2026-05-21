import 'package:flutter/material.dart';

class TaskSheet extends StatefulWidget {
  final TextEditingController titleCtrl;
  final TextEditingController descCtrl;
  final void Function(String title, String desc, String time, int priority) onSave;
  final bool isEditMode;
  final int initialHour;
  final int initialMinute;
  final bool initialIsPM;
  final int priority;

  const TaskSheet({
    super.key,
    required this.titleCtrl,
    required this.descCtrl,
    required this.onSave,
    this.isEditMode    = false,
    this.initialHour   = 8,
    this.initialMinute = 0,
    this.priority = 1,
    this.initialIsPM   = false,
  });

  @override
  State<TaskSheet> createState() => _TaskSheetState();
}

class _TaskSheetState extends State<TaskSheet> {
  late final FixedExtentScrollController _hourCtrl;
  late final FixedExtentScrollController _minCtrl;
  late int  _hour;
  late int  _minute;
  late int _priority;
  late bool _isPM;

  @override
  void initState() {
    super.initState();
    _hour   = widget.initialHour;
    _minute = widget.initialMinute;
    _isPM   = widget.initialIsPM;
    _priority = widget.priority;
    _hourCtrl = FixedExtentScrollController(initialItem: _hour - 1);
    _minCtrl  = FixedExtentScrollController(initialItem: _minute);
  }

  @override
  void dispose() {
    _hourCtrl.dispose();
    _minCtrl.dispose();
    super.dispose();
  }

  String get _time =>
      '${_hour.toString().padLeft(2, '0')}:${_minute.toString().padLeft(2, '0')} ${_isPM ? 'PM' : 'AM'}';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top:   BorderSide(color: theme.dividerColor),
          left:  BorderSide(color: theme.dividerColor),
          right: BorderSide(color: theme.dividerColor),
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                    color: theme.dividerColor,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const SizedBox(width: 12, height: 6),
                Text(
                  widget.isEditMode ? 'Editar Tarefa' : 'Nova Tarefa',
                  style: TextStyle(
                      color: theme.colorScheme.onSurface, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _Field(
              controller: widget.titleCtrl,
              label: 'Nome da tarefa',
              hint: 'Ex: Tomar medicação',
              icon: Icons.task_alt_rounded,
            ),
            const SizedBox(height: 20),
            Text(
              'HORÁRIO',
              style: TextStyle(
                  color: theme.textTheme.bodyMedium?.color?.withValues(
                      alpha: 0.7),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5),
            ),
            const SizedBox(height: 10),
            _buildTimePicker(theme),
            const SizedBox(height: 20),
            Text(
              'PRIORIDADE',
              style: TextStyle(
                  color: theme.textTheme.bodyMedium?.color?.withValues(
                      alpha: 0.7),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5),
            ),
            const SizedBox(height: 10),
            _buildPrioritySelector(theme),
            const SizedBox(height: 20),
            _Field(
              controller: widget.descCtrl,
              label: 'Descrição',
              hint: 'Breve nota sobre a tarefa...',
              icon: Icons.notes_rounded,
              maxLines: 2,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: theme.dividerColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: theme.dividerColor),
                      ),
                      child: Center(
                        child: Text('Cancelar',
                            style: TextStyle(
                                color: theme.textTheme.bodyMedium?.color, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () =>
                        widget.onSave(widget.titleCtrl.text, widget.descCtrl.text, _time, _priority),
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                          color: theme.colorScheme.primary, borderRadius: BorderRadius.circular(12)),
                      child: Center(
                        child: Text(
                          widget.isEditMode ? 'Salvar' : 'Adicionar',
                          style: TextStyle(
                              color: theme.colorScheme.onPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 15),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrioritySelector(ThemeData theme) {
    return Row(
      children: [1, 2, 3].map((p) {
        final isSel = _priority == p;
        final label = p == 1 ? 'Baixa' : p == 2 ? 'Média' : 'Alta';
        final color = p == 1 ? Colors.blue : p == 2 ? Colors.orange : Colors.red;
        
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _priority = p),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(
                right: p < 3 ? 8 : 0,
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSel ? color.withValues(alpha: 0.15) : theme
                    .dividerColor.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSel ? color : theme.dividerColor,
                  width: isSel ? 1.5 : 1,
                ),
              ),
              child: Center(
                child: Text(
                  label,
                  style: TextStyle(
                    color: isSel ? color : theme.textTheme.bodyMedium?.color
                        ?.withValues(alpha: 0.6),
                    fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTimePicker(ThemeData theme) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        children: [
          Expanded(child: _scrollCol(
            theme: theme,
            ctrl: _hourCtrl,
            count: 12,
            label: (i) => (i + 1).toString().padLeft(2, '0'),
            onChange: (i) => setState(() => _hour = i + 1),
          )),
          _vDivider(theme),
          Expanded(child: _scrollCol(
            theme: theme,
            ctrl: _minCtrl,
            count: 60,
            label: (i) => i.toString().padLeft(2, '0'),
            onChange: (i) => setState(() => _minute = i),
          )),
          _vDivider(theme),
          _amPm(theme),
        ],
      ),
    );
  }

  Widget _scrollCol({
    required ThemeData theme,
    required FixedExtentScrollController ctrl,
    required int count,
    required String Function(int) label,
    required void Function(int) onChange,
  }) {
    return ListWheelScrollView.useDelegate(
      controller: ctrl,
      itemExtent: 40,
      diameterRatio: 1.4,
      physics: const FixedExtentScrollPhysics(),
      onSelectedItemChanged: onChange,
      childDelegate: ListWheelChildBuilderDelegate(
        childCount: count,
        builder: (_, i) {
          final sel = ctrl.hasClients && ctrl.selectedItem == i;
          return Center(
            child: Text(
              label(i),
              style: TextStyle(
                color: sel ? theme.colorScheme.primary : theme.textTheme
                    .bodyMedium?.color?.withValues(alpha: 0.5),
                fontSize: sel ? 22 : 16,
                fontWeight: sel ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _amPm(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: ['AM', 'PM'].map((lbl) {
          final sel = (_isPM && lbl == 'PM') || (!_isPM && lbl == 'AM');
          return GestureDetector(
            onTap: () => setState(() => _isPM = lbl == 'PM'),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(vertical: 4),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: sel ? theme.colorScheme.primary : theme.dividerColor
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: sel ? theme.colorScheme.primary : theme.dividerColor),
              ),
              child: Text(lbl,
                  style: TextStyle(
                      color: sel ? theme.colorScheme.onPrimary : theme.textTheme.bodyMedium?.color,
                      fontWeight: FontWeight.bold,
                      fontSize: 13)),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _vDivider(ThemeData theme) => Container(width: 1, height: 60, color: theme.dividerColor);
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final int maxLines;

  const _Field({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                color: theme.textTheme.bodyMedium?.color?.withValues(
                    alpha: 0.7),
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5)),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.dividerColor),
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 14),
            cursorColor: theme.colorScheme.primary,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle:
              TextStyle(color: theme.textTheme.bodyMedium?.color?.withValues(
                  alpha: 0.4), fontSize: 14),
              prefixIcon: Icon(icon, color: theme.colorScheme.primary, size: 18),
              border: InputBorder.none,
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            ),
          ),
        ),
      ],
    );
  }
}

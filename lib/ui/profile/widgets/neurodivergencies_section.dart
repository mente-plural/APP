import 'package:flutter/material.dart';

class NeurodivergenciesSection extends StatelessWidget {
  final List<String> neurodivergencies;
  final bool isEditing;
  final List<String> availableOptions;
  final Function(String, bool)? onSelected;

  const NeurodivergenciesSection({
    super.key,
    required this.neurodivergencies,
    this.isEditing = false,
    this.availableOptions = const [],
    this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (isEditing) {
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: availableOptions.map((item) {
          final isSelected = neurodivergencies.contains(item);
          return FilterChip(
            label: Text(
              item,
              style: TextStyle(
                color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha:0.7),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            selected: isSelected,
            onSelected: (val) => onSelected?.call(item, val),
            backgroundColor: theme.colorScheme.surface,
            selectedColor: theme.colorScheme.primary.withValues(alpha:0.15),
            checkmarkColor: theme.colorScheme.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          );
        }).toList(),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: neurodivergencies
          .map((item) => _buildChip(theme, item))
          .toList(),
    );
  }

  Widget _buildChip(ThemeData theme, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha:0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.primary.withValues(alpha:0.35)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.primary,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class ProfileTypeSelector extends StatelessWidget {
  final String? selectedType;
  final Function(String) onTypeSelected;
  final List<Map<String, String>> options;

  const ProfileTypeSelector({
    super.key,
    required this.selectedType,
    required this.onTypeSelected,
    required this.options,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: options.map((type) {
        final isSelected = selectedType == type['value'];
        final isDevelopment = type['value'] != 'FOR_ME';
        
        return GestureDetector(
          onTap: isDevelopment ? null : () => onTypeSelected(type['value']!),
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? theme.colorScheme.primary.withValues(alpha:0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected
                    ? theme.colorScheme.primary
                    : (isDevelopment ? theme.dividerColor.withValues(alpha:0.3) : theme.dividerColor),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : (isDevelopment ? theme.dividerColor.withValues(alpha:0.3) : theme.dividerColor),
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    type['label']!,
                    style: TextStyle(color: isDevelopment ? theme.disabledColor : null),
                  ),
                ),
                if (isDevelopment)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha:0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "Em breve",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

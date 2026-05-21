import 'package:flutter/material.dart';

class SelectionCard extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isMulti;
  final bool clickable;
  final bool isDevelopment;

  const SelectionCard({
    super.key,
    required this.title,
    required this.isSelected,
    required this.onTap,
    this.isMulti = false,
    this.clickable = true,
    this.isDevelopment = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool effectiveClickable = clickable && !isDevelopment;
    
    return GestureDetector(
      onTap: effectiveClickable ? onTap : null,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: effectiveClickable ? 1.0 : (isDevelopment ? 0.6 : 0.2),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primary.withOpacity(0.1)
                : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.dividerColor.withOpacity(0.5),
              width: 2,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: isSelected ? theme.colorScheme.onSurface : theme.textTheme.bodyMedium?.color,
                        fontSize: 18,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (isDevelopment)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    "Em breve",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              if (isSelected)
                Icon(
                  isMulti ? Icons.check_box : Icons.check_circle,
                  color: theme.colorScheme.primary,
                ),
              if (!isSelected && isMulti && !isDevelopment)
                Icon(
                  Icons.check_box_outline_blank,
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

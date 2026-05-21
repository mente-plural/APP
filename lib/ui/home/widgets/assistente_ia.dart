import 'package:app/core/providers/navigation_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AssistenteIASection extends StatefulWidget {
  final ThemeData theme;

  const AssistenteIASection({super.key, required this.theme});

  @override
  State<AssistenteIASection> createState() => _AssistenteIASectionState();
}

class _AssistenteIASectionState extends State<AssistenteIASection> {
  @override
  void initState() {
    super.initState();
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
              "Assistente IA",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: widget.theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildTaskCard(context),
      ],
    );
  }

  Widget _buildTaskCard(BuildContext context) {
    return InkWell(
      onTap: () =>
          Provider.of<NavigationProvider>(context, listen: false).setIndex(2),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: widget.theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: widget.theme.dividerColor),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: widget.theme.scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.star,
                  color: widget.theme.colorScheme.primary,
                  size: 16,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Conversar com Assistente",
                      style: TextStyle(
                        color: widget.theme.colorScheme.onSurface,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Tire dúvidas ou peça ajuda com o foco",
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
                color: widget.theme.colorScheme.primary.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

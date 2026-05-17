import 'package:app/core/providers/navigation_provider.dart';
import 'package:app/ui/focus/widgets/focus_card.dart';
import 'package:app/ui/focus/widgets/time_section.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../shared/widgets/page_header.dart';

class TempoFocoPage extends StatelessWidget {
  const TempoFocoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildHeader(context, theme),
              const SizedBox(height: 32),
              _buildTopBadge(theme),
              const SizedBox(height: 16),
              Text(
                "Concentre-se em uma única tarefa por vez.",
                style: TextStyle(color: textTheme.bodyMedium?.color?.withValues(alpha: 0.7), fontSize: 15),
              ),
              const SizedBox(height: 24),
              const FocusCard(),
              const SizedBox(height: 40),
              const TimerSection(),
              const SizedBox(height: 40),
              _buildActionButtons(theme),
              const SizedBox(height: 24),
              _buildCurrentFocusCard(theme),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildHeader(BuildContext context, ThemeData theme) {
    return PageHeader(
      title: "Tempo de Foco"
    );
  }


  Widget _buildTopBadge(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.menu_book_outlined, color: theme.colorScheme.primary, size: 18),
          const SizedBox(width: 8),
          Text(
            "Sessão de Foco",
            style: TextStyle(
              color: theme.colorScheme.onSurface,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildActionButtons(ThemeData theme) {
    return Column(
      children: [

        Container(
          width: double.infinity,
          height: 60,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {},
              borderRadius: const BorderRadius.all(Radius.circular(30)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.refresh, color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7), size: 24),
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
            child: InkWell(
              onTap: () {},
              borderRadius: const BorderRadius.all(Radius.circular(30)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.play_arrow, color: theme.colorScheme.onPrimary, size: 28),
                  const SizedBox(width: 8),
                  Text(
                    "Iniciar",
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


  Widget _buildCurrentFocusCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.menu_book_outlined, color: theme.colorScheme.primary, size: 24),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "FOCO ATUAL",
                style: TextStyle(
                  color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Estudo e Leitura",
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}



class StepPomodoro extends StatelessWidget {
  final String number;
  final String label;
  final String time;
  final bool isActive;

  const StepPomodoro({
    super.key,
    required this.number,
    required this.label,
    required this.time,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Column(
      children: [
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            color: isActive ? primary : theme.colorScheme.surface,
            shape: BoxShape.circle,
            border: isActive ? null : Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
            boxShadow: isActive
                ? [BoxShadow(color: primary.withValues(alpha: 0.3), blurRadius: 15, spreadRadius: 2)]
                : null,
          ),
          child: Center(
            child: Text(
              number,
              style: TextStyle(
                color: isActive ? theme.colorScheme.onPrimary : theme.textTheme.bodyMedium?.color,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
 ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isActive ? primary : theme.textTheme.bodyMedium?.color,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          time,
          style: TextStyle(
            color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

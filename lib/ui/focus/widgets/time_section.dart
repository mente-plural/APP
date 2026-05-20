import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/focus_provider.dart';

class TimerSection extends StatelessWidget {
  const TimerSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final focusProvider = Provider.of<FocusProvider>(context);

    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 320,
          height: 320,
          child: CircularProgressIndicator(
            value: focusProvider.progress,
            strokeWidth: 8,
            backgroundColor: theme.dividerColor.withValues(alpha: 0.1),
            valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
          ),
        ),
        Text(
          focusProvider.timerString,
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontSize: 84,
            fontWeight: FontWeight.bold,
            letterSpacing: -2.0,
          ),
        ),
      ],
    );
  }
}

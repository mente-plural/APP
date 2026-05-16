
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../focus_page.dart';

class TimerSection extends StatelessWidget {
  const TimerSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 320,
      height: 320,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1), width: 6),
      ),
      child: Center(
        child: Text(
          "25:00",
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontSize: 84,
            fontWeight: FontWeight.bold,
            letterSpacing: -2.0,
          ),
        ),
      ),
    );
  }
}

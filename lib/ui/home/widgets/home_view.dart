import 'package:app/ui/home/widgets/proxima_rotina_section.dart';
import 'package:flutter/material.dart';
import 'home_header.dart';
import 'momento_foco.dart';
import 'dica_tdah_section.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const HomeHeader(),
            const SizedBox(height: 32),
            MomentoFocoCard(theme: theme),
            const SizedBox(height: 32),
            ProximoRotinaSection(theme: theme),
            const SizedBox(height: 32),
            DicaTdahSection(theme: theme),
          ],
        ),
      ),
    );
  }
}
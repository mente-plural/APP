import 'package:app/shared/utils/responsive.dart';
import 'package:app/ui/home/widgets/assistente_ia.dart';
import 'package:app/ui/home/widgets/proxima_rotina_section.dart';
import 'package:flutter/material.dart';

import 'dica_tdah_section.dart';
import 'home_header.dart';
import 'momento_foco.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    

    final horizontalPadding = context.responsiveSize(20.0, tabletSize: 40.0, desktopSize: 60.0);

    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: SingleChildScrollView(

          padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const HomeHeader(),
              const SizedBox(height: 24),


              MomentoFocoCard(theme: theme),
              const SizedBox(height: 24),
              AssistenteIASection(theme: theme),
              const SizedBox(height: 24),

              ProximoRotinaSection(theme: theme),
              const SizedBox(height: 24),
              
              DicaTdahSection(theme: theme),
              

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

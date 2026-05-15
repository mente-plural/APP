import 'package:app/ui/home/widgets/home_bottom_navigation.dart';
import 'package:app/ui/home/widgets/home_view.dart';
import 'package:flutter/material.dart';
import '../../ui/help/help_page.dart';
import '../../ui/focus/focus_page.dart';
import '../../ui/learn/learn_page.dart';
import '../../ui/routine/routine_page.dart';
import '../profile/profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomeView(),
    const RoutinePage(),
    const TempoFocoPage(),
    const LearnPage(),
    const ProfilePage(),
    const HelpPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: HomeBottomNavigation(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
import 'package:app/core/providers/navigation_provider.dart';
import 'package:app/ui/home/widgets/home_bottom_navigation.dart';
import 'package:app/ui/home/widgets/home_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../ui/focus/focus_page.dart';
import '../../ui/routine/routine_page.dart';
import '../chat/chat_page.dart';
import '../profile/profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Widget> _pages = [
    const HomeView(),
    const RoutinePage(),
    const ChatPage(),
    const TempoFocoPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final navProvider = Provider.of<NavigationProvider>(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: IndexedStack(
        index: navProvider.currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: HomeBottomNavigation(
        currentIndex: navProvider.currentIndex,
        onTap: (index) => navProvider.setIndex(index),
      ),
    );
  }
}

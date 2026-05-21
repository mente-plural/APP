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
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: IndexedStack(
              index: navProvider.currentIndex,
              children: _pages,
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          border: Border(
            top: BorderSide(
              color: theme.dividerColor.withOpacity(0.1),
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          child: Center(
            heightFactor: 1.0,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: HomeBottomNavigation(
                currentIndex: navProvider.currentIndex,
                onTap: (index) => navProvider.setIndex(index),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

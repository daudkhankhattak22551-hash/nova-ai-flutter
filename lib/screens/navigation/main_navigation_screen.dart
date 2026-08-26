import 'package:flutter/material.dart';
import '../../core/controllers/app_controller.dart';
import '../../widgets/navigation/bottom_navigation_bar.dart';
import '../home/home_screen.dart';
import '../chat/chat_screen.dart';
import '../history/history_screen.dart';
import '../profile/profile_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late final AppController _appController;

  @override
  void initState() {
    super.initState();
    _appController = AppController();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _appController,
      builder: (context, child) {
        return Scaffold(
          body: IndexedStack(
            index: _appController.currentIndex,
            children: const [
              HomeScreen(),
              ChatScreen(),
              HistoryScreen(),
              ProfileScreen(),
            ],
          ),
          bottomNavigationBar: NovaBottomNavigationBar(
            currentIndex: _appController.currentIndex,
            onTap: _appController.changeTab,
          ),
        );
      },
    );
  }
}

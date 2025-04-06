import 'package:flutter/material.dart';
import 'package:trackfi/features/dashboard/ui/dashboard_screen.dart';
import 'package:trackfi/shared/screens/wip_screen.dart';
import 'package:trackfi/shared/widgets/app_nav_bar.dart';

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    WorkInProgressScreen(label: 'Accounts'),
    WorkInProgressScreen(label: 'Analytics'),
    WorkInProgressScreen(label: 'Settings'),
  ];

  void _onTabSelected(int index) {
    if (_currentIndex != index) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: AppNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabSelected,
      ),
    );
  }
}

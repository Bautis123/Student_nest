import 'package:flutter/material.dart';
import 'landlord/dashboard_screen.dart';
import 'settings_screen.dart';

class LandlordMainScreen extends StatefulWidget {
  const LandlordMainScreen({super.key});

  @override
  State<LandlordMainScreen> createState() => _LandlordMainScreenState();
}

class _LandlordMainScreenState extends State<LandlordMainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final navTheme = Theme.of(context).bottomNavigationBarTheme;

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        selectedItemColor: navTheme.selectedItemColor,
        unselectedItemColor: navTheme.unselectedItemColor,
        backgroundColor: navTheme.backgroundColor,
        elevation: navTheme.elevation,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings_rounded),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

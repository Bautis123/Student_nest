import 'package:flutter/material.dart';
import '../utils/student_nest_icons.dart';
import '../utils/theme.dart';
import 'student/browse_screen.dart';
import 'settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [const BrowseScreen(), const SettingsScreen()];

  @override
  Widget build(BuildContext context) {
    final navTheme = Theme.of(context).bottomNavigationBarTheme;

    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 0, 16, 10),
        child: Container(
          height: 68,
          decoration: BoxDecoration(
            color: navTheme.backgroundColor ?? Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 14,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: _FloatingNavItem(
                  label: 'Home',
                  asset: StudentNestIcons.home,
                  selected: _currentIndex == 0,
                  selectedColor: navTheme.selectedItemColor ?? AppTheme.primary,
                  unselectedColor:
                      navTheme.unselectedItemColor ?? AppTheme.gray,
                  onTap: () => setState(() => _currentIndex = 0),
                ),
              ),
              Expanded(
                child: _FloatingNavItem(
                  label: 'Profile',
                  asset: StudentNestIcons.profile,
                  selected: _currentIndex == 1,
                  selectedColor: navTheme.selectedItemColor ?? AppTheme.primary,
                  unselectedColor:
                      navTheme.unselectedItemColor ?? AppTheme.gray,
                  onTap: () => setState(() => _currentIndex = 1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FloatingNavItem extends StatelessWidget {
  const _FloatingNavItem({
    required this.label,
    required this.asset,
    required this.selected,
    required this.selectedColor,
    required this.unselectedColor,
    required this.onTap,
  });

  final String label;
  final String asset;
  final bool selected;
  final Color selectedColor;
  final Color unselectedColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? selectedColor : unselectedColor;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: selected ? 34 : 30,
            height: selected ? 34 : 30,
            decoration: BoxDecoration(
              color: selected ? selectedColor : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: StudentNestIcon(
                asset,
                size: selected ? 17 : 20,
                color: selected ? Colors.white : color,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

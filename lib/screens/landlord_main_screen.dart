import 'package:flutter/material.dart';
import 'package:student_nest/core/theme/app_colors.dart';
import '../utils/student_nest_icons.dart';
import 'landlord/add_listing_screen.dart';
import 'landlord/dashboard_screen.dart';
import 'settings_screen.dart';

class LandlordMainScreen extends StatefulWidget {
  const LandlordMainScreen({super.key});

  @override
  State<LandlordMainScreen> createState() => _LandlordMainScreenState();
}

class _LandlordMainScreenState extends State<LandlordMainScreen> {
  int _currentIndex = 0;
  int _dashboardVersion = 0;

  Future<void> _openAddListing() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddListingScreen()),
    );
    if (!mounted) return;
    setState(() => _dashboardVersion++);
  }

  @override
  Widget build(BuildContext context) {
    final navTheme = Theme.of(context).bottomNavigationBarTheme;
    final screens = [
      DashboardScreen(
        key: ValueKey('home-$_dashboardVersion'),
        onAddListing: _openAddListing,
      ),
      DashboardScreen(
        key: ValueKey('listings-$_dashboardVersion'),
        listingsOnly: true,
      ),
      SettingsScreen(
        onOpenLandlordListings: () => setState(() => _currentIndex = 1),
      ),
    ];

    return Scaffold(
      extendBody: false,
      body: IndexedStack(index: _currentIndex, children: screens),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 0, 16, 10),
        child: Container(
          height: 68,
          decoration: BoxDecoration(
            color: navTheme.backgroundColor ?? AppDesign.surface(context),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
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
                  selectedColor: AppDesign.accent,
                  unselectedColor:
                      navTheme.unselectedItemColor ?? AppDesign.lightMuted,
                  onTap: () => setState(() => _currentIndex = 0),
                ),
              ),
              Expanded(
                child: _FloatingNavItem(
                  label: 'Listings',
                  asset: StudentNestIcons.building,
                  selected: _currentIndex == 1,
                  selectedColor: AppDesign.accent,
                  unselectedColor:
                      navTheme.unselectedItemColor ?? AppDesign.lightMuted,
                  onTap: () => setState(() => _currentIndex = 1),
                ),
              ),
              Expanded(
                child: _FloatingNavItem(
                  label: 'Profile',
                  asset: StudentNestIcons.profile,
                  selected: _currentIndex == 2,
                  selectedColor: AppDesign.accent,
                  unselectedColor:
                      navTheme.unselectedItemColor ?? AppDesign.lightMuted,
                  onTap: () => setState(() => _currentIndex = 2),
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

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/property.dart';
import 'package:student_nest/core/theme/app_colors.dart';
import '../utils/student_nest_icons.dart';
import 'main/campus_screen.dart';
import 'main/main_nav_item.dart';
import 'main/saved_listings_screen.dart';
import 'student/browse_screen.dart';
import 'settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  static const String _savedListingsKey = 'saved_listing_ids';

  int _currentIndex = 0;
  int _browseVersion = 0;
  Set<String> _savedPropertyIds = {};
  final Map<String, Property> _knownProperties = {};

  @override
  void initState() {
    super.initState();
    _loadSavedListings();
  }

  Future<void> _loadSavedListings() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _savedPropertyIds = prefs.getStringList(_savedListingsKey)?.toSet() ?? {};
    });
  }

  Future<void> _saveSavedListings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_savedListingsKey, _savedPropertyIds.toList());
  }

  void _rememberProperties(List<Property> properties) {
    var changed = false;
    for (final property in properties) {
      if (_knownProperties[property.id] != property) {
        _knownProperties[property.id] = property;
        changed = true;
      }
    }
    if (changed && mounted) {
      setState(() {});
    }
  }

  void _toggleSavedProperty(Property property, bool isSaved) {
    setState(() {
      _knownProperties[property.id] = property;
      if (isSaved) {
        _savedPropertyIds.add(property.id);
      } else {
        _savedPropertyIds.remove(property.id);
      }
    });
    _saveSavedListings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: false,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          BrowseScreen(
            key: ValueKey(_browseVersion),
            savedPropertyIds: _savedPropertyIds,
            onSavedToggle: _toggleSavedProperty,
            onPropertiesLoaded: _rememberProperties,
          ),
          const CampusScreen(),
          SavedListingsScreen(
            savedProperties: _savedPropertyIds
                .map((id) => _knownProperties[id])
                .whereType<Property>()
                .toList(growable: false),
            onSavedToggle: _toggleSavedProperty,
          ),
          SettingsScreen(
            onOpenSaved: () => setState(() => _currentIndex = 2),
            onOpenHome:
                () => setState(() {
                  _browseVersion++;
                  _currentIndex = 0;
                }),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 68,
          color: AppDesign.surface(context),
          child: Row(
            children: [
              _buildNavItem(
                label: 'Home',
                asset: StudentNestIcons.home,
                index: 0,
              ),
              _buildNavItem(
                label: 'Campus',
                asset: StudentNestIcons.university,
                index: 1,
              ),
              _buildNavItem(
                label: 'Saved',
                asset: StudentNestIcons.save,
                index: 2,
              ),
              _buildNavItem(
                label: 'Profile',
                asset: StudentNestIcons.profile,
                index: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required String label,
    required String asset,
    required int index,
  }) {
    return Expanded(
      child: MainNavItem(
        label: label,
        asset: asset,
        selected: _currentIndex == index,
        selectedColor: AppDesign.accent,
        unselectedColor: AppDesign.muted(context),
        onTap: () => setState(() => _currentIndex = index),
      ),
    );
  }
}

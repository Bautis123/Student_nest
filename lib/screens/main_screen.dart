import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/property.dart';
import '../utils/app_design.dart';
import '../utils/student_nest_icons.dart';
import '../widgets/property_card.dart';
import 'student/browse_screen.dart';
import 'student/property_detail_screen.dart';
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
          const _CampusScreen(),
          _SavedListingsScreen(
            savedProperties:
                _savedPropertyIds
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
      child: _FloatingNavItem(
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

class _SavedListingsScreen extends StatelessWidget {
  const _SavedListingsScreen({
    required this.savedProperties,
    required this.onSavedToggle,
  });

  final List<Property> savedProperties;
  final void Function(Property property, bool isSaved) onSavedToggle;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppDesign.page(context),
      appBar: AppBar(
        title: Text(
          'Saved',
          style: TextStyle(
            color: AppDesign.text(context),
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        backgroundColor: AppDesign.surface(context),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body:
          savedProperties.isEmpty
              ? const _SavedEmptyState()
              : ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                itemCount: savedProperties.length,
                itemBuilder: (context, index) {
                  final property = savedProperties[index];
                  return PropertyCard(
                    property: property,
                    isSaved: true,
                    onSavedChanged:
                        (isSaved) => onSavedToggle(property, isSaved),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) =>
                                  PropertyDetailScreen(propertyId: property.id),
                        ),
                      );
                    },
                  );
                },
              ),
    );
  }
}

class _SavedEmptyState extends StatelessWidget {
  const _SavedEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: AppDesign.accentTint(context),
                borderRadius: BorderRadius.circular(999),
              ),
              child: const StudentNestIcon(
                StudentNestIcons.save,
                color: AppDesign.accent,
                size: 28,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'No saved listings yet',
              style: TextStyle(
                color: AppDesign.text(context),
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Tap the bookmark on a boarding house to keep it here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppDesign.muted(context),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CampusScreen extends StatelessWidget {
  const _CampusScreen();

  static const _safetyGuide = _CampusGuide(
    title: 'Safety checklist',
    subtitle: 'Before paying',
    icon: StudentNestIcons.safety,
    intro: 'Use this before you send money or sign anything.',
    items: [
      'Visit the room in person or ask for a live video tour.',
      'Confirm the landlord or caretaker has authority to rent it out.',
      'Check locks, lighting, windows, and the route back from campus.',
      'Ask whether water, power, Wi-Fi, and security are included.',
      'Do not pay full rent before you have a receipt or written agreement.',
      'Save payment proof, landlord phone number, and property address.',
    ],
  );

  static const _budgetGuide = _CampusGuide(
    title: 'Budget planner',
    subtitle: 'Monthly costs',
    icon: StudentNestIcons.payment,
    intro: 'Plan beyond rent so the place stays affordable.',
    items: [
      'Rent per month',
      'Deposit or advance payment',
      'Transport to campus',
      'Food and groceries',
      'Utilities if not included',
      'Laundry, data, and emergency money',
    ],
  );

  static const _viewingGuide = _CampusGuide(
    title: 'Viewing day',
    subtitle: 'What to inspect',
    icon: StudentNestIcons.calendar,
    intro: 'A quick room viewing checklist.',
    items: [
      'Open taps and check water pressure.',
      'Test lights, sockets, and phone signal.',
      'Look for leaks, damp walls, and broken windows.',
      'Ask about curfew, visitors, cleaning, and noise rules.',
      'Check distance to transport and campus routes.',
    ],
  );

  static const _moveInGuide = _CampusGuide(
    title: 'Move-in kit',
    subtitle: 'Pack the essentials',
    icon: StudentNestIcons.room,
    intro: 'Small things that make the first week easier.',
    items: [
      'Bedding, towel, and toiletries',
      'Extension cable and charger',
      'Padlock or spare lock if allowed',
      'Basic plates, mug, and cutlery',
      'Cleaning cloth, soap, and bucket',
      'Printed or saved emergency contacts',
    ],
  );

  static const _transportGuide = _CampusGuide(
    title: 'Transport',
    subtitle: 'Daily movement',
    icon: StudentNestIcons.location,
    intro: 'Think about the daily trip, not only the room.',
    items: [
      'Estimate walking time to campus.',
      'Check taxi or bus availability early and late.',
      'Ask students nearby about regular transport costs.',
      'Avoid routes that feel unsafe after evening classes.',
    ],
  );

  void _showGuide(BuildContext context, _CampusGuide guide) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CampusGuideSheet(guide: guide),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppDesign.page(context),
      appBar: AppBar(
        title: Text(
          'Campus',
          style: TextStyle(
            color: AppDesign.text(context),
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        backgroundColor: AppDesign.surface(context),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: StudentNestIcon(
              StudentNestIcons.notifications,
              size: 21,
              color: AppDesign.text(context),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          const _CampusHeroCard(),
          const SizedBox(height: 16),
          _CampusQuickActions(
            guides: const [
              _safetyGuide,
              _viewingGuide,
              _moveInGuide,
              _transportGuide,
            ],
            onGuideTap: (guide) => _showGuide(context, guide),
          ),
          const SizedBox(height: 16),
          _CampusListRow(
            guide: _safetyGuide,
            onTap: () => _showGuide(context, _safetyGuide),
          ),
          const SizedBox(height: 10),
          _CampusListRow(
            guide: _budgetGuide,
            onTap: () => _showGuide(context, _budgetGuide),
          ),
        ],
      ),
    );
  }
}

class _CampusHeroCard extends StatelessWidget {
  const _CampusHeroCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: AppDesign.surfaceDecoration(context, radius: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppDesign.accentTint(context),
              borderRadius: BorderRadius.circular(999),
            ),
            child: StudentNestIcon(
              StudentNestIcons.university,
              size: 24,
              color: AppDesign.accent,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Student move-in hub',
            style: TextStyle(
              color: AppDesign.text(context),
              fontSize: 20,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Keep the practical stuff close: safety checks, budgeting, move-in prep, and daily transport before you commit.',
            style: TextStyle(
              color: AppDesign.muted(context),
              fontSize: 13,
              fontWeight: FontWeight.w500,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: const [
              _CampusStat(label: 'Ask', value: '8 checks'),
              SizedBox(width: 10),
              _CampusStat(label: 'Plan', value: 'Monthly'),
            ],
          ),
        ],
      ),
    );
  }
}

class _CampusStat extends StatelessWidget {
  const _CampusStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppDesign.page(context),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: AppDesign.muted(context),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              value,
              style: TextStyle(
                color: AppDesign.text(context),
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CampusQuickActions extends StatelessWidget {
  const _CampusQuickActions({required this.guides, required this.onGuideTap});

  final List<_CampusGuide> guides;
  final ValueChanged<_CampusGuide> onGuideTap;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children:
          guides
              .map(
                (guide) =>
                    _CampusChip(label: guide.title, onTap: () => onGuideTap(guide)),
              )
              .toList(growable: false),
    );
  }
}

class _CampusChip extends StatelessWidget {
  const _CampusChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppDesign.surface(context),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: AppDesign.border(context)),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: AppDesign.muted(context),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CampusListRow extends StatelessWidget {
  const _CampusListRow({required this.guide, required this.onTap});

  final _CampusGuide guide;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppDesign.surface(context),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppDesign.surface(context),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppDesign.shadow(context),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppDesign.accentTint(context),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: StudentNestIcon(
                  guide.icon,
                  size: 19,
                  color: AppDesign.accent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      guide.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppDesign.text(context),
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      guide.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppDesign.muted(context),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right_rounded,
                color:
                    AppDesign.subtle(context),
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
class _CampusGuide {
  const _CampusGuide({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.intro,
    required this.items,
  });

  final String title;
  final String subtitle;
  final String icon;
  final String intro;
  final List<String> items;
}

class _CampusGuideSheet extends StatelessWidget {
  const _CampusGuideSheet({required this.guide});

  final _CampusGuide guide;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.68,
      minChildSize: 0.38,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: AppDesign.surface(context),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppDesign.border(context),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppDesign.accentTint(context),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: StudentNestIcon(
                      guide.icon,
                      size: 22,
                      color: AppDesign.accent,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          guide.title,
                          style: TextStyle(
                            color: AppDesign.text(context),
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          guide.subtitle,
                          style: TextStyle(
                            color: AppDesign.muted(context),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                guide.intro,
                style: TextStyle(
                  color: AppDesign.muted(context),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 16),
              for (final item in guide.items) _CampusGuideItem(text: item),
            ],
          ),
        );
      },
    );
  }
}

class _CampusGuideItem extends StatelessWidget {
  const _CampusGuideItem({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            margin: const EdgeInsets.only(top: 1),
            decoration: BoxDecoration(
              color: AppDesign.accentTint(context),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Icon(
              Icons.check_rounded,
              color: AppDesign.accent,
              size: 15,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: AppDesign.text(context),
                fontSize: 13,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

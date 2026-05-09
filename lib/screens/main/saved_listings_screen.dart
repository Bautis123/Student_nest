import 'package:flutter/material.dart';
import 'package:student_nest/core/theme/app_colors.dart';
import 'package:student_nest/core/widgets/property_card.dart';

import '../../models/property.dart';
import '../../utils/student_nest_icons.dart';
import '../student/property_detail_screen.dart';

class SavedListingsScreen extends StatelessWidget {
  const SavedListingsScreen({
    super.key,
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
      body: savedProperties.isEmpty
          ? const _SavedEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              itemCount: savedProperties.length,
              itemBuilder: (context, index) {
                final property = savedProperties[index];
                return PropertyCard(
                  property: property,
                  isSaved: true,
                  onSavedChanged: (isSaved) => onSavedToggle(property, isSaved),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
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

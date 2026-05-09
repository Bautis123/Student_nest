import 'package:flutter/material.dart';
import 'package:student_nest/core/widgets/property_card.dart';
import 'package:student_nest/core/widgets/sn_loading_indicator.dart';

import '../../../models/property.dart';
import '../property_detail_screen.dart';
import 'browse_empty_state.dart';
import 'browse_error_state.dart';

class BrowseResultsSliver extends StatelessWidget {
  const BrowseResultsSliver({
    super.key,
    required this.isLoading,
    required this.error,
    required this.properties,
    required this.savedPropertyIds,
    required this.walkingDistanceByPropertyId,
    required this.onRetry,
    required this.onSavedToggle,
  });

  final bool isLoading;
  final String? error;
  final List<Property> properties;
  final Set<String> savedPropertyIds;
  final Map<String, double> walkingDistanceByPropertyId;
  final VoidCallback onRetry;
  final void Function(Property property, bool isSaved)? onSavedToggle;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SliverFillRemaining(child: SNLoadingIndicator());
    }

    final errorMessage = error;
    if (errorMessage != null) {
      return SliverFillRemaining(
        child: BrowseErrorState(message: errorMessage, onRetry: onRetry),
      );
    }

    if (properties.isEmpty) {
      return const SliverFillRemaining(child: BrowseEmptyState());
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 104),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final property = properties[index];
          return PropertyCard(
            key: ValueKey(property.id),
            property: property,
            isSaved: savedPropertyIds.contains(property.id),
            onSavedChanged: (isSaved) => onSavedToggle?.call(
              property,
              isSaved,
            ),
            displayDistanceKm: walkingDistanceByPropertyId[property.id],
            preferWalkingDistance: true,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PropertyDetailScreen(propertyId: property.id),
                ),
              );
            },
          );
        }, childCount: properties.length),
      ),
    );
  }
}

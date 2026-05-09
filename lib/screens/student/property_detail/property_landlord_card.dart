import 'package:flutter/material.dart';
import '../../../models/property.dart';
import 'package:student_nest/core/theme/app_colors.dart';
import 'package:student_nest/core/widgets/app_surface_card.dart';

class PropertyLandlordCard extends StatelessWidget {
  final Property property;

  const PropertyLandlordCard({super.key, required this.property});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppSurfaceCard(
      padding: const EdgeInsets.all(14),
      radius: 12,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppDesign.accentTint(context),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(Icons.person_outline, color: AppDesign.accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  property.landlordName ?? 'Landlord',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  property.landlordPhone ?? '',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppDesign.muted(context),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

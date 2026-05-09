import 'package:flutter/material.dart';

import 'package:student_nest/core/widgets/sn_card.dart';
import 'package:student_nest/models/property.dart';

class ListingRowItem extends StatelessWidget {
  const ListingRowItem({super.key, required this.listing, required this.onTap});

  final Property listing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SNCard(
      onTap: onTap,
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              listing.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const Icon(Icons.chevron_right_rounded),
        ],
      ),
    );
  }
}

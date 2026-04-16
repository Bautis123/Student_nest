import 'package:flutter/material.dart';
import '../../../utils/theme.dart';
import '../../../widgets/app_bottom_action_bar.dart';

class PropertyActionBar extends StatelessWidget {
  final VoidCallback onOpenMaps;
  final VoidCallback onOpenYango;
  final VoidCallback onCall;
  final String landlordName;

  const PropertyActionBar({
    super.key,
    required this.onOpenMaps,
    required this.onOpenYango,
    required this.onCall,
    required this.landlordName,
  });

  @override
  Widget build(BuildContext context) {
    return AppBottomActionBar(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      backgroundColor: AppTheme.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onOpenMaps,
                  icon: const Icon(Icons.map_outlined),
                  label: const Text('Open in Maps'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onOpenYango,
                  icon: const Icon(Icons.local_taxi_outlined),
                  label: const Text('Open in Yango'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onCall,
              icon: const Icon(Icons.phone_outlined),
              label: Text('Call $landlordName'),
            ),
          ),
        ],
      ),
    );
  }
}

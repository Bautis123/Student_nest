import 'package:flutter/material.dart';
import '../../../utils/theme.dart';
import '../../../widgets/app_bottom_action_bar.dart';

class PropertyActionBar extends StatelessWidget {
  final VoidCallback onViewMap;
  final VoidCallback onCall;
  final String landlordName;

  const PropertyActionBar({
    super.key,
    required this.onViewMap,
    required this.onCall,
    required this.landlordName,
  });

  @override
  Widget build(BuildContext context) {
    return AppBottomActionBar(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      backgroundColor: AppTheme.white,
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onViewMap,
              icon: const Icon(Icons.map_outlined),
              label: const Text('View in Map'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
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

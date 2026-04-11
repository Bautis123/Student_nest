import 'package:flutter/material.dart';
import '../../../utils/theme.dart';

class BrowseHeader extends StatelessWidget {
  final ValueChanged<String> onSearchChanged;

  const BrowseHeader({super.key, required this.onSearchChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.primary,
      padding: const EdgeInsets.fromLTRB(16, 60, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Student Nest',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(
            'Find boarding houses near UNZA',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 12),
          TextField(
            onChanged: onSearchChanged,
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Search by name or area...',
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
              prefixIcon: const Icon(Icons.search, size: 20),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

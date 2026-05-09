import 'package:flutter/material.dart';
import 'package:student_nest/core/theme/app_theme.dart';
import 'package:student_nest/core/widgets/app_bottom_action_bar.dart';
import 'package:student_nest/core/widgets/sn_button.dart';

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
      padding: EdgeInsets.fromLTRB(
        16,
        10,
        16,
        14 + MediaQuery.paddingOf(context).bottom,
      ),
      backgroundColor: Colors.white,
      withTopBorder: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: _RouteButton(
                  icon: Icons.map_outlined,
                  label: 'Open in\nMaps',
                  onTap: onOpenMaps,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _RouteButton(
                  icon: Icons.local_taxi_outlined,
                  label: 'Open in\nYango',
                  onTap: onOpenYango,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: SNButton(
              label: 'Call $landlordName',
              onPressed: onCall,
              leadingIcon: Icons.phone_outlined,
            ),
          ),
        ],
      ),
    );
  }
}

class _RouteButton extends StatelessWidget {
  const _RouteButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppTheme.dark, size: 21),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppTheme.dark,
                    fontSize: 12,
                    height: 1.22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

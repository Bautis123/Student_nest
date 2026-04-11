import 'package:flutter/material.dart';

class AuthMessageBanner extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String message;
  final String? title;
  final Widget? footer;

  const AuthMessageBanner({
    super.key,
    required this.icon,
    required this.color,
    required this.message,
    this.title,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null)
                  Text(
                    title!,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                if (title != null) const SizedBox(height: 4),
                Text(
                  message,
                  style: TextStyle(color: color, fontSize: 12, height: 1.4),
                ),
                if (footer != null) const SizedBox(height: 12),
                if (footer != null) footer!,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

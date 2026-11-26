import 'package:flutter/material.dart';
import 'package:student_nest/core/theme/app_colors.dart';

import '../../utils/student_nest_icons.dart';
import 'campus_guide.dart';

class CampusHeroCard extends StatelessWidget {
  const CampusHeroCard({super.key});

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
            child: const StudentNestIcon(
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
              fontSize: 15,
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
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              value,
              style: TextStyle(
                color: AppDesign.text(context),
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CampusQuickActions extends StatelessWidget {
  const CampusQuickActions({
    super.key,
    required this.guides,
    required this.onGuideTap,
  });

  final List<CampusGuide> guides;
  final ValueChanged<CampusGuide> onGuideTap;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: guides
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
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CampusListRow extends StatelessWidget {
  const CampusListRow({super.key, required this.guide, required this.onTap});

  final CampusGuide guide;
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
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right_rounded,
                color: AppDesign.subtle(context),
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

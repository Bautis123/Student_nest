import 'package:flutter/material.dart';
import '../../../../utils/theme.dart';
import 'plan_feature_tile.dart';

class PlanCard extends StatelessWidget {
  final String title;
  final String price;
  final String subtitle;
  final List<String> features;
  final bool isSelected;
  final bool isRecommended;
  final bool premium;
  final VoidCallback onTap;

  const PlanCard({
    super.key,
    required this.title,
    required this.price,
    required this.subtitle,
    required this.features,
    required this.isSelected,
    required this.isRecommended,
    required this.premium,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor =
        isSelected
            ? (premium ? const Color(0xFFF59E0B) : AppTheme.primary)
            : AppTheme.border;

    final bgColor =
        premium && isSelected ? const Color(0xFFFFFBEB) : Colors.white;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: borderColor, width: isSelected ? 2 : 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isRecommended) _recommendedTag(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _header()),
                const SizedBox(width: 12),
                _priceBlock(),
              ],
            ),
            const SizedBox(height: 16),
            ...features.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: PlanFeatureTile(text: item, premium: premium),
              ),
            ),
            const SizedBox(height: 6),
            _selectButton(),
          ],
        ),
      ),
    );
  }

  Widget _recommendedTag() {
    return Align(
      alignment: Alignment.topRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFFFBBF24),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text(
          'Recommended',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppTheme.dark,
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.dark,
              ),
            ),
            if (premium)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFFCD34D)),
                ),
                child: const Text(
                  'Premium badge',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFB45309),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 13,
            color: AppTheme.gray,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _priceBlock() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          price,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: premium ? AppTheme.success : AppTheme.dark,
          ),
        ),
        const Text(
          'per year',
          style: TextStyle(fontSize: 11, color: AppTheme.gray),
        ),
      ],
    );
  }

  Widget _selectButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 13),
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.primary : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? AppTheme.primary : AppTheme.border,
        ),
      ),
      child: Text(
        isSelected ? 'Selected' : 'Tap to choose',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: isSelected ? Colors.white : AppTheme.dark,
        ),
      ),
    );
  }
}


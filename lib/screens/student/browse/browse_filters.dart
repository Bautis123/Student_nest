import '../../../models/property.dart';

enum BrowseFilter {
  suggested('Suggested'),
  closest('Closest'),
  cheapest('Cheapest'),
  premiumOnly('Premium'),
  basicOnly('Basic');

  const BrowseFilter(this.label);
  final String label;
}

class BrowseFilterEngine {
  const BrowseFilterEngine._();

  static Set<BrowseFilter> normalizeSelectedFilters(Set<BrowseFilter> filters) {
    if (filters.isNotEmpty) return filters;
    return {BrowseFilter.suggested};
  }

  static String buildFiltersKey(Set<BrowseFilter> filters) {
    final ids = filters.map((f) => f.index).toList()..sort();
    return ids.join(',');
  }

  static List<Property> applyFilters({
    required List<Property> properties,
    required Set<BrowseFilter> selectedFilters,
    required Map<String, double> walkingDistanceByPropertyId,
  }) {
    var filtered = List<Property>.from(properties);

    final usePremiumOnly = selectedFilters.contains(BrowseFilter.premiumOnly);
    final useBasicOnly = selectedFilters.contains(BrowseFilter.basicOnly);
    if (usePremiumOnly && !useBasicOnly) {
      filtered = filtered.where((p) => p.isPremium).toList(growable: false);
    } else if (useBasicOnly && !usePremiumOnly) {
      filtered = filtered.where((p) => !p.isPremium).toList(growable: false);
    }

    final sortKeys = _buildSortKeys(filtered, walkingDistanceByPropertyId);
    if (filtered.length <= 1) return filtered;

    final hasRankingFilter =
        selectedFilters.contains(BrowseFilter.closest) ||
        selectedFilters.contains(BrowseFilter.cheapest);

    if (selectedFilters.contains(BrowseFilter.suggested)) {
      return _buildSuggestedOrder(filtered, sortKeys);
    }
    if (!hasRankingFilter) return filtered;

    final sorted = List<Property>.from(filtered);
    sorted.sort((a, b) {
      if (selectedFilters.contains(BrowseFilter.closest)) {
        final aDistance = sortKeys[a.id]?.distanceKm;
        final bDistance = sortKeys[b.id]?.distanceKm;
        if (aDistance != null || bDistance != null) {
          if (aDistance == null) return 1;
          if (bDistance == null) return -1;
          final distanceCompare = aDistance.compareTo(bDistance);
          if (distanceCompare != 0) return distanceCompare;
        }
      }

      if (selectedFilters.contains(BrowseFilter.cheapest)) {
        final aPrice = sortKeys[a.id]?.price;
        final bPrice = sortKeys[b.id]?.price;
        if (aPrice != null || bPrice != null) {
          if (aPrice == null) return 1;
          if (bPrice == null) return -1;
          final priceCompare = aPrice.compareTo(bPrice);
          if (priceCompare != 0) return priceCompare;
        }
      }

      return (sortKeys[b.id]?.views ?? 0).compareTo(sortKeys[a.id]?.views ?? 0);
    });

    return sorted;
  }

  static Map<String, _BrowseSortKey> _buildSortKeys(
    List<Property> properties,
    Map<String, double> walkingDistanceByPropertyId,
  ) {
    final keys = <String, _BrowseSortKey>{};
    for (final property in properties) {
      keys[property.id] = _BrowseSortKey(
        distanceKm:
            walkingDistanceByPropertyId[property.id] ??
            property.straightLineDistanceKm,
        price: property.minPrice,
        clicks: property.contactClickCount,
        views: property.viewCount,
      );
    }
    return keys;
  }

  static List<Property> _buildSuggestedOrder(
    List<Property> properties,
    Map<String, _BrowseSortKey> sortKeys,
  ) {
    if (properties.length <= 1) return properties;

    final remaining = List<Property>.from(properties);
    final ordered = <Property>[];

    void takeBest(
      bool Function(Property property) predicate,
      int Function(Property a, Property b) comparator,
    ) {
      final candidates = remaining.where(predicate).toList(growable: false);
      if (candidates.isEmpty) return;
      candidates.sort(comparator);
      final selected = candidates.first;
      ordered.add(selected);
      remaining.removeWhere((p) => p.id == selected.id);
    }

    takeBest(
      (p) => p.isPremium && sortKeys[p.id]?.distanceKm != null,
      (a, b) =>
          sortKeys[a.id]!.distanceKm!.compareTo(sortKeys[b.id]!.distanceKm!),
    );
    takeBest(
      (p) => !p.isPremium && sortKeys[p.id]?.distanceKm != null,
      (a, b) =>
          sortKeys[a.id]!.distanceKm!.compareTo(sortKeys[b.id]!.distanceKm!),
    );
    takeBest(
      (p) => p.isPremium && sortKeys[p.id]?.distanceKm != null,
      (a, b) =>
          sortKeys[b.id]!.distanceKm!.compareTo(sortKeys[a.id]!.distanceKm!),
    );
    takeBest((_) => true, (a, b) {
      final clickCompare = sortKeys[b.id]!.clicks.compareTo(
        sortKeys[a.id]!.clicks,
      );
      if (clickCompare != 0) return clickCompare;
      return sortKeys[b.id]!.views.compareTo(sortKeys[a.id]!.views);
    });
    takeBest(
      (p) => !p.isPremium && sortKeys[p.id]?.distanceKm != null,
      (a, b) =>
          sortKeys[b.id]!.distanceKm!.compareTo(sortKeys[a.id]!.distanceKm!),
    );

    remaining.sort((a, b) {
      final aDistance = sortKeys[a.id]?.distanceKm;
      final bDistance = sortKeys[b.id]?.distanceKm;
      if (aDistance == null && bDistance == null) {
        return sortKeys[b.id]!.clicks.compareTo(sortKeys[a.id]!.clicks);
      }
      if (aDistance == null) return 1;
      if (bDistance == null) return -1;
      return aDistance.compareTo(bDistance);
    });

    return [...ordered, ...remaining];
  }
}

class _BrowseSortKey {
  final double? distanceKm;
  final double? price;
  final int clicks;
  final int views;

  const _BrowseSortKey({
    required this.distanceKm,
    required this.price,
    required this.clicks,
    required this.views,
  });
}

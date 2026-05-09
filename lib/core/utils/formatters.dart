class Formatters {
  const Formatters._();

  static String currency(num value) {
    final rounded = value.round().toString();
    final buffer = StringBuffer();
    for (var i = 0; i < rounded.length; i++) {
      final remaining = rounded.length - i;
      buffer.write(rounded[i]);
      if (remaining > 1 && remaining % 3 == 1) buffer.write(',');
    }
    return 'K$buffer';
  }

  static String distance(double value) => '${value.toStringAsFixed(1)} km away';

  static String compactDistance(double value) =>
      '${value.toStringAsFixed(2)} km';

  static String monthPrice(num value) => '${currency(value)}/mo';

  static String coordinate(double value) => value.toStringAsFixed(6);

  static String schoolDistance({
    required double distanceKm,
    required String schoolName,
    required bool isWalking,
  }) {
    final distance = compactDistance(distanceKm);
    return isWalking
        ? '$distance walk to $schoolName'
        : '$distance from $schoolName';
  }

  static String sentenceCase(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return trimmed;
    return trimmed[0].toUpperCase() + trimmed.substring(1);
  }

  static String titleCaseWord(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1);
  }
}

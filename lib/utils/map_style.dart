class AppMapStyle {
  static const String boardingHouseMap = '''
[
  {
    "featureType": "poi",
    "stylers": [{"visibility": "off"}]
  },
  {
    "featureType": "poi.business",
    "stylers": [{"visibility": "off"}]
  },
  {
    "featureType": "transit",
    "stylers": [{"visibility": "off"}]
  },
  {
    "featureType": "road",
    "elementType": "geometry",
    "stylers": [{"color": "#e5e7eb"}]
  },
  {
    "featureType": "road",
    "elementType": "labels.icon",
    "stylers": [{"visibility": "off"}]
  },
  {
    "featureType": "administrative",
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#64748b"}]
  },
  {
    "featureType": "landscape",
    "elementType": "geometry",
    "stylers": [{"color": "#f8fafc"}]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [{"color": "#dbeafe"}]
  }
]
''';
}

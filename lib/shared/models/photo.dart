class Photo {
  final String id;
  final String propertyId;
  final String url;
  final bool isCover;

  Photo({
    required this.id,
    required this.propertyId,
    required this.url,
    required this.isCover,
  });

  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      id: json['id'],
      propertyId: json['property_id'],
      url: json['url'],
      isCover: json['is_cover'] ?? false,
    );
  }
}

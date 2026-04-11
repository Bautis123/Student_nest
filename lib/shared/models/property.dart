import 'room.dart';
import 'photo.dart';

class Property {
  final String id;
  final String landlordId;
  final String title;
  final String? description;
  final String address;
  final double latitude;
  final double longitude;
  final String? nearestSchoolId;
  final double? distanceFromSchool;
  final Map<String, dynamic> amenities;
  final bool isActive;
  final bool isApproved;
  final int viewCount;
  final int contactClickCount;
  final String? listingExpiresAt;
  final String createdAt;
  final String? schoolName;
  final String? landlordName;
  final String? landlordPhone;
  final List<Room> rooms;
  final List<Photo> photos;
  final double? minPrice;
  final double? maxPrice;
  final String? listingPlan;
  final bool? isPremiumFlag;

  Property({
    required this.id,
    required this.landlordId,
    required this.title,
    this.description,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.nearestSchoolId,
    this.distanceFromSchool,
    required this.amenities,
    required this.isActive,
    required this.isApproved,
    required this.viewCount,
    required this.contactClickCount,
    this.listingExpiresAt,
    required this.createdAt,
    this.schoolName,
    this.landlordName,
    this.landlordPhone,
    this.rooms = const [],
    this.photos = const [],
    this.minPrice,
    this.maxPrice,
    this.listingPlan,
    this.isPremiumFlag,
  });

  factory Property.fromJson(Map<String, dynamic> json) {
    return Property(
      id: json['id'],
      landlordId: json['landlord_id'],
      title: json['title'],
      description: json['description'],
      address: json['address'],
      latitude: double.parse(json['latitude'].toString()),
      longitude: double.parse(json['longitude'].toString()),
      nearestSchoolId: json['nearest_school_id'],
      distanceFromSchool:
          json['distance_from_school'] != null
              ? double.parse(json['distance_from_school'].toString())
              : null,
      amenities: json['amenities'] ?? {},
      isActive: json['is_active'] ?? true,
      isApproved: json['is_approved'] ?? false,
      viewCount: json['view_count'] ?? 0,
      contactClickCount: json['contact_click_count'] ?? 0,
      listingExpiresAt: json['listing_expires_at'],
      createdAt: json['created_at'],
      schoolName: json['school_name'],
      landlordName: json['landlord_name'],
      landlordPhone: json['landlord_phone'],
      rooms:
          json['rooms'] != null
              ? (json['rooms'] as List).map((r) => Room.fromJson(r)).toList()
              : [],
      photos:
          json['photos'] != null
              ? (json['photos'] as List).map((p) => Photo.fromJson(p)).toList()
              : [],
      minPrice:
          json['min_price'] != null
              ? double.parse(json['min_price'].toString())
              : null,
      maxPrice:
          json['max_price'] != null
              ? double.parse(json['max_price'].toString())
              : null,
      listingPlan:
          (json['listing_plan'] ?? json['plan'] ?? json['subscription_plan'])
              ?.toString(),
      isPremiumFlag:
          json['is_premium'] is bool
              ? json['is_premium'] as bool
              : (json['premium'] is bool ? json['premium'] as bool : null),
    );
  }

  bool get isPremium {
    if (isPremiumFlag != null) return isPremiumFlag!;
    final plan = listingPlan?.toLowerCase();
    return plan == 'premium';
  }
}

class Room {
  final String id;
  final String propertyId;
  final String roomType;
  final double pricePerMonth;
  final int studentsPerRoom;
  final int totalRooms;
  final int availableRooms;

  Room({
    required this.id,
    required this.propertyId,
    required this.roomType,
    required this.pricePerMonth,
    required this.studentsPerRoom,
    required this.totalRooms,
    required this.availableRooms,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id'],
      propertyId: json['property_id'],
      roomType: json['room_type'] ?? 'single',
      pricePerMonth: double.parse(json['price_per_month'].toString()),
      studentsPerRoom: json['students_per_room'] ?? 1,
      totalRooms: json['total_rooms'] ?? 1,
      availableRooms: json['available_rooms'] ?? 1,
    );
  }
}

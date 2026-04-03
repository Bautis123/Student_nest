class User {
  final String id;
  final String fullName;
  final String phone;
  final String? email;
  final String role;
  final bool isApproved;

  User({
    required this.id,
    required this.fullName,
    required this.phone,
    this.email,
    required this.role,
    required this.isApproved,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      fullName: json['full_name'],
      phone: json['phone'],
      email: json['email'],
      role: json['role'],
      isApproved: json['is_approved'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'phone': phone,
      'email': email,
      'role': role,
      'is_approved': isApproved,
    };
  }
}

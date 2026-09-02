/// Represents a record in public.user_profile
class UserProfile {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String role; // 'customer', 'worker', 'cooperative_admin'
  final String address;
  final String city;
  final String state;
  final String pincode;
  final String profileImage;
  final DateTime? createdAt;

  const UserProfile({
    required this.id,
    this.fullName = '',
    this.email = '',
    this.phone = '',
    this.role = 'customer',
    this.address = '',
    this.city = '',
    this.state = '',
    this.pincode = '',
    this.profileImage = '',
    this.createdAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String? ?? '',
      fullName: json['full_name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      role: json['role'] as String? ?? 'customer',
      address: json['address'] as String? ?? '',
      city: json['city'] as String? ?? '',
      state: json['state'] as String? ?? '',
      pincode: json['pincode'] as String? ?? '',
      profileImage: json['profile_image'] as String? ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'phone': phone,
      'role': role,
      'address': address,
      'city': city,
      'state': state,
      'pincode': pincode,
      'profile_image': profileImage,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }

  UserProfile copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phone,
    String? role,
    String? address,
    String? city,
    String? state,
    String? pincode,
    String? profileImage,
    DateTime? createdAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      pincode: pincode ?? this.pincode,
      profileImage: profileImage ?? this.profileImage,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

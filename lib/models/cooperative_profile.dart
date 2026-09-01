/// Represents a record in public.cooperative_profile
class CooperativeProfile {
  final String id;
  final String name;
  final String registrationNumber;
  final String type;
  final String email;
  final String phone;
  final String address;
  final String city;
  final String state;
  final String pincode;
  final String logoUrl;
  final DateTime? createdAt;

  const CooperativeProfile({
    required this.id,
    this.name = '',
    this.registrationNumber = '',
    this.type = '',
    this.email = '',
    this.phone = '',
    this.address = '',
    this.city = '',
    this.state = '',
    this.pincode = '',
    this.logoUrl = '',
    this.createdAt,
  });

  factory CooperativeProfile.fromJson(Map<String, dynamic> json) {
    return CooperativeProfile(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      registrationNumber: json['registration_number'] as String? ?? '',
      type: json['type'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      address: json['address'] as String? ?? '',
      city: json['city'] as String? ?? '',
      state: json['state'] as String? ?? '',
      pincode: json['pincode'] as String? ?? '',
      logoUrl: json['logo_url'] as String? ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'registration_number': registrationNumber,
      'type': type,
      'email': email,
      'phone': phone,
      'address': address,
      'city': city,
      'state': state,
      'pincode': pincode,
      'logo_url': logoUrl,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }

  CooperativeProfile copyWith({
    String? id,
    String? name,
    String? registrationNumber,
    String? type,
    String? email,
    String? phone,
    String? address,
    String? city,
    String? state,
    String? pincode,
    String? logoUrl,
    DateTime? createdAt,
  }) {
    return CooperativeProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      type: type ?? this.type,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      pincode: pincode ?? this.pincode,
      logoUrl: logoUrl ?? this.logoUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

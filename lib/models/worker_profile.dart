import '../theme/app_theme.dart';
import 'cooperative_profile.dart';
import 'user_profile.dart';
import 'worker.dart';

/// Represents a record in public.worker_profile
class WorkerProfile {
  final String id;
  final String userId;
  final String? cooperativeId;
  final String workerCode;
  final int experienceYears;
  final String address;
  final String city;
  final String state;
  final String pincode;
  final double? latitude;
  final double? longitude;

  final String verificationStatus;
  final String availabilityStatus;

  // New worker details
  final String emergencyContactName;
  final String emergencyContactPhone;
  final String serviceArea;
  final String workingArea;

  final DateTime? createdAt;

  // Joined relations
  final UserProfile? userProfile;
  final CooperativeProfile? cooperativeProfile;

  const WorkerProfile({
    required this.id,
    required this.userId,
    this.cooperativeId,
    this.workerCode = '',
    this.experienceYears = 0,
    this.address = '',
    this.city = '',
    this.state = '',
    this.pincode = '',
    this.latitude,
    this.longitude,
    this.verificationStatus = 'pending',
    this.availabilityStatus = 'available',

    // New fields
    this.emergencyContactName = '',
    this.emergencyContactPhone = '',
    this.serviceArea = '',
    this.workingArea = '',

    this.createdAt,
    this.userProfile,
    this.cooperativeProfile,
  });

  factory WorkerProfile.fromJson(Map<String, dynamic> json) {
    UserProfile? user;

    if (json['user_profile'] is Map<String, dynamic>) {
      user = UserProfile.fromJson(
        json['user_profile'] as Map<String, dynamic>,
      );
    }

    CooperativeProfile? coop;

    if (json['cooperative_profile'] is Map<String, dynamic>) {
      coop = CooperativeProfile.fromJson(
        json['cooperative_profile'] as Map<String, dynamic>,
      );
    }

    return WorkerProfile(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      cooperativeId: json['cooperative_id'] as String?,
      workerCode: json['worker_code'] as String? ?? '',

      experienceYears: json['experience_years'] is int
          ? json['experience_years'] as int
          : int.tryParse(
                json['experience_years']?.toString() ?? '0',
              ) ??
              0,

      address: json['address'] as String? ?? '',
      city: json['city'] as String? ?? '',
      state: json['state'] as String? ?? '',
      pincode: json['pincode'] as String? ?? '',

      latitude: json['latitude'] is num
          ? (json['latitude'] as num).toDouble()
          : double.tryParse(
              json['latitude']?.toString() ?? '',
            ),

      longitude: json['longitude'] is num
          ? (json['longitude'] as num).toDouble()
          : double.tryParse(
              json['longitude']?.toString() ?? '',
            ),

      verificationStatus:
          json['verification_status'] as String? ?? 'pending',

      availabilityStatus:
          json['availability_status'] as String? ?? 'available',

      // New fields
      emergencyContactName:
          json['emergency_contact_name'] as String? ?? '',

      emergencyContactPhone:
          json['emergency_contact_phone'] as String? ?? '',

      serviceArea:
          json['service_area'] as String? ?? '',

      workingArea:
          json['working_area'] as String? ?? '',

      createdAt: json['created_at'] != null
          ? DateTime.tryParse(
              json['created_at'].toString(),
            )
          : null,

      userProfile: user,
      cooperativeProfile: coop,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'cooperative_id': cooperativeId,
      'worker_code': workerCode,
      'experience_years': experienceYears,
      'address': address,
      'city': city,
      'state': state,
      'pincode': pincode,
      'latitude': latitude,
      'longitude': longitude,
      'verification_status': verificationStatus,
      'availability_status': availabilityStatus,

      // New fields
      'emergency_contact_name': emergencyContactName,
      'emergency_contact_phone': emergencyContactPhone,
      'service_area': serviceArea,
      'working_area': workingArea,

      if (createdAt != null)
        'created_at': createdAt!.toIso8601String(),
    };
  }

  WorkerProfile copyWith({
    String? id,
    String? userId,
    String? cooperativeId,
    String? workerCode,
    int? experienceYears,
    String? address,
    String? city,
    String? state,
    String? pincode,
    double? latitude,
    double? longitude,
    String? verificationStatus,
    String? availabilityStatus,

    // New fields
    String? emergencyContactName,
    String? emergencyContactPhone,
    String? serviceArea,
    String? workingArea,

    DateTime? createdAt,
    UserProfile? userProfile,
    CooperativeProfile? cooperativeProfile,
  }) {
    return WorkerProfile(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      cooperativeId: cooperativeId ?? this.cooperativeId,
      workerCode: workerCode ?? this.workerCode,
      experienceYears: experienceYears ?? this.experienceYears,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      pincode: pincode ?? this.pincode,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      verificationStatus:
          verificationStatus ?? this.verificationStatus,
      availabilityStatus:
          availabilityStatus ?? this.availabilityStatus,

      // New fields
      emergencyContactName:
          emergencyContactName ?? this.emergencyContactName,

      emergencyContactPhone:
          emergencyContactPhone ?? this.emergencyContactPhone,

      serviceArea:
          serviceArea ?? this.serviceArea,

      workingArea:
          workingArea ?? this.workingArea,

      createdAt: createdAt ?? this.createdAt,
      userProfile: userProfile ?? this.userProfile,
      cooperativeProfile:
          cooperativeProfile ?? this.cooperativeProfile,
    );
  }

  /// Converts this database WorkerProfile record to the existing UI Worker model.
  Worker toWorker({
    String? fallbackProfession,
    double rating = 4.8,
    int reviews = 42,
    int jobsCompleted = 24,
    double pricePerHour = 350,
    List<String>? skills,
  }) {
    final name = userProfile?.fullName.isNotEmpty == true
        ? userProfile!.fullName
        : (workerCode.isNotEmpty
            ? 'Worker $workerCode'
            : 'Worker');

    final initials = name
        .trim()
        .split(' ')
        .map(
          (p) => p.isNotEmpty ? p[0] : '',
        )
        .take(2)
        .join()
        .toUpperCase();

    final isVerified =
        verificationStatus.toLowerCase() == 'verified';

    final isAvailable =
        availabilityStatus.toLowerCase() == 'available' ||
        availabilityStatus.toLowerCase() == 'on_duty';

    final coopName =
        cooperativeProfile?.name ?? '';

    final locationName =
        city.isNotEmpty
            ? city
            : (userProfile?.city ?? 'Mumbai');

    final localityName =
        address.isNotEmpty
            ? address
            : (userProfile?.address ?? 'Grant Road');

    return Worker(
      id: id,
      name: name,
      profession:
          fallbackProfession ?? 'Service Professional',
      location: locationName,
      locality: localityName,
      rating: rating,
      reviews: reviews,
      jobsCompleted: jobsCompleted,
      distanceKm: 1.5,
      pricePerHour: pricePerHour,
      avatarInitials:
          initials.isNotEmpty ? initials : 'WK',
      color: AppColors.primary,
      skills: skills ??
          const [
            'General Repair',
            'Maintenance',
          ],
      experience:
          '$experienceYears years',
      description:
          'Verified cooperative professional affiliated with '
          '$coopName with $experienceYears years of field experience.',
      cooperative: coopName,
      verified: isVerified,
      skillVerified: isVerified,
      available: isAvailable,
    );
  }
}
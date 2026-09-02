import '../data/mock_models.dart';
import '../theme/app_theme.dart';
import 'user_profile.dart';
import 'worker_profile.dart';

/// Represents a record in public.jobs
class Job {
  final String id;
  final String? workerId;
  final String customerId;
  final String jobTitle;
  final String description;
  final String status; // 'pending', 'accepted', 'in_progress', 'completed', 'cancelled'
  final DateTime? scheduledAt;
  final DateTime? completedAt;
  final double amount;
  final DateTime? createdAt;

  // Joined relations
  final WorkerProfile? workerProfile;
  final UserProfile? customerProfile;

  const Job({
    required this.id,
    this.workerId,
    required this.customerId,
    this.jobTitle = '',
    this.description = '',
    this.status = 'pending',
    this.scheduledAt,
    this.completedAt,
    this.amount = 0.0,
    this.createdAt,
    this.workerProfile,
    this.customerProfile,
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    WorkerProfile? worker;
    if (json['worker_profile'] is Map<String, dynamic>) {
      worker = WorkerProfile.fromJson(
        json['worker_profile'] as Map<String, dynamic>,
      );
    }

    UserProfile? customer;
    if (json['customer_profile'] is Map<String, dynamic>) {
      customer = UserProfile.fromJson(
        json['customer_profile'] as Map<String, dynamic>,
      );
    }

    return Job(
      id: json['id'] as String? ?? '',
      workerId: json['worker_id'] as String?,
      customerId: json['customer_id'] as String? ?? '',
      jobTitle: json['job_title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      scheduledAt: json['scheduled_at'] != null
          ? DateTime.tryParse(json['scheduled_at'].toString())
          : null,
      completedAt: json['completed_at'] != null
          ? DateTime.tryParse(json['completed_at'].toString())
          : null,
      amount: json['amount'] is num
          ? (json['amount'] as num).toDouble()
          : double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      workerProfile: worker,
      customerProfile: customer,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (workerId != null) 'worker_id': workerId,
      'customer_id': customerId,
      'job_title': jobTitle,
      'description': description,
      'status': status,
      if (scheduledAt != null) 'scheduled_at': scheduledAt!.toIso8601String(),
      if (completedAt != null) 'completed_at': completedAt!.toIso8601String(),
      'amount': amount,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }

  Job copyWith({
    String? id,
    String? workerId,
    String? customerId,
    String? jobTitle,
    String? description,
    String? status,
    DateTime? scheduledAt,
    DateTime? completedAt,
    double? amount,
    DateTime? createdAt,
    WorkerProfile? workerProfile,
    UserProfile? customerProfile,
  }) {
    return Job(
      id: id ?? this.id,
      workerId: workerId ?? this.workerId,
      customerId: customerId ?? this.customerId,
      jobTitle: jobTitle ?? this.jobTitle,
      description: description ?? this.description,
      status: status ?? this.status,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      completedAt: completedAt ?? this.completedAt,
      amount: amount ?? this.amount,
      createdAt: createdAt ?? this.createdAt,
      workerProfile: workerProfile ?? this.workerProfile,
      customerProfile: customerProfile ?? this.customerProfile,
    );
  }

  /// Converts Job record to existing Booking UI model
  Booking toBooking() {
    final workerName = workerProfile?.userProfile?.fullName.isNotEmpty == true
        ? workerProfile!.userProfile!.fullName
        : 'Assigned Worker';

    final initials = workerName.trim().split(' ').map((p) => p.isNotEmpty ? p[0] : '').take(2).join().toUpperCase();

    final dateVal = scheduledAt ?? createdAt ?? DateTime.now();

    return Booking(
      id: id,
      workerName: workerName,
      profession: jobTitle.isNotEmpty ? jobTitle : 'Services',
      status: _mapStatusToBookingStatus(status),
      date: dateVal,
      timeSlot: scheduledAt != null
          ? '${scheduledAt!.hour.toString().padLeft(2, '0')}:${scheduledAt!.minute.toString().padLeft(2, '0')}'
          : 'Scheduled',
      address: customerProfile?.address ?? 'Customer Location',
      amount: amount,
      paymentStatus: status == 'completed' ? 'paid' : 'pending',
      avatarInitials: initials.isNotEmpty ? initials : 'WK',
      color: AppColors.primary,
    );
  }

  /// Converts Job record to existing UserRequest UI model
  UserRequest toUserRequest() {
    final dateVal = scheduledAt ?? createdAt ?? DateTime.now();
    final workerName = workerProfile?.userProfile?.fullName ?? '';

    return UserRequest(
      id: id,
      service: jobTitle.isNotEmpty ? jobTitle : 'Service Request',
      status: _mapStatusToUserRequestStatus(status),
      date: '${dateVal.day.toString().padLeft(2, '0')} ${_monthShort(dateVal.month)} ${dateVal.year}',
      description: description,
      workerName: workerName,
    );
  }

  static String _mapStatusToBookingStatus(String status) {
    switch (status.toLowerCase()) {
      case 'in_progress':
        return 'active';
      case 'accepted':
        return 'confirmed';
      case 'completed':
        return 'completed';
      case 'cancelled':
        return 'cancelled';
      case 'pending':
      default:
        return 'pending';
    }
  }

  static String _mapStatusToUserRequestStatus(String status) {
    switch (status.toLowerCase()) {
      case 'in_progress':
        return 'In Progress';
      case 'accepted':
        return 'Matched';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      case 'pending':
      default:
        return 'Pending';
    }
  }

  static String _monthShort(int m) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return (m >= 1 && m <= 12) ? months[m - 1] : '';
  }
}

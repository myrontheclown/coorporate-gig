/// Represents a record in public.reviews
class Review {
  final String id;
  final String customerId;
  final String? workerId;
  final int rating;
  final String comment;
  final bool tipWorker;
  final DateTime? createdAt;

  const Review({
    required this.id,
    required this.customerId,
    this.workerId,
    required this.rating,
    this.comment = '',
    this.tipWorker = false,
    this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] as String? ?? '',
      customerId: json['customer_id'] as String? ?? '',
      workerId: json['worker_id'] as String?,
      rating: json['rating'] as int? ?? 0,
      comment: json['comment'] as String? ?? '',
      tipWorker: json['tip_worker'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_id': customerId,
      if (workerId != null) 'worker_id': workerId,
      'rating': rating,
      'comment': comment,
      'tip_worker': tipWorker,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }

  Review copyWith({
    String? id,
    String? customerId,
    String? workerId,
    bool clearWorkerId = false,
    int? rating,
    String? comment,
    bool? tipWorker,
    DateTime? createdAt,
  }) {
    return Review(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      workerId: clearWorkerId ? null : (workerId ?? this.workerId),
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      tipWorker: tipWorker ?? this.tipWorker,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

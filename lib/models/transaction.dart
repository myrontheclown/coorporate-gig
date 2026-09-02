/// Represents a record in public.transactions
class Transaction {
  final String id;
  final String? jobId;
  final String customerId;
  final String? workerId;
  final double amount;
  final String paymentMethod;
  final String status;
  final String transactionReference;
  final DateTime? createdAt;

  const Transaction({
    required this.id,
    this.jobId,
    required this.customerId,
    this.workerId,
    this.amount = 0.0,
    this.paymentMethod = 'UPI',
    this.status = 'completed',
    this.transactionReference = '',
    this.createdAt,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as String? ?? '',
      jobId: json['job_id'] as String?,
      customerId: json['customer_id'] as String? ?? '',
      workerId: json['worker_id'] as String?,
      amount: json['amount'] is num
          ? (json['amount'] as num).toDouble()
          : double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
      paymentMethod: json['payment_method'] as String? ?? 'UPI',
      status: json['status'] as String? ?? 'completed',
      transactionReference: json['transaction_reference'] as String? ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (jobId != null) 'job_id': jobId,
      'customer_id': customerId,
      if (workerId != null) 'worker_id': workerId,
      'amount': amount,
      'payment_method': paymentMethod,
      'status': status,
      'transaction_reference': transactionReference,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }

  Transaction copyWith({
    String? id,
    String? jobId,
    String? customerId,
    String? workerId,
    double? amount,
    String? paymentMethod,
    String? status,
    String? transactionReference,
    DateTime? createdAt,
  }) {
    return Transaction(
      id: id ?? this.id,
      jobId: jobId ?? this.jobId,
      customerId: customerId ?? this.customerId,
      workerId: workerId ?? this.workerId,
      amount: amount ?? this.amount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      transactionReference: transactionReference ?? this.transactionReference,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

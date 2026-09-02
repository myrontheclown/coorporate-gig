import 'package:flutter/foundation.dart';
import '../models/review.dart';
import 'supabase_service.dart';

class ReviewService {
  static const String _tableName = 'reviews';

  /// Creates a new review record.
  static Future<Review?> createReview(Review review) async {
    if (!SupabaseService.isReady) return null;

    try {
      final data = review.toJson();
      if (data['id'] == null || (data['id'] as String).isEmpty) {
        data.remove('id'); // Let Supabase generate UUID default
      }

      final response = await SupabaseService.client!
          .from(_tableName)
          .insert(data)
          .select()
          .single();

      return Review.fromJson(response);
    } catch (e, stack) {
      if (kDebugMode) {
        print('⚠️ [ReviewService.createReview] Error: $e\n$stack');
      }
      return null;
    }
  }

  /// Retrieves all reviews for a specific worker.
  static Future<List<Review>> getReviewsForWorker(String workerId) async {
    if (!SupabaseService.isReady || workerId.isEmpty) return [];

    try {
      final response = await SupabaseService.client!
          .from(_tableName)
          .select()
          .eq('worker_id', workerId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => Review.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e, stack) {
      if (kDebugMode) {
        print('⚠️ [ReviewService.getReviewsForWorker] Error: $e\n$stack');
      }
      return [];
    }
  }

  /// Retrieves all reviews by a specific customer.
  static Future<List<Review>> getReviewsByCustomer(String customerId) async {
    if (!SupabaseService.isReady || customerId.isEmpty) return [];

    try {
      final response = await SupabaseService.client!
          .from(_tableName)
          .select()
          .eq('customer_id', customerId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => Review.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e, stack) {
      if (kDebugMode) {
        print('⚠️ [ReviewService.getReviewsByCustomer] Error: $e\n$stack');
      }
      return [];
    }
  }
}

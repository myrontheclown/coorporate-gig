import 'package:flutter/foundation.dart';
import '../models/transaction.dart';
import 'supabase_service.dart';

class TransactionService {
  static const String _tableName = 'transactions';

  /// Retrieves transaction history for a specific customer.
  static Future<List<Transaction>> getTransactionsForCustomer(String customerId) async {
    if (!SupabaseService.isReady || customerId.isEmpty) return [];

    try {
      final response = await SupabaseService.client!
          .from(_tableName)
          .select()
          .eq('customer_id', customerId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => Transaction.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e, stack) {
      if (kDebugMode) {
        print('⚠️ [TransactionService.getTransactionsForCustomer] Error: $e\n$stack');
      }
      return [];
    }
  }

  /// Retrieves transaction history for a specific worker.
  static Future<List<Transaction>> getTransactionsForWorker(String workerId) async {
    if (!SupabaseService.isReady || workerId.isEmpty) return [];

    try {
      final response = await SupabaseService.client!
          .from(_tableName)
          .select()
          .eq('worker_id', workerId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => Transaction.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e, stack) {
      if (kDebugMode) {
        print('⚠️ [TransactionService.getTransactionsForWorker] Error: $e\n$stack');
      }
      return [];
    }
  }

  /// Retrieves all transactions (Admin view).
  static Future<List<Transaction>> getAllTransactions() async {
    if (!SupabaseService.isReady) return [];

    try {
      final response = await SupabaseService.client!
          .from(_tableName)
          .select()
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => Transaction.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e, stack) {
      if (kDebugMode) {
        print('⚠️ [TransactionService.getAllTransactions] Error: $e\n$stack');
      }
      return [];
    }
  }

  /// Creates a new transaction record.
  static Future<Transaction?> createTransaction(Transaction transaction) async {
    if (!SupabaseService.isReady) return null;

    try {
      final data = transaction.toJson();
      if (data['id'] == null || (data['id'] as String).isEmpty) {
        data.remove('id'); // Let Supabase generate UUID default if empty
      }

      final response = await SupabaseService.client!
          .from(_tableName)
          .insert(data)
          .select()
          .single();

      return Transaction.fromJson(response);
    } catch (e, stack) {
      if (kDebugMode) {
        print('⚠️ [TransactionService.createTransaction] Error: $e\n$stack');
      }
      return null;
    }
  }
}

import 'package:flutter/foundation.dart';
import '../models/cooperative_profile.dart';
import 'supabase_service.dart';

class CooperativeService {
  static const String _tableName = 'cooperative_profile';

  /// Retrieves all cooperative profiles.
  static Future<List<CooperativeProfile>> getCooperatives() async {
    if (!SupabaseService.isReady) return [];

    try {
      final response = await SupabaseService.client!
          .from(_tableName)
          .select()
          .order('name', ascending: true);

      return (response as List)
          .map((json) => CooperativeProfile.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e, stack) {
      if (kDebugMode) {
        print('⚠️ [CooperativeService.getCooperatives] Error: $e\n$stack');
      }
      return [];
    }
  }

  /// Retrieves a single cooperative profile by id.
  static Future<CooperativeProfile?> getCooperativeById(String coopId) async {
    if (!SupabaseService.isReady || coopId.isEmpty) return null;

    try {
      final response = await SupabaseService.client!
          .from(_tableName)
          .select()
          .eq('id', coopId)
          .maybeSingle();

      if (response == null) return null;
      return CooperativeProfile.fromJson(response);
    } catch (e, stack) {
      if (kDebugMode) {
        print('⚠️ [CooperativeService.getCooperativeById] Error: $e\n$stack');
      }
      return null;
    }
  }
}

import 'package:flutter/foundation.dart';
import '../models/user_profile.dart';
import 'supabase_service.dart';

class UserProfileService {
  static const String _tableName = 'user_profile';

  /// Retrieves a user profile by user UUID.
  static Future<UserProfile?> getProfile(String userId) async {
    if (!SupabaseService.isReady || userId.isEmpty) return null;

    try {
      final response = await SupabaseService.client!
          .from(_tableName)
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response == null) return null;
      return UserProfile.fromJson(response);
    } catch (e, stack) {
      if (kDebugMode) {
        print('⚠️ [UserProfileService.getProfile] Error: $e\n$stack');
      }
      return null;
    }
  }

  /// Creates a new user profile record in public.user_profile.
  static Future<UserProfile?> createProfile(UserProfile profile) async {
    if (!SupabaseService.isReady) return null;

    try {
      final response = await SupabaseService.client!
          .from(_tableName)
          .insert(profile.toJson())
          .select()
          .single();

      return UserProfile.fromJson(response);
    } catch (e, stack) {
      if (kDebugMode) {
        print('⚠️ [UserProfileService.createProfile] Error: $e\n$stack');
      }
      return null;
    }
  }

  /// Updates an existing user profile.
  static Future<UserProfile?> updateProfile(UserProfile profile) async {
    if (!SupabaseService.isReady || profile.id.isEmpty) return null;

    try {
      final data = profile.toJson();
      data.remove('id'); // Do not update primary key

      final response = await SupabaseService.client!
          .from(_tableName)
          .update(data)
          .eq('id', profile.id)
          .select()
          .single();

      return UserProfile.fromJson(response);
    } catch (e, stack) {
      if (kDebugMode) {
        print('⚠️ [UserProfileService.updateProfile] Error: $e\n$stack');
      }
      return null;
    }
  }
}

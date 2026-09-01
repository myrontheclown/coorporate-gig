import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

/// Core Supabase service wrapper ensuring safe client access and error resilience.
class SupabaseService {
  static bool _initialized = false;
  static bool get isInitialized => _initialized;

  /// Initializes Supabase if configured. Fails safely if offline or unconfigured.
  static Future<void> initialize() async {
    if (!SupabaseConfig.isConfigured) {
      if (kDebugMode) {
        print(
          'ℹ️ [SupabaseService] Running in fallback/offline mode (no custom SUPABASE_URL / SUPABASE_ANON_KEY provided).',
        );
      }
      return;
    }

    try {
      await Supabase.initialize(
        url: SupabaseConfig.supabaseUrl,
        // ignore: deprecated_member_use
        anonKey: SupabaseConfig.supabaseAnonKey,
      );
      _initialized = true;
      if (kDebugMode) {
        print('✅ [SupabaseService] Supabase initialized successfully.');
      }
    } catch (e, stack) {
      _initialized = false;
      if (kDebugMode) {
        print('⚠️ [SupabaseService] Failed to initialize Supabase: $e\n$stack');
      }
    }
  }

  /// Safe getter for Supabase client. Returns null if not initialized.
  static SupabaseClient? get client {
    if (!_initialized) return null;
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  /// Checks if Supabase client is active and available.
  static bool get isReady => _initialized && client != null;
}

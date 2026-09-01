/// Configuration for Supabase client connection.
///
/// Values can be supplied at build/run time via:
/// `--dart-define=SUPABASE_URL=https://your-project.supabase.co`
/// `--dart-define=SUPABASE_ANON_KEY=your-anon-key`
class SupabaseConfig {
  static const String supabaseUrl = String.fromEnvironment(
    'https://tldmhpescgkjrsjbtphd.supabase.co',
    defaultValue: 'https://placeholder.supabase.co',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRsZG1ocGVzY2dranJzamJ0cGhkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODgyMjc0NjgsImV4cCI6MjEwMzgwMzQ2OH0.HQDMuKNkzyN_lQUfYAZamCtkgy-YyCcPc55bPf3YmxA',
    defaultValue: 'placeholder-anon-key',
  );

  /// Checks if Supabase has been supplied with non-placeholder configuration.
  static bool get isConfigured {
    return supabaseUrl.isNotEmpty &&
        !supabaseUrl.contains('placeholder.supabase.co') &&
        supabaseAnonKey.isNotEmpty &&
        supabaseAnonKey != 'placeholder-anon-key';
  }
}

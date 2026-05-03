/// Supabase project configuration.
///
/// Project ref: `euxzifpvelqwqhbudppt` (from `.mcp.json` at repo root).
/// TODO(secrets): replace these placeholders with the real values from the
/// Supabase dashboard before running on a device:
///   Settings → API → Project URL
///   Settings → API → Project API keys → anon / public
class SupabaseConfig {
  SupabaseConfig._();

  static const String url = 'https://euxzifpvelqwqhbudppt.supabase.co';
  static const String anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImV1eHppZnB2ZWxxd3FoYnVkcHB0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzczMzgxMTgsImV4cCI6MjA5MjkxNDExOH0.NGx3x-uus2FuPeSKJwSgDB15_uEsBQ6OqBxf-Njnxws';

  // Returns false only when the key is literally empty or a short placeholder.
  // A real Supabase JWT is always >100 characters.
  static bool get isConfigured => anonKey.length > 100;
}

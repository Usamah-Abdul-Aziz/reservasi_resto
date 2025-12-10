import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  // TODO: Ganti dengan URL dan KEY Supabase Anda
  static const String supabaseUrl = 'https://nudcvwuihchgwejrfayn.supabase.co';
  static const String supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im51ZGN2d3VpaGNoZ3dlanJmYXluIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjUxNzQ4MzYsImV4cCI6MjA4MDc1MDgzNn0.9vl9UOCjmowdFY-jMDVeb3sFiYxiD6XjCeJcqMSK1Z0';

  static late SupabaseClient supabaseClient;

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseKey,
    );
    supabaseClient = Supabase.instance.client;
  }

  static SupabaseClient getClient() {
    return supabaseClient;
  }
}

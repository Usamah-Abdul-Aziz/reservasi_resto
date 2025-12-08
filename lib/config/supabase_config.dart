import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  // TODO: Ganti dengan URL dan KEY Supabase Anda
  static const String supabaseUrl = 'YOUR_SUPABASE_URL';
  static const String supabaseKey = 'YOUR_SUPABASE_ANON_KEY';

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

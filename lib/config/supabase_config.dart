import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  // TODO: Ganti dengan URL dan KEY Supabase Anda
  static const String supabaseUrl = 'https://glqazvkncbctbfogpwtt.supabase.co';
  static const String supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdscWF6dmtuY2JjdGJmb2dwd3R0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjUxODIyOTIsImV4cCI6MjA4MDc1ODI5Mn0.eZ1-OUTgnyJbSOJOWDhzOOfQOp7OsYhGzsCMnnWEtF8';

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

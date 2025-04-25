import 'package:supabase_flutter/supabase_flutter.dart';

const String supabaseUrl = 'https://sjascaerzktalalasonl.supabase.co';
const String supabaseAnonKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNqYXNjYWVyemt0YWxhbGFzb25sIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDUzNjcwMDksImV4cCI6MjA2MDk0MzAwOX0.9wjf-rOvb8-pyFTS0WFZc-RdQAHNHi4zsJJyff80eac';

class SupabaseConfig {
  static final SupabaseClient client = SupabaseClient(supabaseUrl, supabaseAnonKey);
}

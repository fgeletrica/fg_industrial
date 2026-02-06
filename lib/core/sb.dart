import 'package:supabase_flutter/supabase_flutter.dart';

class Sb {
  static SupabaseClient get c => Supabase.instance.client;
}

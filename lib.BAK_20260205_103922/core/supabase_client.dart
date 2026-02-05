import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_config.dart';

class SupabaseClientApp {
  static Future<void> init() async {
    final k = SupabaseConfig.anonKey;

    if (k.trim() != k || k.contains('\n') || k.length < 80) {
      throw Exception('Supabase anonKey inválida (quebrada/truncada).');
    }

    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey,
    );
  }
}

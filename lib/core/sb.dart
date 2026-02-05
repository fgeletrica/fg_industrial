import 'package:supabase_flutter/supabase_flutter.dart';

import '../app_config.dart';
import 'supabase_client.dart';

class Sb {
  static Future<void> init() async {
    await SupabaseClientApp.init();
  }

  static SupabaseClient get c => Supabase.instance.client;

  static String emailFromMatricula(String matricula) {
    final m = matricula.trim();
    if (m.isEmpty) return '';
    return '$m@${AppConfig.matriculaEmailDomain}';
  }
}

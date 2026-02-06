import "screens/screen_login.dart";
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/app_theme.dart';
import 'supabase_service.dart';
import 'screens/screen_login.dart';
import 'screens/screen_home.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Sb.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "FG Industrial",
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      home: StreamBuilder<AuthState>(
        stream: Sb.c.auth.onAuthStateChange,
        builder: (context, snap) {
          final session = Sb.c.auth.currentSession;
          if (session == null) return ScreenLogin();
          return const HomeScreen();
        },
      ),
    );
  }
}

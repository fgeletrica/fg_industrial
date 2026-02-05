import 'core/sb.dart';

import "package:flutter/material.dart";
import "supabase_service.dart";
import "screen_login.dart";

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Sb.init();
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "FG Industrial",
      theme: ThemeData.dark(useMaterial3: true),
      home: const LoginScreen(),
    );
  }
}

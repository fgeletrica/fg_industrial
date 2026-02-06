import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData dark() {
    const seed = Color(0xFFF2C14E); // amarelo “industrial”
    const bg = Color(0xFF070B14);
    const surface = Color(0xFF0B1220);
    const outline = Color(0xFF1B2A41);

    final scheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: Brightness.dark,
      surface: surface,
      background: bg,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: bg,

      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: bg,
        foregroundColor: Colors.white,
      ),

      cardTheme: const CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(18)),
          side: BorderSide(color: outline, width: 1),
        ),
      ),

      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          borderSide: BorderSide(color: outline, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          borderSide: BorderSide(color: outline, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          borderSide: BorderSide(color: seed, width: 1.5),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          minimumSize: MaterialStatePropertyAll(Size.fromHeight(52)),
          shape: const MaterialStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
          ),
          backgroundColor: MaterialStatePropertyAll(seed),
          foregroundColor: const MaterialStatePropertyAll(Colors.black),
          textStyle: const MaterialStatePropertyAll(
            TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          minimumSize: const MaterialStatePropertyAll(Size.fromHeight(52)),
          shape: const MaterialStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
          ),
          backgroundColor: MaterialStatePropertyAll(seed),
          foregroundColor: const MaterialStatePropertyAll(Colors.black),
          textStyle: const MaterialStatePropertyAll(
            TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),
      ),

      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(14))),
      ),

      dividerTheme: const DividerThemeData(
        thickness: 1,
        space: 1,
        color: outline,
      ),
    );
  }
}

import "package:flutter/material.dart";

ThemeData buildTheme() {
  const radius = 16.0;

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF0B1220),

    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFFFFC107),
      brightness: Brightness.dark,
    ),

    appBarTheme: const AppBarTheme(
      centerTitle: false,
      elevation: 0,
      backgroundColor: Color(0xFF0B1220),
      foregroundColor: Colors.white,
    ),

    cardTheme: const CardThemeData(
      color: Color(0xFF0F1A2E),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(radius)),
      ),
    ),

    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: Color(0xFF0F1A2E),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(radius)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(radius)),
        borderSide: BorderSide(color: Color(0x223FFFFFF)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(radius)),
        borderSide: BorderSide(color: Color(0xFFFFC107), width: 1.2),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      hintStyle: TextStyle(color: Color(0x88FFFFFF)),
      labelStyle: TextStyle(color: Color(0xCCFFFFFF)),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size.fromHeight(48),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(radius)),
        ),
      ),
    ),
  );
}

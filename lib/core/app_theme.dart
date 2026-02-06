import 'package:flutter/material.dart';

class AppTheme {
  // Coca palette (base)
  static const cocaRed = Color(0xFFE41E2B);
  static const cocaRedDark = Color(0xFFB5121C);

  // “Ink” / industrial dark
  static const ink = Color(0xFF0B0F1A);
  static const ink2 = Color(0xFF0F1526);
  static const outlineDark = Color(0xFF2A3553);

  // Light palette
  static const bgLight = Color(0xFFF7F7F9);
  static const outlineLight = Color(0xFFE5E7EB);

  static ThemeData dark() {
    final cs =
        ColorScheme.fromSeed(
          seedColor: cocaRed,
          brightness: Brightness.dark,
          background: ink,
          surface: ink2,
        ).copyWith(
          primary: cocaRed,
          secondary: cocaRedDark,
          outline: outlineDark,
          surface: ink2,
          background: ink,
        );

    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      scaffoldBackgroundColor: cs.background,

      // Tipografia “corporate”
      textTheme: Typography.englishLike2021.apply(
        bodyColor: cs.onSurface,
        displayColor: cs.onSurface,
      ),

      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: cs.background,
        foregroundColor: cs.onSurface,
        surfaceTintColor: Colors.transparent,
      ),

      cardTheme: CardThemeData(
        color: cs.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(Radius.circular(18)),
          side: BorderSide(color: cs.outline, width: 1),
        ),
      ),

      dividerTheme: DividerThemeData(thickness: 1, space: 1, color: cs.outline),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cs.surface,
        hintStyle: TextStyle(color: cs.onSurface.withOpacity(.60)),
        labelStyle: TextStyle(color: cs.onSurface.withOpacity(.72)),
        border: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(16)),
          borderSide: BorderSide(color: cs.outline, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(16)),
          borderSide: BorderSide(color: cs.outline, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(16)),
          borderSide: BorderSide(color: cs.primary, width: 1.6),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          minimumSize: const MaterialStatePropertyAll(Size.fromHeight(52)),
          shape: const MaterialStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
          ),
          backgroundColor: MaterialStatePropertyAll(cs.primary),
          foregroundColor: const MaterialStatePropertyAll(Colors.white),
          textStyle: const MaterialStatePropertyAll(
            TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          minimumSize: const MaterialStatePropertyAll(Size.fromHeight(52)),
          shape: const MaterialStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
          ),
          backgroundColor: MaterialStatePropertyAll(cs.primary),
          foregroundColor: const MaterialStatePropertyAll(Colors.white),
          textStyle: const MaterialStatePropertyAll(
            TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          minimumSize: const MaterialStatePropertyAll(Size.fromHeight(48)),
          shape: const MaterialStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
          ),
          side: MaterialStatePropertyAll(
            BorderSide(color: cs.outline, width: 1),
          ),
          foregroundColor: MaterialStatePropertyAll(cs.onSurface),
          textStyle: const MaterialStatePropertyAll(
            TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
        ),
      ),

      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(14)),
        ),
      ),
    );
  }

  static ThemeData light() {
    final cs = ColorScheme.fromSeed(
      seedColor: cocaRed,
      brightness: Brightness.light,
      background: bgLight,
      surface: Colors.white,
    ).copyWith(primary: cocaRed, secondary: cocaRedDark, outline: outlineLight);

    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      scaffoldBackgroundColor: cs.background,

      textTheme: Typography.englishLike2021.apply(
        bodyColor: cs.onSurface,
        displayColor: cs.onSurface,
      ),

      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: cs.surface,
        foregroundColor: cs.onSurface,
        surfaceTintColor: Colors.transparent,
      ),

      cardTheme: CardThemeData(
        color: cs.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(Radius.circular(18)),
          side: BorderSide(color: cs.outline, width: 1),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cs.surface,
        hintStyle: TextStyle(color: cs.onSurface.withOpacity(.55)),
        labelStyle: TextStyle(color: cs.onSurface.withOpacity(.70)),
        border: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(16)),
          borderSide: BorderSide(color: cs.outline, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(16)),
          borderSide: BorderSide(color: cs.outline, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(16)),
          borderSide: BorderSide(color: cs.primary, width: 1.6),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          minimumSize: const MaterialStatePropertyAll(Size.fromHeight(52)),
          shape: const MaterialStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
          ),
          backgroundColor: MaterialStatePropertyAll(cs.primary),
          foregroundColor: const MaterialStatePropertyAll(Colors.white),
          textStyle: const MaterialStatePropertyAll(
            TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
        ),
      ),
    );
  }
}

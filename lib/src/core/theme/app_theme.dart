import 'package:flutter/material.dart';

class AppTheme {
  // Gold gradient palette (Shiny Gold)
  static const goldHigh = Color(0xFFFFE7A6);
  static const goldMain = Color(0xFFC9A227);
  static const goldDeep = Color(0xFF8B6B0D);
  static const goldLight = Color(0xFFFFD37A);

  // Glassy Base Colors
  static const darkGlassBg = Color(0xFF0B0E14); // Blurry Black
  static const lightGlassBg = Color(0xFFF7F7F7); // Blurry White

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: goldMain,
      primary: goldMain,
      onPrimary: Colors.black,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: lightGlassBg,
      fontFamily: 'Inter', // Default UI font
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'Amiri',
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white.withOpacity(0.85),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.black.withOpacity(0.05)),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
            );
          }
          return const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          );
        }),
      ),
    );
  }

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: goldMain,
      primary: goldMain,
      onPrimary: Colors.black,
      brightness: Brightness.dark,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: darkGlassBg,
      fontFamily: 'Inter',
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: goldLight,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'Amiri',
        ),
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF161B22).withOpacity(0.75),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
            );
          }
          return const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          );
        }),
      ),
    );
  }
}
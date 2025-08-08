import 'package:flutter/material.dart';

class AppTheme {
  
  // --- NEW, PROFESSIONAL DARK THEME ---
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,

    // Define a cohesive color scheme
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF8A77FF),      // A vibrant purple for primary actions and highlights
      secondary: Color(0xFF3D445C),     // A muted blue-grey for secondary elements
      background: Color(0xFF121212),   // A deep, near-black for the main background
      surface: Color(0xFF1E1E1E),      // A slightly lighter black for card surfaces
      onPrimary: Colors.white,
      onSecondary: Colors.white70,
      onBackground: Colors.white,
      onSurface: Colors.white,
      error: Colors.redAccent,
    ),

    // Define the default background color for all screens
    scaffoldBackgroundColor: const Color(0xFF121212),

    // Define the default style for all AppBars
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent, // Transparent to blend with the scaffold
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      iconTheme: IconThemeData(color: Colors.white70),
    ),

    // Define default styles for text fields
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF2A2A2A),
      hintStyle: TextStyle(color: Colors.grey[600]),
      prefixIconColor: Colors.grey[400],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
    ),

    // Define the style for the Bottom Navigation Bar
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: const Color(0xFF1E1E1E), // Slightly lighter than the background
      selectedItemColor: const Color(0xFF8A77FF), // Use primary color for the selected item
      unselectedItemColor: Colors.grey[600],
      type: BottomNavigationBarType.fixed,
      elevation: 10,
    ),
    
    // Define the theme for all ElevatedButtons
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF8A77FF), // Use primary color
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),

    // Define default styles for text
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white70),
      titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      headlineSmall: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    ),
  );

  
  // --- OLD LIGHT THEME (Kept for reference or future use) ---
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
    scaffoldBackgroundColor: const Color(0xFFF0F2F5),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: Colors.black87,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: IconThemeData(color: Colors.black87),
    ),
  );
}
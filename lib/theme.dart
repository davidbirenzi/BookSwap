import 'package:flutter/material.dart';

// BookSwap App Theme - Consistent design system
// Color scheme: Dark navy blue + warm yellow + white
class AppTheme {
  // Primary brand colors
  static const Color darkNavy = Color(0xFF0E0E2C);   // App bars, navigation
  static const Color warmYellow = Color(0xFFF5C841); // Buttons, accents
  
  // Main theme configuration
  static ThemeData get theme {
    return ThemeData(
      primarySwatch: Colors.blue,
      scaffoldBackgroundColor: Colors.white,
      // App bar styling - dark navy with white text
      appBarTheme: const AppBarTheme(
        backgroundColor: darkNavy,
        foregroundColor: Colors.white,
        elevation: 0, // flat design
      ),
      // Card styling for book listings and UI elements
      cardTheme: const CardThemeData(
        color: Colors.white,
        elevation: 4, // subtle shadow
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)), // rounded corners
        ),
      ),
      // Input field styling - clean white fields with rounded borders
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none, // no border, just fill
        ),
        labelStyle: TextStyle(color: Colors.grey[600]),
        hintStyle: TextStyle(color: Colors.grey[500]),
      ),
      // Button styling - warm yellow with black text
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: warmYellow, // brand yellow
          foregroundColor: Colors.black, // black text for contrast
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
        ),
      ),
      // Text styling - black text for readability on white backgrounds
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Colors.black),
        bodyMedium: TextStyle(color: Colors.black),
        titleLarge: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        titleMedium: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: Colors.black,
      ),
      // Bottom navigation - dark navy background with yellow selection
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: darkNavy,
        selectedItemColor: warmYellow, // yellow for active tab
        unselectedItemColor: Colors.white54, // muted white for inactive
        type: BottomNavigationBarType.fixed, // always show all tabs
      ),
    );
  }
}
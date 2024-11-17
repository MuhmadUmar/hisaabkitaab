import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF007BFF); // Dark Blue
  static const Color secondaryColor = Color(0xFFF2F2F2); // Light Gray
  static const Color accentColor = Color(0xFFFF9800); // Orange

  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: primaryColor,
    secondaryHeaderColor: secondaryColor,
    hintColor: accentColor,
    fontFamily: 'Roboto',
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
      bodyLarge: TextStyle(fontSize: 16.0),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: secondaryColor,
    secondaryHeaderColor: primaryColor,
    hintColor: accentColor,
    fontFamily: 'Roboto',
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
      bodyLarge: TextStyle(fontSize: 16.0),
    ),
  );
}

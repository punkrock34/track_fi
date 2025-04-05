import 'package:flutter/material.dart';

class AppTheme {
  static const _lightPrimary = Color(0xFF3366FF);
  static const _darkPrimary = Color(0xFF1A2B4C);
  static const _accentBlue = Color(0xFF4F83FF);

  static final lightTheme = ThemeData(
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: _lightPrimary,
      secondary: _accentBlue,
      surface: Colors.white,
      error: Colors.redAccent,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.black,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: const Color(0xFFF5F8FF),
    useMaterial3: true,
  );

  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: _accentBlue,
      secondary: _accentBlue,
      surface: const Color(0xFF121E35),
      error: Colors.redAccent,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.white,
      onError: Colors.black,
    ),
    scaffoldBackgroundColor: _darkPrimary,
    useMaterial3: true,
  );
}

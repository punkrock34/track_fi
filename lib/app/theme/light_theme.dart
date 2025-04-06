import 'package:flutter/material.dart';
import 'colors.dart';

final lightTheme = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
    primary: lightPrimary,
    secondary: lightSecondary,
    surface: lightSurface,
    error: lightError,
    onPrimary: Colors.white,
    onSecondary: lightOnSurface,
    onSurface: lightOnSurface,
    onError: Colors.white,
    tertiary: lightAccent,
  ),
  scaffoldBackgroundColor: lightBackground,
  cardColor: lightSurface,
  dividerColor: lightDividerColor,
  shadowColor: shadowColor,
  useMaterial3: true,

  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: lightOnSurface),
    bodyMedium: TextStyle(color: lightOnSurface),
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      foregroundColor: Colors.white,
      backgroundColor: lightPrimary,
      elevation: 2,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  ),

  cardTheme: CardTheme(
    elevation: 3,
    margin: const EdgeInsets.all(8),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),

  appBarTheme: const AppBarTheme(
    backgroundColor: lightPrimary,
    foregroundColor: Colors.white,
    elevation: 0,
    centerTitle: true,
  ),

  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: lightAccent,
    foregroundColor: Colors.white,
  ),
);

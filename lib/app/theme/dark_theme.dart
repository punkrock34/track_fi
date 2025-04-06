import 'package:flutter/material.dart';
import 'colors.dart';

final darkTheme = ThemeData(
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    primary: darkAccentBlue,
    secondary: darkAccentBlue,
    surface: darkSurface,
    error: Colors.redAccent,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: Colors.white,
    onError: Colors.black,
    tertiary: darkTertiary,
  ),
  scaffoldBackgroundColor: darkPrimary,
  cardColor: darkSurface,
  dividerColor: darkDividerColor,
  shadowColor: shadowColor,
  useMaterial3: true,

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      foregroundColor: Colors.white,
      backgroundColor: darkAccentBlue,
      elevation: 3,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  ),

  cardTheme: CardTheme(
    elevation: 4,
    margin: const EdgeInsets.all(8),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),

  appBarTheme: const AppBarTheme(
    backgroundColor: darkPrimary,
    foregroundColor: Colors.white,
    elevation: 0,
    centerTitle: true,
  ),

  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: darkAccentBlue,
    foregroundColor: Colors.white,
  ),
);

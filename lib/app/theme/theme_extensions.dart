import 'package:flutter/material.dart';

extension ThemeColors on ThemeData {
  Color get backgroundGradientStart => brightness == Brightness.dark
      ? const Color(0xFF1A2B4C)
      : const Color(0xFF3366FF);

  Color get backgroundGradientEnd => brightness == Brightness.dark
      ? const Color(0xFF121E35)
      : const Color(0xFF4F83FF);

  Color get textSubtle =>
      brightness == Brightness.dark ? Colors.white70 : Colors.black54;

  Color get textPrimary =>
      brightness == Brightness.dark ? Colors.white : Colors.black87;

  Color get cardBorder =>
      brightness == Brightness.dark ? Colors.white10 : Colors.black12;
}

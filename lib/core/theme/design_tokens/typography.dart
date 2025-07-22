import 'package:flutter/material.dart';

abstract class AppTypography {
  
  static String get fontFamily => 'Roboto';
  
  static TextTheme get lightTextTheme => const TextTheme(
    displayLarge: TextStyle(
      fontFamily: 'Roboto',
      fontSize: 57,
      fontWeight: FontWeight.w400,
      height: 1.12,
      letterSpacing: -0.25,
      color: Color(0xFF0A0A0A),
    ),
    displayMedium: TextStyle(
      fontFamily: 'Roboto',
      fontSize: 45,
      fontWeight: FontWeight.w400,
      height: 1.16,
      color: Color(0xFF0A0A0A),
    ),
    displaySmall: TextStyle(
      fontFamily: 'Roboto',
      fontSize: 36,
      fontWeight: FontWeight.w400,
      height: 1.22,
      color: Color(0xFF0A0A0A),
    ),
    
    headlineLarge: TextStyle(
      fontFamily: 'Roboto',
      fontSize: 32,
      fontWeight: FontWeight.w600,
      height: 1.25,
      color: Color(0xFF0A0A0A),
    ),
    headlineMedium: TextStyle(
      fontFamily: 'Roboto',
      fontSize: 28,
      fontWeight: FontWeight.w600,
      height: 1.29,
      color: Color(0xFF0A0A0A),
    ),
    headlineSmall: TextStyle(
      fontFamily: 'Roboto',
      fontSize: 24,
      fontWeight: FontWeight.w600,
      height: 1.33,
      color: Color(0xFF0A0A0A),
    ),
    
    titleLarge: TextStyle(
      fontFamily: 'Roboto',
      fontSize: 22,
      fontWeight: FontWeight.w600,
      height: 1.27,
      color: Color(0xFF0A0A0A),
    ),
    titleMedium: TextStyle(
      fontFamily: 'Roboto',
      fontSize: 16,
      fontWeight: FontWeight.w600,
      height: 1.50,
      letterSpacing: 0.15,
      color: Color(0xFF0A0A0A),
    ),
    titleSmall: TextStyle(
      fontFamily: 'Roboto',
      fontSize: 14,
      fontWeight: FontWeight.w600,
      height: 1.43,
      letterSpacing: 0.1,
      color: Color(0xFF0A0A0A),
    ),
    
    bodyLarge: TextStyle(
      fontFamily: 'Roboto',
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: 1.50,
      letterSpacing: 0.5,
      color: Color(0xFF0A0A0A),
    ),
    bodyMedium: TextStyle(
      fontFamily: 'Roboto',
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.43,
      letterSpacing: 0.25,
      color: Color(0xFF0A0A0A),
    ),
    bodySmall: TextStyle(
      fontFamily: 'Roboto',
      fontSize: 12,
      fontWeight: FontWeight.w400,
      height: 1.33,
      letterSpacing: 0.4,
      color: Color(0xFF6B7280),
    ),
    
    labelLarge: TextStyle(
      fontFamily: 'Roboto',
      fontSize: 14,
      fontWeight: FontWeight.w600,
      height: 1.43,
      letterSpacing: 0.1,
      color: Color(0xFF0A0A0A),
    ),
    labelMedium: TextStyle(
      fontFamily: 'Roboto',
      fontSize: 12,
      fontWeight: FontWeight.w600,
      height: 1.33,
      letterSpacing: 0.5,
      color: Color(0xFF0A0A0A),
    ),
    labelSmall: TextStyle(
      fontFamily: 'Roboto',
      fontSize: 11,
      fontWeight: FontWeight.w600,
      height: 1.45,
      letterSpacing: 0.5,
      color: Color(0xFF6B7280),
    ),
  );
  
  static TextTheme get darkTextTheme => const TextTheme(
    displayLarge: TextStyle(
      fontFamily: 'Roboto',
      fontSize: 57,
      fontWeight: FontWeight.w400,
      height: 1.12,
      letterSpacing: -0.25,
      color: Color(0xFFFAFAFA),
    ),
    displayMedium: TextStyle(
      fontFamily: 'Roboto',
      fontSize: 45,
      fontWeight: FontWeight.w400,
      height: 1.16,
      color: Color(0xFFFAFAFA),
    ),
    displaySmall: TextStyle(
      fontFamily: 'Roboto',
      fontSize: 36,
      fontWeight: FontWeight.w400,
      height: 1.22,
      color: Color(0xFFFAFAFA),
    ),
    
    headlineLarge: TextStyle(
      fontFamily: 'Roboto',
      fontSize: 32,
      fontWeight: FontWeight.w600,
      height: 1.25,
      color: Color(0xFFFAFAFA),
    ),
    headlineMedium: TextStyle(
      fontFamily: 'Roboto',
      fontSize: 28,
      fontWeight: FontWeight.w600,
      height: 1.29,
      color: Color(0xFFFAFAFA),
    ),
    headlineSmall: TextStyle(
      fontFamily: 'Roboto',
      fontSize: 24,
      fontWeight: FontWeight.w600,
      height: 1.33,
      color: Color(0xFFFAFAFA),
    ),

    titleLarge: TextStyle(
      fontFamily: 'Roboto',
      fontSize: 22,
      fontWeight: FontWeight.w600,
      height: 1.27,
      color: Color(0xFFFAFAFA),
    ),
    titleMedium: TextStyle(
      fontFamily: 'Roboto',
      fontSize: 16,
      fontWeight: FontWeight.w600,
      height: 1.50,
      letterSpacing: 0.15,
      color: Color(0xFFFAFAFA),
    ),
    titleSmall: TextStyle(
      fontFamily: 'Roboto',
      fontSize: 14,
      fontWeight: FontWeight.w600,
      height: 1.43,
      letterSpacing: 0.1,
      color: Color(0xFFFAFAFA),
    ),
    
    bodyLarge: TextStyle(
      fontFamily: 'Roboto',
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: 1.50,
      letterSpacing: 0.5,
      color: Color(0xFFFAFAFA),
    ),
    bodyMedium: TextStyle(
      fontFamily: 'Roboto',
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.43,
      letterSpacing: 0.25,
      color: Color(0xFFFAFAFA),
    ),
    bodySmall: TextStyle(
      fontFamily: 'Roboto',
      fontSize: 12,
      fontWeight: FontWeight.w400,
      height: 1.33,
      letterSpacing: 0.4,
      color: Color(0xFF9CA3AF),
    ),
    
    labelLarge: TextStyle(
      fontFamily: 'Roboto',
      fontSize: 14,
      fontWeight: FontWeight.w600,
      height: 1.43,
      letterSpacing: 0.1,
      color: Color(0xFFFAFAFA),
    ),
    labelMedium: TextStyle(
      fontFamily: 'Roboto',
      fontSize: 12,
      fontWeight: FontWeight.w600,
      height: 1.33,
      letterSpacing: 0.5,
      color: Color(0xFFFAFAFA),
    ),
    labelSmall: TextStyle(
      fontFamily: 'Roboto',
      fontSize: 11,
      fontWeight: FontWeight.w600,
      height: 1.45,
      letterSpacing: 0.5,
      color: Color(0xFF9CA3AF),
    ),
  );
  
  static TextStyle get moneyLarge => const TextStyle(
    fontFamily: 'Roboto',
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.25,
    fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
  );
  
  static TextStyle get moneyMedium => const TextStyle(
    fontFamily: 'Roboto',
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.40,
    fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
  );
  
  static TextStyle get moneySmall => const TextStyle(
    fontFamily: 'Roboto',
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.50,
    fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
  );
}

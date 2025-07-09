import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract class AppTypography {
  
  static String get fontFamily => GoogleFonts.inter().fontFamily!;
  
  static TextTheme get lightTextTheme => GoogleFonts.interTextTheme().copyWith(
    displayLarge: GoogleFonts.inter(
      fontSize: 57,
      fontWeight: FontWeight.w400,
      height: 1.12,
      letterSpacing: -0.25,
      color: const Color(0xFF0A0A0A),
    ),
    displayMedium: GoogleFonts.inter(
      fontSize: 45,
      fontWeight: FontWeight.w400,
      height: 1.16,
      color: const Color(0xFF0A0A0A),
    ),
    displaySmall: GoogleFonts.inter(
      fontSize: 36,
      fontWeight: FontWeight.w400,
      height: 1.22,
      color: const Color(0xFF0A0A0A),
    ),
    
    headlineLarge: GoogleFonts.inter(
      fontSize: 32,
      fontWeight: FontWeight.w600,
      height: 1.25,
      color: const Color(0xFF0A0A0A),
    ),
    headlineMedium: GoogleFonts.inter(
      fontSize: 28,
      fontWeight: FontWeight.w600,
      height: 1.29,
      color: const Color(0xFF0A0A0A),
    ),
    headlineSmall: GoogleFonts.inter(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      height: 1.33,
      color: const Color(0xFF0A0A0A),
    ),
    
    titleLarge: GoogleFonts.inter(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      height: 1.27,
      color: const Color(0xFF0A0A0A),
    ),
    titleMedium: GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      height: 1.50,
      letterSpacing: 0.15,
      color: const Color(0xFF0A0A0A),
    ),
    titleSmall: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      height: 1.43,
      letterSpacing: 0.1,
      color: const Color(0xFF0A0A0A),
    ),
    
    bodyLarge: GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: 1.50,
      letterSpacing: 0.5,
      color: const Color(0xFF0A0A0A),
    ),
    bodyMedium: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.43,
      letterSpacing: 0.25,
      color: const Color(0xFF0A0A0A),
    ),
    bodySmall: GoogleFonts.inter(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      height: 1.33,
      letterSpacing: 0.4,
      color: const Color(0xFF6B7280),
    ),
    
    labelLarge: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      height: 1.43,
      letterSpacing: 0.1,
      color: const Color(0xFF0A0A0A),
    ),
    labelMedium: GoogleFonts.inter(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      height: 1.33,
      letterSpacing: 0.5,
      color: const Color(0xFF0A0A0A),
    ),
    labelSmall: GoogleFonts.inter(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      height: 1.45,
      letterSpacing: 0.5,
      color: const Color(0xFF6B7280),
    ),
  );
  
  static TextTheme get darkTextTheme => GoogleFonts.interTextTheme().copyWith(
    displayLarge: GoogleFonts.inter(
      fontSize: 57,
      fontWeight: FontWeight.w400,
      height: 1.12,
      letterSpacing: -0.25,
      color: const Color(0xFFFAFAFA),
    ),
    displayMedium: GoogleFonts.inter(
      fontSize: 45,
      fontWeight: FontWeight.w400,
      height: 1.16,
      color: const Color(0xFFFAFAFA),
    ),
    displaySmall: GoogleFonts.inter(
      fontSize: 36,
      fontWeight: FontWeight.w400,
      height: 1.22,
      color: const Color(0xFFFAFAFA),
    ),
    
    headlineLarge: GoogleFonts.inter(
      fontSize: 32,
      fontWeight: FontWeight.w600,
      height: 1.25,
      color: const Color(0xFFFAFAFA),
    ),
    headlineMedium: GoogleFonts.inter(
      fontSize: 28,
      fontWeight: FontWeight.w600,
      height: 1.29,
      color: const Color(0xFFFAFAFA),
    ),
    headlineSmall: GoogleFonts.inter(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      height: 1.33,
      color: const Color(0xFFFAFAFA),
    ),

    titleLarge: GoogleFonts.inter(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      height: 1.27,
      color: const Color(0xFFFAFAFA),
    ),
    titleMedium: GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      height: 1.50,
      letterSpacing: 0.15,
      color: const Color(0xFFFAFAFA),
    ),
    titleSmall: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      height: 1.43,
      letterSpacing: 0.1,
      color: const Color(0xFFFAFAFA),
    ),
    
    bodyLarge: GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: 1.50,
      letterSpacing: 0.5,
      color: const Color(0xFFFAFAFA),
    ),
    bodyMedium: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.43,
      letterSpacing: 0.25,
      color: const Color(0xFFFAFAFA),
    ),
    bodySmall: GoogleFonts.inter(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      height: 1.33,
      letterSpacing: 0.4,
      color: const Color(0xFF9CA3AF),
    ),
    
    labelLarge: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      height: 1.43,
      letterSpacing: 0.1,
      color: const Color(0xFFFAFAFA),
    ),
    labelMedium: GoogleFonts.inter(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      height: 1.33,
      letterSpacing: 0.5,
      color: const Color(0xFFFAFAFA),
    ),
    labelSmall: GoogleFonts.inter(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      height: 1.45,
      letterSpacing: 0.5,
      color: const Color(0xFF9CA3AF),
    ),
  );
  
  static TextStyle get moneyLarge => GoogleFonts.inter(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.25,
    fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
  );
  
  static TextStyle get moneyMedium => GoogleFonts.inter(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.40,
    fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
  );
  
  static TextStyle get moneySmall => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.50,
    fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
  );
}

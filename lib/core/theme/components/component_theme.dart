import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../design_tokens/design_tokens.dart';
import '../schemes/color_schemes.dart';

abstract class ComponentThemes {
  
  static AppBarTheme get lightAppBarTheme => const AppBarTheme(
    backgroundColor: ColorSchemes.premiumWhite,
    foregroundColor: ColorSchemes.premiumBlack,
    elevation: 0,
    scrolledUnderElevation: 4,
    centerTitle: true,
    titleTextStyle: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: ColorSchemes.premiumBlack,
    ),
    systemOverlayStyle: SystemUiOverlayStyle.dark,
  );

  static CardTheme get lightCardTheme => CardTheme(
    color: ColorSchemes.premiumWhite,
    shadowColor: Colors.black.withOpacity(0.8),
    elevation: DesignTokens.elevationCard,
    margin: const EdgeInsets.all(DesignTokens.spacingXs),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
      side: BorderSide(
        color: const Color(0xFFE5E7EB).withOpacity(0.8),
        width: 0.5,
      ),
    ),
    clipBehavior: Clip.antiAlias,
  );

  static ElevatedButtonThemeData get lightElevatedButtonTheme => ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: ColorSchemes.accentBlue,
      foregroundColor: ColorSchemes.premiumWhite,
      disabledBackgroundColor: const Color(0xFFE5E7EB),
      disabledForegroundColor: const Color(0xFF9CA3AF),
      elevation: 2,
      shadowColor: ColorSchemes.accentBlue.withOpacity(0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.spacingLg,
        vertical: DesignTokens.spacingSm,
      ),
      minimumSize: const Size(88, DesignTokens.buttonHeightMd),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      ),
    ),
  );

  static OutlinedButtonThemeData get lightOutlinedButtonTheme => OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: ColorSchemes.accentBlue,
      backgroundColor: Colors.transparent,
      disabledForegroundColor: const Color(0xFF9CA3AF),
      side: const BorderSide(
        color: ColorSchemes.accentBlue,
        width: 1.5,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.spacingLg,
        vertical: DesignTokens.spacingSm,
      ),
      minimumSize: const Size(88, DesignTokens.buttonHeightMd),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      ),
    ),
  );

  static TextButtonThemeData get lightTextButtonTheme => TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: ColorSchemes.accentBlue,
      disabledForegroundColor: const Color(0xFF9CA3AF),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.spacingMd,
        vertical: DesignTokens.spacingSm,
      ),
      minimumSize: const Size(88, DesignTokens.buttonHeightMd),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      ),
    ),
  );

  static InputDecorationTheme get lightInputDecorationTheme => InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFFF8FAFC),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
      borderSide: const BorderSide(
        color: Color(0xFFE5E7EB),
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
      borderSide: const BorderSide(
        color: Color(0xFFE5E7EB),
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
      borderSide: const BorderSide(
        color: ColorSchemes.accentBlue,
        width: 2,
      ),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
      borderSide: const BorderSide(
        color: ColorSchemes.errorRed,
      ),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
      borderSide: const BorderSide(
        color: ColorSchemes.errorRed,
        width: 2,
      ),
    ),
    contentPadding: const EdgeInsets.symmetric(
      horizontal: DesignTokens.spacingSm,
      vertical: DesignTokens.spacingSm,
    ),
    hintStyle: const TextStyle(
      color: Color(0xFF9CA3AF),
      fontSize: 16,
    ),
    labelStyle: const TextStyle(
      color: Color(0xFF6B7280),
      fontSize: 16,
    ),
  );

  static FloatingActionButtonThemeData get lightFabTheme => const FloatingActionButtonThemeData(
    backgroundColor: ColorSchemes.accentBlue,
    foregroundColor: ColorSchemes.premiumWhite,
    elevation: DesignTokens.elevationFab,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(DesignTokens.radiusLg)),
    ),
  );

  static SwitchThemeData get lightSwitchTheme => SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
      if (states.contains(WidgetState.selected)) {
        return ColorSchemes.premiumWhite;
      }
      return const Color(0xFF9CA3AF);
    }),
    trackColor: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
      if (states.contains(WidgetState.selected)) {
        return ColorSchemes.accentBlue;
      }
      return const Color(0xFFE5E7EB);
    }),
  );

  static DividerThemeData get lightDividerTheme => const DividerThemeData(
    color: Color(0xFFE5E7EB),
    thickness: 1,
    space: 1,
  );

  static AppBarTheme get darkAppBarTheme => const AppBarTheme(
    backgroundColor: Color(0xFF1E293B),
    foregroundColor: ColorSchemes.premiumWhite,
    elevation: 0,
    scrolledUnderElevation: 4,
    centerTitle: true,
    titleTextStyle: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: ColorSchemes.premiumWhite,
    ),
    systemOverlayStyle: SystemUiOverlayStyle.light,
  );

  static CardTheme get darkCardTheme => CardTheme(
    color: const Color(0xFF1E293B),
    shadowColor: Colors.black.withOpacity(0.3),
    elevation: DesignTokens.elevationCard,
    margin: const EdgeInsets.all(DesignTokens.spacingXs),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
      side: BorderSide(
        color: const Color(0xFF374151).withOpacity(0.8),
        width: 0.5,
      ),
    ),
    clipBehavior: Clip.antiAlias,
  );

  static ElevatedButtonThemeData get darkElevatedButtonTheme => ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: ColorSchemes.accentBlue,
      foregroundColor: ColorSchemes.premiumWhite,
      disabledBackgroundColor: const Color(0xFF374151),
      disabledForegroundColor: const Color(0xFF6B7280),
      elevation: 2,
      shadowColor: ColorSchemes.accentBlue.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.spacingLg,
        vertical: DesignTokens.spacingSm,
      ),
      minimumSize: const Size(88, DesignTokens.buttonHeightMd),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      ),
    ),
  );

  static OutlinedButtonThemeData get darkOutlinedButtonTheme => OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: ColorSchemes.accentBlue,
      backgroundColor: Colors.transparent,
      disabledForegroundColor: const Color(0xFF6B7280),
      side: const BorderSide(
        color: ColorSchemes.accentBlue,
        width: 1.5,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.spacingLg,
        vertical: DesignTokens.spacingSm,
      ),
      minimumSize: const Size(88, DesignTokens.buttonHeightMd),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      ),
    ),
  );

  static TextButtonThemeData get darkTextButtonTheme => TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: ColorSchemes.accentBlue,
      disabledForegroundColor: const Color(0xFF6B7280),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.spacingMd,
        vertical: DesignTokens.spacingSm,
      ),
      minimumSize: const Size(88, DesignTokens.buttonHeightMd),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      ),
    ),
  );

  static InputDecorationTheme get darkInputDecorationTheme => InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFF0F172A),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
      borderSide: const BorderSide(
        color: Color(0xFF374151),
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
      borderSide: const BorderSide(
        color: Color(0xFF374151),
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
      borderSide: const BorderSide(
        color: ColorSchemes.accentBlue,
        width: 2,
      ),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
      borderSide: const BorderSide(
        color: ColorSchemes.errorRed,
      ),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
      borderSide: const BorderSide(
        color: ColorSchemes.errorRed,
        width: 2,
      ),
    ),
    contentPadding: const EdgeInsets.symmetric(
      horizontal: DesignTokens.spacingSm,
      vertical: DesignTokens.spacingSm,
    ),
    hintStyle: const TextStyle(
      color: Color(0xFF6B7280),
      fontSize: 16,
    ),
    labelStyle: const TextStyle(
      color: Color(0xFF9CA3AF),
      fontSize: 16,
    ),
  );

  static FloatingActionButtonThemeData get darkFabTheme => const FloatingActionButtonThemeData(
    backgroundColor: ColorSchemes.accentBlue,
    foregroundColor: ColorSchemes.premiumWhite,
    elevation: DesignTokens.elevationFab,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(DesignTokens.radiusLg)),
    ),
  );

  static SwitchThemeData get darkSwitchTheme => SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
      if (states.contains(WidgetState.selected)) {
        return ColorSchemes.premiumWhite;
      }
      return const Color(0xFF6B7280);
    }),
    trackColor: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
      if (states.contains(WidgetState.selected)) {
        return ColorSchemes.accentBlue;
      }
      return const Color(0xFF374151);
    }),
  );

  static DividerThemeData get darkDividerTheme => const DividerThemeData(
    color: Color(0xFF374151),
    thickness: 1,
    space: 1,
  );
}

import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';

abstract class ColorSchemes {
  static const Color premiumBlack = Color(0xFF0A0A0A);
  static const Color premiumWhite = Color(0xFFFAFAFA);
  static const Color charcoal = Color(0xFF1A1A1A);
  static const Color platinum = Color(0xFFE8E8E8);
  static const Color graphite = Color(0xFF2D2D2D);
  
  static const Color accentGold = Color(0xFFD4AF37);
  static const Color accentSilver = Color(0xFF9CA3AF);
  
  static const Color successGreen = Color(0xFF10B981);
  static const Color errorRed = Color(0xFFEF4444);
  static const Color warningAmber = Color(0xFFF59E0B);

  static ColorScheme get lightScheme => FlexColorScheme.light(
        colors: const FlexSchemeColor(
          primary: premiumBlack,
          primaryContainer: platinum,
          secondary: graphite,
          secondaryContainer: Color(0xFFF5F5F5),
          tertiary: accentGold,
          tertiaryContainer: Color(0xFFFFF8E1),
          appBarColor: premiumWhite,
          error: errorRed,
        ),
        surface: premiumWhite,
        background: premiumWhite,
        scaffoldBackground: premiumWhite,
        onPrimary: premiumWhite,
        onSurface: premiumBlack,
        onBackground: premiumBlack,
        onSecondary: premiumWhite,
        subThemesData: const FlexSubThemesData(
          interactionEffects: true,
          useM2StyleDividerInM3: true,
          elevatedButtonSchemeColor: SchemeColor.primary,
          elevatedButtonSecondarySchemeColor: SchemeColor.primaryContainer,
          inputDecoratorSchemeColor: SchemeColor.primary,
          inputDecoratorBorderSchemeColor: SchemeColor.outline,
          inputDecoratorRadius: 12.0,
          cardRadius: 16.0,
          elevatedButtonRadius: 12.0,
          outlinedButtonRadius: 12.0,
          textButtonRadius: 12.0,
        ),
      ).toScheme;

  static ColorScheme get darkScheme => FlexColorScheme.dark(
        colors: const FlexSchemeColor(
          primary: premiumWhite,
          primaryContainer: charcoal,
          secondary: platinum,
          secondaryContainer: graphite,
          tertiary: accentGold,
          tertiaryContainer: Color(0xFF3D3D00),
          appBarColor: premiumBlack,
          error: errorRed,
        ),
        surface: charcoal,
        background: premiumBlack,
        scaffoldBackground: premiumBlack,
        onPrimary: premiumBlack,
        onSurface: premiumWhite,
        onBackground: premiumWhite,
        onSecondary: premiumBlack,
        subThemesData: const FlexSubThemesData(
          interactionEffects: true,
          useM2StyleDividerInM3: true,
          elevatedButtonSchemeColor: SchemeColor.primary,
          elevatedButtonSecondarySchemeColor: SchemeColor.primaryContainer,
          inputDecoratorSchemeColor: SchemeColor.primary,
          inputDecoratorBorderSchemeColor: SchemeColor.outline,
          inputDecoratorRadius: 12.0,
          cardRadius: 16.0,
          elevatedButtonRadius: 12.0,
          outlinedButtonRadius: 12.0,
          textButtonRadius: 12.0,
        ),
      ).toScheme;

  static const FinTechColors finTechLight = FinTechColors(
    success: successGreen,
    error: errorRed,
    warning: warningAmber,
    neutral: Color(0xFF6B7280),
    accent: accentGold,
    
    cardBackground: premiumWhite,
    divider: Color(0xFFE5E7EB),
    border: Color(0xFFD1D5DB),
    shadow: Color(0x10000000),
  );

  static const FinTechColors finTechDark = FinTechColors(
    success: successGreen,
    error: errorRed,
    warning: warningAmber,
    neutral: Color(0xFF9CA3AF),
    accent: accentGold,
    
    cardBackground: charcoal,
    divider: Color(0xFF374151),
    border: Color(0xFF4B5563),
    shadow: Color(0x20000000),
  );
}

@immutable
class FinTechColors extends ThemeExtension<FinTechColors> {
  const FinTechColors({
    required this.success,
    required this.error,
    required this.warning,
    required this.neutral,
    required this.accent,
    required this.cardBackground,
    required this.divider,
    required this.border,
    required this.shadow,
  });

  final Color success;
  final Color error;
  final Color warning;
  final Color neutral;
  final Color accent;
  final Color cardBackground;
  final Color divider;
  final Color border;
  final Color shadow;

  @override
  FinTechColors copyWith({
    Color? success,
    Color? error,
    Color? warning,
    Color? neutral,
    Color? accent,
    Color? cardBackground,
    Color? divider,
    Color? border,
    Color? shadow,
  }) {
    return FinTechColors(
      success: success ?? this.success,
      error: error ?? this.error,
      warning: warning ?? this.warning,
      neutral: neutral ?? this.neutral,
      accent: accent ?? this.accent,
      cardBackground: cardBackground ?? this.cardBackground,
      divider: divider ?? this.divider,
      border: border ?? this.border,
      shadow: shadow ?? this.shadow,
    );
  }

  @override
  FinTechColors lerp(ThemeExtension<FinTechColors>? other, double t) {
    if (other is! FinTechColors) {
      return this;
    }
    return FinTechColors(
      success: Color.lerp(success, other.success, t)!,
      error: Color.lerp(error, other.error, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      neutral: Color.lerp(neutral, other.neutral, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      cardBackground: Color.lerp(cardBackground, other.cardBackground, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      border: Color.lerp(border, other.border, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
    );
  }
}

extension FinTechColorsExtension on ThemeData {
  FinTechColors get finTechColors => extension<FinTechColors>()!;
}

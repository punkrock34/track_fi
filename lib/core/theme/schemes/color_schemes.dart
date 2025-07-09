import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';

abstract class ColorSchemes {
  static const Color premiumBlack = Color(0xFF0A0A0A);
  static const Color premiumWhite = Color(0xFFFAFAFA);
  static const Color accentBlue = Color(0xFF3B82F6);

  static const Color successGreen = Color(0xFF10B981);
  static const Color errorRed = Color(0xFFEF4444);
  static const Color warningAmber = Color(0xFFF59E0B);

  static ColorScheme get lightScheme => FlexColorScheme.light(
        colors: const FlexSchemeColor(
          primary: accentBlue,
          primaryContainer: Color(0xFFD0E4FF),
          secondary: Color(0xFF565F71),
          secondaryContainer: Color(0xFFD9E3F8),
          tertiary: Color(0xFF6B5778),
          tertiaryContainer: Color(0xFFF2DAFF),
          appBarColor: Color(0xFFD9E3F8),
          error: errorRed,
        ),
        surface: premiumWhite,
        background: premiumWhite,
        scaffoldBackground: premiumWhite,
        onPrimary: Colors.white,
        onSurface: premiumBlack,
        onBackground: premiumBlack,
        onSecondary: Colors.white,
        subThemesData: const FlexSubThemesData(
          interactionEffects: true,
          tintedDisabledControls: true,
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
          primary: accentBlue,
          primaryContainer: Color(0xFF00325B),
          secondary: Color(0xFF92C5DD),
          secondaryContainer: Color(0xFF004A65),
          tertiary: Color(0xFFD7BEE4),
          tertiaryContainer: Color(0xFF523F5F),
          appBarColor: Color(0xFF004A65),
          error: errorRed,
        ),
        surface: const Color(0xFF1E293B),
        background: premiumBlack,
        scaffoldBackground: premiumBlack,
        onPrimary: Colors.white,
        onSurface: premiumWhite,
        onBackground: premiumWhite,
        onSecondary: premiumBlack,
        subThemesData: const FlexSubThemesData(
          interactionEffects: true,
          tintedDisabledControls: true,
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

    cardBackground: Colors.white,
    divider: Color(0xFFE5E7EB),
  );

  static const FinTechColors finTechDark = FinTechColors(
    success: successGreen,
    error: errorRed,
    warning: warningAmber,
    neutral: Color(0xFF9CA3AF),

    cardBackground: Color(0xFF1E293B),
    divider: Color(0xFF374151),
  );
}

@immutable
class FinTechColors extends ThemeExtension<FinTechColors> {
  const FinTechColors({
    required this.success,
    required this.error,
    required this.warning,
    required this.neutral,
    required this.cardBackground,
    required this.divider,
  });

  final Color success;
  final Color error;
  final Color warning;
  final Color neutral;
  final Color cardBackground;
  final Color divider;

  @override
  FinTechColors copyWith({
    Color? success,
    Color? error,
    Color? warning,
    Color? neutral,
    Color? cardBackground,
    Color? divider,
  }) {
    return FinTechColors(
      success: success ?? this.success,
      error: error ?? this.error,
      warning: warning ?? this.warning,
      neutral: neutral ?? this.neutral,
      cardBackground: cardBackground ?? this.cardBackground,
      divider: divider ?? this.divider,
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
      cardBackground: Color.lerp(cardBackground, other.cardBackground, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
    );
  }
}

extension FinTechColorsExtension on ThemeData {
  FinTechColors get finTechColors => extension<FinTechColors>()!;
}

import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'components/component_theme.dart';
import 'design_tokens/design_tokens.dart';
import 'design_tokens/typography.dart';
import 'schemes/color_schemes.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final ThemeData baseTheme = FlexThemeData.light(
      colorScheme: ColorSchemes.lightScheme,
      textTheme: AppTypography.lightTextTheme,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      platform: TargetPlatform.iOS, // Consistent across platforms

      subThemesData: const FlexSubThemesData(
        interactionEffects: true,
        tintedDisabledControls: true,
        blendOnLevel: 10,

        useM2StyleDividerInM3: true,

        inputDecoratorSchemeColor: SchemeColor.primary,
        inputDecoratorBorderSchemeColor: SchemeColor.outline,
        inputDecoratorRadius: DesignTokens.radiusMd,
        inputDecoratorBorderWidth: 1.0,
        inputDecoratorFocusedBorderWidth: 2.0,

        cardRadius: DesignTokens.radiusLg,
        cardElevation: DesignTokens.elevationCard,

        elevatedButtonRadius: DesignTokens.radiusMd,
        elevatedButtonElevation: 2.0,
        elevatedButtonSchemeColor: SchemeColor.primary,
        
        outlinedButtonRadius: DesignTokens.radiusMd,
        outlinedButtonBorderWidth: 1.5,
        
        textButtonRadius: DesignTokens.radiusMd,

        fabRadius: DesignTokens.radiusLg,
        fabUseShape: true,
        fabSchemeColor: SchemeColor.primary,

        appBarBackgroundSchemeColor: SchemeColor.surface,
        appBarScrolledUnderElevation: 4.0,

        navigationBarSelectedLabelSchemeColor: SchemeColor.primary,
        navigationBarSelectedIconSchemeColor: SchemeColor.primary,
        navigationBarIndicatorSchemeColor: SchemeColor.primaryContainer,

        dialogRadius: DesignTokens.radiusLg,
        dialogElevation: DesignTokens.elevationModal,

        switchSchemeColor: SchemeColor.primary,
        checkboxSchemeColor: SchemeColor.primary,
        radioSchemeColor: SchemeColor.primary,

        chipRadius: DesignTokens.radiusSm,
        chipSchemeColor: SchemeColor.primaryContainer,
      ),
    );

    return baseTheme.copyWith(
      extensions: <ThemeExtension<dynamic>>[
        ColorSchemes.finTechLight,
      ],
      
      appBarTheme: ComponentThemes.lightAppBarTheme,
      cardTheme: ComponentThemes.lightCardTheme,
      elevatedButtonTheme: ComponentThemes.lightElevatedButtonTheme,
      outlinedButtonTheme: ComponentThemes.lightOutlinedButtonTheme,
      textButtonTheme: ComponentThemes.lightTextButtonTheme,
      inputDecorationTheme: ComponentThemes.lightInputDecorationTheme,
      floatingActionButtonTheme: ComponentThemes.lightFabTheme,
      switchTheme: ComponentThemes.lightSwitchTheme,
      dividerTheme: ComponentThemes.lightDividerTheme,
    );
  }

  static ThemeData get dark {
    final ThemeData baseTheme = FlexThemeData.dark(
      colorScheme: ColorSchemes.darkScheme,
      textTheme: AppTypography.darkTextTheme,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      platform: TargetPlatform.iOS, // Consistent across platforms

      subThemesData: const FlexSubThemesData(
        interactionEffects: true,
        tintedDisabledControls: true,
        blendOnLevel: 20,

        useM2StyleDividerInM3: true,
        
        inputDecoratorSchemeColor: SchemeColor.primary,
        inputDecoratorBorderSchemeColor: SchemeColor.outline,
        inputDecoratorRadius: DesignTokens.radiusMd,
        inputDecoratorBorderWidth: 1.0,
        inputDecoratorFocusedBorderWidth: 2.0,

        cardRadius: DesignTokens.radiusLg,
        cardElevation: DesignTokens.elevationCard,

        elevatedButtonRadius: DesignTokens.radiusMd,
        elevatedButtonElevation: 2.0,
        elevatedButtonSchemeColor: SchemeColor.primary,
        
        outlinedButtonRadius: DesignTokens.radiusMd,
        outlinedButtonBorderWidth: 1.5,
        
        textButtonRadius: DesignTokens.radiusMd,

        fabRadius: DesignTokens.radiusLg,
        fabUseShape: true,
        fabSchemeColor: SchemeColor.primary,

        appBarBackgroundSchemeColor: SchemeColor.surface,
        appBarScrolledUnderElevation: 4.0,

        navigationBarSelectedLabelSchemeColor: SchemeColor.primary,
        navigationBarSelectedIconSchemeColor: SchemeColor.primary,
        navigationBarIndicatorSchemeColor: SchemeColor.primaryContainer,

        dialogRadius: DesignTokens.radiusLg,
        dialogElevation: DesignTokens.elevationModal,

        switchSchemeColor: SchemeColor.primary,
        checkboxSchemeColor: SchemeColor.primary,
        radioSchemeColor: SchemeColor.primary,

        chipRadius: DesignTokens.radiusSm,
        chipSchemeColor: SchemeColor.primaryContainer,
      ),
    );

    return baseTheme.copyWith(

      extensions: <ThemeExtension<dynamic>>[
        ColorSchemes.finTechDark,
      ],

      appBarTheme: ComponentThemes.darkAppBarTheme,
      cardTheme: ComponentThemes.darkCardTheme,
      elevatedButtonTheme: ComponentThemes.darkElevatedButtonTheme,
      outlinedButtonTheme: ComponentThemes.darkOutlinedButtonTheme,
      textButtonTheme: ComponentThemes.darkTextButtonTheme,
      inputDecorationTheme: ComponentThemes.darkInputDecorationTheme,
      floatingActionButtonTheme: ComponentThemes.darkFabTheme,
      switchTheme: ComponentThemes.darkSwitchTheme,
      dividerTheme: ComponentThemes.darkDividerTheme,
    );
  }

  static const SystemUiOverlayStyle lightSystemUiOverlayStyle = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarBrightness: Brightness.light,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: Color(0xFFFAFAFA),
    systemNavigationBarIconBrightness: Brightness.dark,
  );

  static const SystemUiOverlayStyle darkSystemUiOverlayStyle = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarBrightness: Brightness.dark,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF0A0A0A),
    systemNavigationBarIconBrightness: Brightness.light,
  );
}

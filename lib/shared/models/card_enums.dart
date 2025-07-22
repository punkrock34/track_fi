import '../../core/theme/design_tokens/design_tokens.dart';

enum FeatureCardStyle {
  compact(
    padding: DesignTokens.spacingSm,
    iconPadding: DesignTokens.spacingXs,
    iconSize: DesignTokens.iconSizeSm,
    spacing: DesignTokens.spacingXs,
    elevation: 1.0,
    showIconShadow: false,
  ),
  standard(
    padding: DesignTokens.spacingMd,
    iconPadding: DesignTokens.spacingSm,
    iconSize: DesignTokens.iconSizeMd,
    spacing: DesignTokens.spacingSm,
    elevation: 2.0,
    showIconShadow: true,
  ),
  large(
    padding: DesignTokens.spacingLg,
    iconPadding: DesignTokens.spacingMd,
    iconSize: DesignTokens.iconSizeLg,
    spacing: DesignTokens.spacingMd,
    elevation: 4.0,
    showIconShadow: true,
  );

  const FeatureCardStyle({
    required this.padding,
    required this.iconPadding,
    required this.iconSize,
    required this.spacing,
    required this.elevation,
    required this.showIconShadow,
  });

  final double padding;
  final double iconPadding;
  final double iconSize;
  final double spacing;
  final double elevation;
  final bool showIconShadow;
}

enum FinancialTrend {
  up,
  down,
  neutral,
}

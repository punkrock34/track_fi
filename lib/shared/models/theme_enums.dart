import '../../core/theme/design_tokens/design_tokens.dart';

enum ThemeToggleSize {
  small(
    padding: DesignTokens.spacingXs,
    spacing: DesignTokens.spacingXs,
    iconSize: DesignTokens.iconSizeSm,
    buttonPadding: DesignTokens.spacingXs,
    buttonMargin: DesignTokens.spacingXs,
  ),
  medium(
    padding: DesignTokens.spacingSm,
    spacing: DesignTokens.spacingSm,
    iconSize: DesignTokens.iconSizeMd,
    buttonPadding: DesignTokens.spacingSm,
    buttonMargin: DesignTokens.spacingXs,
  ),
  large(
    padding: DesignTokens.spacingLg,
    spacing: DesignTokens.spacingLg,
    iconSize: DesignTokens.iconSizeLg,
    buttonPadding: DesignTokens.spacingMd,
    buttonMargin: DesignTokens.spacingSm,
  );

  const ThemeToggleSize({
    required this.padding,
    required this.spacing,
    required this.iconSize,
    required this.buttonPadding,
    required this.buttonMargin,
  });

  final double padding;
  final double spacing;
  final double iconSize;
  final double buttonPadding;
  final double buttonMargin;
}

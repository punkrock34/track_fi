enum FeatureCardStyle {
  compact(
    padding: 12.0,
    iconPadding: 8.0,
    iconSize: 20.0,
    spacing: 8.0,
    elevation: 1.0,
    showIconShadow: false,
  ),
  standard(
    padding: 24.0,
    iconPadding: 12.0,
    iconSize: 24.0,
    spacing: 16.0,
    elevation: 2.0,
    showIconShadow: true,
  ),
  large(
    padding: 32.0,
    iconPadding: 16.0,
    iconSize: 32.0,
    spacing: 24.0,
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

enum ThemeToggleSize {
  small(
    padding: 8.0,
    spacing: 8.0,
    iconSize: 16.0,
    buttonPadding: 6.0,
    buttonMargin: 2.0,
  ),
  medium(
    padding: 12.0,
    spacing: 12.0,
    iconSize: 20.0,
    buttonPadding: 8.0,
    buttonMargin: 2.0,
  ),
  large(
    padding: 16.0,
    spacing: 16.0,
    iconSize: 24.0,
    buttonPadding: 10.0,
    buttonMargin: 3.0,
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

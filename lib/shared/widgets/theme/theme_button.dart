import 'package:flutter/material.dart';

import '../../../core/theme/design_tokens/design_tokens.dart';
import '../../models/theme_enums.dart';

class ThemeButton extends StatelessWidget {
  const ThemeButton({
    super.key,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    required this.size,
  });

  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final ThemeToggleSize size;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.all(size.buttonMargin),
        padding: EdgeInsets.all(size.buttonPadding),
        decoration: const BoxDecoration(
          color: Colors.transparent, // No background - indicator handles selection
          borderRadius: BorderRadius.all(Radius.circular(DesignTokens.radiusFull)),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 150), // Faster icon transition
          child: Icon(
            icon,
            key: ValueKey<bool>(isSelected), // Key for AnimatedSwitcher
            size: size.iconSize,
            color: isSelected
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.outline,
          ),
        ),
      ),
    );
  }
}

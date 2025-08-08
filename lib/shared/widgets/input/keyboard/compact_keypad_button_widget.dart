import 'package:flutter/material.dart';

class CompactKeypadButton extends StatelessWidget {
  const CompactKeypadButton({
    super.key,
    this.text,
    this.icon,
    required this.onPressed,
    this.isSpecial = false,
  });

  final String? text;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool isSpecial;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isEnabled = onPressed != null;

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isSpecial
              ? (isEnabled
                  ? theme.colorScheme.primaryContainer.withOpacity(0.3)
                  : theme.colorScheme.surface.withOpacity(0.5))
              : (isEnabled
                  ? theme.colorScheme.surface
                  : theme.colorScheme.surface.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: theme.colorScheme.outline.withOpacity(0.2),
          ),
        ),
        child: Center(
          child: text != null
              ? Text(
                  text!,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isEnabled
                        ? theme.colorScheme.onSurface
                        : theme.colorScheme.onSurface.withOpacity(0.38),
                  ),
                )
              : Icon(
                  icon,
                  size: 20,
                  color: isSpecial
                      ? (isEnabled
                          ? theme.colorScheme.primary
                          : theme.colorScheme.primary.withOpacity(0.38))
                      : (isEnabled
                          ? theme.colorScheme.onSurface
                          : theme.colorScheme.onSurface.withOpacity(0.38)),
                ),
        ),
      ),
    );
  }
}

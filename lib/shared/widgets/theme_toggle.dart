import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../core/theme/design_tokens/design_tokens.dart';
import '../../core/theme/providers/theme_provider.dart';

class ThemeToggle extends ConsumerWidget {
  const ThemeToggle({
    super.key,
    this.showLabel = true,
    this.size = ThemeToggleSize.medium,
  });

  final bool showLabel;
  final ThemeToggleSize size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeMode themeMode = ref.watch(themeProvider);
    final bool isDark = ref.watch(isDarkModeProvider);
    final ThemeData theme = Theme.of(context);

    return AnimatedContainer(
      duration: DesignTokens.durationMedium,
      curve: Curves.easeInOut,
      padding: EdgeInsets.all(size.padding),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (showLabel) ...<Widget>[
            Text(
              'Theme',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
            Gap(size.spacing),
          ],
          
          // Theme mode selector
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                _ThemeButton(
                  icon: Icons.light_mode_rounded,
                  isSelected: themeMode == ThemeMode.light,
                  onTap: () => ref.read(themeProvider.notifier).setThemeMode(ThemeMode.light),
                  size: size,
                ),
                _ThemeButton(
                  icon: Icons.auto_mode_rounded,
                  isSelected: themeMode == ThemeMode.system,
                  onTap: () => ref.read(themeProvider.notifier).setThemeMode(ThemeMode.system),
                  size: size,
                ),
                _ThemeButton(
                  icon: Icons.dark_mode_rounded,
                  isSelected: themeMode == ThemeMode.dark,
                  onTap: () => ref.read(themeProvider.notifier).setThemeMode(ThemeMode.dark),
                  size: size,
                ),
              ],
            ),
          ),
        ],
      ),
    )
        .animate(target: isDark ? 1 : 0)
        .tint(color: Colors.blue.withOpacity(0.1), curve: Curves.easeInOut);
  }
}

class _ThemeButton extends StatelessWidget {
  const _ThemeButton({
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
      child: AnimatedContainer(
        duration: DesignTokens.durationMedium,
        curve: Curves.easeInOut,
        margin: EdgeInsets.all(size.buttonMargin),
        padding: EdgeInsets.all(size.buttonPadding),
        decoration: BoxDecoration(
          color: isSelected 
              ? theme.colorScheme.primary
              : Colors.transparent,
          borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
          boxShadow: isSelected ? <BoxShadow>[
            BoxShadow(
              color: theme.colorScheme.primary.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ] : null,
        ),
        child: Icon(
          icon,
          size: size.iconSize,
          color: isSelected 
              ? theme.colorScheme.onPrimary
              : theme.colorScheme.onSurface.withOpacity(0.6),
        ),
      ),
    )
        .animate(target: isSelected ? 1 : 0)
        .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.0, 1.0))
        .fadeIn();
  }
}

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

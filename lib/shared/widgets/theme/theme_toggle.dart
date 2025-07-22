import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../core/providers/theme/theme_provider.dart';
import '../../../core/theme/design_tokens/design_tokens.dart';
import '../../models/theme_enums.dart';
import 'theme_button.dart';

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
    final ThemeData theme = Theme.of(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150), // Faster container animation
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
          // Fixed animation direction: outer container animates, inner buttons slide
          Stack(
            children: <Widget>[
              // Background container
              Container(
                width: size.iconSize * 3 + size.buttonPadding * 6 + size.buttonMargin * 6,
                height: size.iconSize + size.buttonPadding * 2 + size.buttonMargin * 2,
                decoration: BoxDecoration(
                  color: theme.colorScheme.background,
                  borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
                ),
              ),
              // Sliding indicator (outer to inner animation)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 200), // Faster slide
                curve: Curves.easeOutCubic,
                left: _getIndicatorPosition(themeMode, size),
                top: size.buttonMargin,
                child: Container(
                  width: size.iconSize + size.buttonPadding * 2,
                  height: size.iconSize + size.buttonPadding * 2,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: theme.colorScheme.primary.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
              // Button row
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ThemeButton(
                    icon: Icons.light_mode_rounded,
                    isSelected: themeMode == ThemeMode.light,
                    onTap: () =>
                        ref.read(themeProvider.notifier).setThemeMode(ThemeMode.light),
                    size: size,
                  ),
                  ThemeButton(
                    icon: Icons.auto_mode_rounded,
                    isSelected: themeMode == ThemeMode.system,
                    onTap: () =>
                        ref.read(themeProvider.notifier).setThemeMode(ThemeMode.system),
                    size: size,
                  ),
                  ThemeButton(
                    icon: Icons.dark_mode_rounded,
                    isSelected: themeMode == ThemeMode.dark,
                    onTap: () =>
                        ref.read(themeProvider.notifier).setThemeMode(ThemeMode.dark),
                    size: size,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  double _getIndicatorPosition(ThemeMode themeMode, ThemeToggleSize size) {
    final double buttonWidth = size.iconSize + size.buttonPadding * 2 + size.buttonMargin * 2;
    switch (themeMode) {
      case ThemeMode.light:
        return size.buttonMargin;
      case ThemeMode.system:
        return buttonWidth + size.buttonMargin;
      case ThemeMode.dark:
        return buttonWidth * 2 + size.buttonMargin;
    }
  }
}

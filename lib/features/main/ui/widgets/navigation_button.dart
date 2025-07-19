import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/design_tokens/design_tokens.dart';
import '../../models/navigation_item.dart';

class NavigationButton extends StatelessWidget {
  const NavigationButton({
    super.key,
    required this.item,
    required this.isSelected,
    required this.onTap,
    required this.animationDelay,
  });

  final NavigationItem item;
  final bool isSelected;
  final VoidCallback onTap;
  final Duration animationDelay;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        constraints: const BoxConstraints(
          minHeight: 56,
          maxWidth: 80, // Prevent labels from getting too wide
        ),
        padding: const EdgeInsets.symmetric(
          vertical: 4,
          horizontal: 2,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            AnimatedContainer(
              duration: DesignTokens.durationMedium,
              curve: Curves.easeInOut,
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colorScheme.primaryContainer.withOpacity(0.3)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
              ),
              child: Icon(
                isSelected ? item.activeIcon : item.icon,
                size: 22, // Slightly smaller to prevent overflow
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 2),
            AnimatedDefaultTextStyle(
              duration: DesignTokens.durationMedium,
              curve: Curves.easeInOut,
              style: theme.textTheme.labelSmall!.copyWith(
                fontSize: 10, // Smaller font to prevent overflow
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withOpacity(0.6),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
              child: Text(
                item.label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ).animate(delay: animationDelay)
       .slideY(begin: 0.3)
       .fadeIn(),
    );
  }
}

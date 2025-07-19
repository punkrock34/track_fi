import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../core/theme/design_tokens/design_tokens.dart';

class QuickActionButton extends StatelessWidget {
  const QuickActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.isPrimary = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: DesignTokens.spacingSm,
          horizontal: DesignTokens.spacingXs,
        ),
        decoration: BoxDecoration(
          color: isPrimary
              ? theme.colorScheme.primaryContainer.withOpacity(0.3)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          border: Border.all(
            color: theme.colorScheme.outline.withOpacity(0.2),
          ),
        ),
        child: Column(
          children: <Widget>[
            Icon(
              icon,
              color: isPrimary
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withOpacity(0.8),
            ),
            const Gap(DesignTokens.spacingXs),
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: isPrimary
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

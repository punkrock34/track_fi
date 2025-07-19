import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../core/theme/design_tokens/design_tokens.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.inbox_outlined,
    this.actionText,
    this.onAction,
  });

  final String title;
  final String message;
  final IconData icon;
  final String? actionText;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(DesignTokens.spacingMd),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              icon,
              size: 64,
              color: theme.colorScheme.onSurface.withOpacity(0.4),
            ),
            const Gap(DesignTokens.spacingMd),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const Gap(DesignTokens.spacingSm),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            if (actionText != null && onAction != null) ...<Widget>[
              const Gap(DesignTokens.spacingLg),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add),
                label: Text(actionText!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../core/theme/design_tokens/design_tokens.dart';

class ErrorState extends StatelessWidget {
  const ErrorState({
    super.key,
    required this.title,
    required this.message,
    this.onRetry,
    this.icon = Icons.error_outline,
  });

  final String title;
  final String message;
  final VoidCallback? onRetry;
  final IconData icon;

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
              color: theme.colorScheme.error,
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
            if (onRetry != null) ...<Widget>[
              const Gap(DesignTokens.spacingLg),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../../core/theme/design_tokens/design_tokens.dart';

class ErrorBanner extends StatelessWidget {
  const ErrorBanner({super.key, this.message});
  final String? message;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    if (message == null || message!.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      children: <Widget>[
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(DesignTokens.spacingSm),
          decoration: BoxDecoration(
            color: theme.colorScheme.errorContainer.withOpacity(0.1),
            borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
            border: Border.all(
              color: theme.colorScheme.error.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: <Widget>[
              Icon(Icons.error_outline,
                color: theme.colorScheme.error,
                size: 20,
              ),
              const Gap(DesignTokens.spacingXs),
              Expanded(
                child: Text(
                  message!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        const Gap(DesignTokens.spacingMd),
      ],
    );
  }
}

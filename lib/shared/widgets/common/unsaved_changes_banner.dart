import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../../core/theme/design_tokens/design_tokens.dart';

class UnsavedChangesBanner extends StatelessWidget {
  const UnsavedChangesBanner({
    super.key,
    required this.visible,
    this.message = 'You have unsaved changes',
  });
  final bool visible;
  final String message;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    if (!visible) {
      return const SizedBox.shrink();
    }

    return Column(
      children: <Widget>[
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(DesignTokens.spacingSm),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withOpacity(0.1),
            borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
            border: Border.all(
              color: theme.colorScheme.primary.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: <Widget>[
              Icon(
                Icons.edit,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              const Gap(DesignTokens.spacingXs),
              Text(message),
            ],
          ),
        ),
        const Gap(DesignTokens.spacingMd),
      ],
    );
  }
}

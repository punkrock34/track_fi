import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../core/theme/design_tokens/design_tokens.dart';
import '../../../../shared/utils/ui_utils.dart';

class TransactionInfoRow extends StatelessWidget {
  const TransactionInfoRow({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.isCopyable = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool isCopyable;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return InkWell(
      onTap: isCopyable ? () => UiUtils.copyToClipboard(context, subtitle) : null,
      borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: DesignTokens.spacingXs),
        child: Row(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
              ),
              child: Icon(
                icon,
                size: 20,
                color: theme.colorScheme.primary,
              ),
            ),
            const Gap(DesignTokens.spacingSm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Gap(2),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            if (isCopyable)
              Icon(
                Icons.copy_rounded,
                size: 16,
                color: theme.colorScheme.onSurface.withOpacity(0.4),
              ),
          ],
        ),
      ),
    );
  }
}

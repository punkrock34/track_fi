import 'package:flutter/material.dart' hide DateUtils;
import 'package:gap/gap.dart';

import '../../../../core/theme/design_tokens/design_tokens.dart';
import '../../../../shared/utils/date_utils.dart';

class TransactionInfoCard extends StatelessWidget {
  const TransactionInfoCard({
    super.key,
    this.isEdit = false,
    this.originalDate,
  });

  final bool isEdit;
  final DateTime? originalDate;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    
    final String title = isEdit ? 'Transaction Update' : 'Transaction Preview';
    final String description = isEdit
        ? 'Changes will update your account balance accordingly.${originalDate != null ? '\nOriginal: ${DateUtils.formatDateTime(originalDate!)}' : ''}'
        : 'This will be added to your selected account and update the balance accordingly.';
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(DesignTokens.spacingMd),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[
            theme.colorScheme.primaryContainer.withOpacity(0.1),
            theme.colorScheme.secondaryContainer.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
            ),
            child: Icon(
              Icons.info_outline,
              color: theme.colorScheme.primary,
              size: 20,
            ),
          ),
          const Gap(DesignTokens.spacingSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Gap(DesignTokens.spacing2xs),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../core/theme/design_tokens/design_tokens.dart';

class TransactionSkeleton extends StatelessWidget {
  const TransactionSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: DesignTokens.spacingXs),
      child: Row(
        children: <Widget>[
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
            ),
          ),
          const Gap(DesignTokens.spacingSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  height: 16,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                  ),
                ),
                const Gap(DesignTokens.spacing2xs),
                Container(
                  height: 12,
                  width: 100,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 16,
            width: 60,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
            ),
          ),
        ],
      ),
    );
  }
}

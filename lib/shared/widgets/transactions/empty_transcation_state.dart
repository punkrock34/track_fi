import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../core/theme/design_tokens/design_tokens.dart';

class EmptyTransactionsState extends StatelessWidget {
  const EmptyTransactionsState({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(DesignTokens.spacingMd),
        child: Column(
          children: <Widget>[
            Icon(
              Icons.receipt_long_outlined,
              size: 48,
              color: theme.colorScheme.onSurface.withOpacity(0.4),
            ),
            const Gap(DesignTokens.spacingSm),
            Text(
              'No transactions yet',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

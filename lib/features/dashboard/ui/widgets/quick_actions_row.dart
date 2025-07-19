import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../core/theme/design_tokens/design_tokens.dart';
import 'quick_action_button.dart';

class QuickActionsRow extends StatelessWidget {
  const QuickActionsRow({
    super.key,
    required this.onViewAccounts,
    required this.onViewTransactions,
    required this.onAddTransaction,
  });

  final VoidCallback onViewAccounts;
  final VoidCallback onViewTransactions;
  final VoidCallback onAddTransaction;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Quick Actions',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const Gap(DesignTokens.spacingSm),
        Row(
          children: <Widget>[
            Expanded(
              child: QuickActionButton(
                icon: Icons.account_balance_rounded,
                label: 'Accounts',
                onTap: onViewAccounts,
              ),
            ),
            const Gap(DesignTokens.spacingSm),
            Expanded(
              child: QuickActionButton(
                icon: Icons.receipt_long_rounded,
                label: 'Transactions',
                onTap: onViewTransactions,
              ),
            ),
            const Gap(DesignTokens.spacingSm),
            Expanded(
              child: QuickActionButton(
                icon: Icons.add_rounded,
                label: 'Add',
                onTap: onAddTransaction,
                isPrimary: true,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

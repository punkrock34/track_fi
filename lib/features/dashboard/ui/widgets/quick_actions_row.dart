import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../core/theme/design_tokens/design_tokens.dart';

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
              child: _QuickActionButton(
                icon: Icons.account_balance_rounded,
                label: 'Accounts',
                onTap: onViewAccounts,
              ),
            ),
            const Gap(DesignTokens.spacingSm),
            Expanded(
              child: _QuickActionButton(
                icon: Icons.receipt_long_rounded,
                label: 'Transactions',
                onTap: onViewTransactions,
              ),
            ),
            const Gap(DesignTokens.spacingSm),
            Expanded(
              child: _QuickActionButton(
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

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
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

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../core/models/database/transaction.dart';
import '../../../../core/theme/design_tokens/design_tokens.dart';
import '../../../../shared/widgets/transactions/transaction_list_item.dart';

class RecentTransactionsCard extends StatelessWidget {
  const RecentTransactionsCard({
    super.key,
    required this.transactions,
    required this.onViewAll,
    this.isLoading = false,
  });

  final List<Transaction> transactions;
  final VoidCallback onViewAll;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(DesignTokens.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Recent Transactions',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton(
                  onPressed: onViewAll,
                  child: const Text('View All'),
                ),
              ],
            ),
            const Gap(DesignTokens.spacingSm),
            if (isLoading)
              ...List<Widget>.generate(3, (int index) => _TransactionSkeleton())
            else if (transactions.isEmpty)
              const _EmptyTransactionsState()
            else
              ...transactions.take(5).map((Transaction transaction) =>
                Padding(
                  padding: const EdgeInsets.only(bottom: DesignTokens.spacingXs),
                  child: TransactionListItem(
                    transaction: transaction,
                    onTap: onViewAll, // Navigate to full transactions list
                    compact: true,
                    showCategory: false,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TransactionSkeleton extends StatelessWidget {
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

class _EmptyTransactionsState extends StatelessWidget {
  const _EmptyTransactionsState();

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

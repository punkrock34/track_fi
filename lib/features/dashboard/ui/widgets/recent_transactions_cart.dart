import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../../core/models/database/transaction.dart';
import '../../../../core/theme/design_tokens/design_tokens.dart';
import '../../../../shared/providers/ui/balance_visibility_provider.dart';
import '../../../../shared/widgets/transactions/empty_transcation_state.dart';
import '../../../../shared/widgets/transactions/transaction_list_item.dart';
import '../../../../shared/widgets/transactions/transaction_skeleton.dart';

class RecentTransactionsCard extends ConsumerWidget {
  const RecentTransactionsCard({
    super.key,
    required this.transactions,
    required this.onViewAll,
    this.isLoading = false,
    required this.onToggleVisibility,
  });

  final List<Transaction> transactions;
  final VoidCallback onViewAll;
  final bool isLoading;
  final VoidCallback onToggleVisibility;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final bool showBalance = ref.watch(balanceVisibilityProvider);
    
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
              ...List<Widget>.generate(3, (int index) => const TransactionSkeleton())
            else if (transactions.isEmpty)
              const EmptyTransactionsState()
            else
              ...transactions.take(5).map((Transaction transaction) =>
                Padding(
                  padding: const EdgeInsets.only(bottom: DesignTokens.spacingXs),
                  child: TransactionListItem(
                    transaction: transaction,
                    onTap: onViewAll, // Navigate to full transactions list
                    compact: true,
                    showCategory: false,
                    visible: showBalance,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart' hide DateUtils;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../../../core/models/database/account.dart';
import '../../../../../core/models/database/transaction.dart';
import '../../../../../core/theme/design_tokens/design_tokens.dart';
import '../../../../../core/theme/design_tokens/typography.dart';
import '../../../../../shared/utils/category_utils.dart';
import '../../../../../shared/utils/date_utils.dart';
import '../../../../../shared/utils/transaction_utils.dart';
import '../../../../../shared/utils/ui_utils.dart';
import '../../../../../shared/widgets/common/detail_row.dart';
import '../../../../../shared/widgets/states/error_state.dart';
import '../../../../../shared/widgets/states/loading_state.dart';
import '../../../accounts/providers/accounts_provider.dart';
import '../../providers/transactions_provider.dart';
import '../widgets/transaction_info_row.dart';

class TransactionDetailScreen extends ConsumerWidget {
  const TransactionDetailScreen({super.key, required this.transactionId});

  final String transactionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<Transaction?> transactionAsync = ref.watch(transactionProvider(transactionId));

    return Scaffold(
      body: transactionAsync.when(
        loading: () => _buildLoadingState(context),
        error: (Object error, StackTrace stackTrace) => _buildErrorState(context, error),
        data: (Transaction? transaction) {
          if (transaction == null) {
            return _buildNotFoundState(context);
          }
          return _buildTransactionDetail(context, ref, transaction);
        },
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction Details'),
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: const LoadingState(),
    );
  }

  Widget _buildErrorState(BuildContext context, Object error) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction Details'),
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: ErrorState(
        title: 'Failed to load transaction',
        message: error.toString(),
      ),
    );
  }

  Widget _buildNotFoundState(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction Details'),
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: const ErrorState(
        title: 'Transaction not found',
        message: 'The transaction you are looking for does not exist.',
        icon: Icons.receipt_long_outlined,
      ),
    );
  }

  Widget _buildTransactionDetail(BuildContext context, WidgetRef ref, Transaction transaction) {
    final ThemeData theme = Theme.of(context);
    final AsyncValue<Account?> accountAsync = ref.watch(accountProvider(transaction.accountId));

    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          // App Bar with Transaction Amount
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: theme.colorScheme.surface,
            actions: <Widget>[
              IconButton(
                icon: const Icon(Icons.share_rounded),
                onPressed: () => _shareTransaction(context, transaction),
                color: Colors.white,
              ),
              _buildMenuButton(context, transaction),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: <Color>[
                      TransactionUtils.getTransactionColor(transaction.type, theme),
                      TransactionUtils.getTransactionColor(transaction.type, theme).withOpacity(0.8),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(DesignTokens.spacingMd),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Container(
                          padding: const EdgeInsets.all(DesignTokens.spacingXs),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                          ),
                          child: Icon(
                            TransactionUtils.getTransactionIcon(transaction.description),
                            color: Colors.white,
                            size: 32,
                          ),
                        ).animate().scale(delay: 100.ms, curve: Curves.easeOutBack),
                        const Gap(DesignTokens.spacingSm),
                        Text(
                          transaction.description,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ).animate().slideX(begin: -0.3, delay: 200.ms).fadeIn(),
                        const Gap(DesignTokens.spacingXs),
                        Text(
                          TransactionUtils.formatAmountWithSign(transaction),
                          style: AppTypography.moneyLarge.copyWith(
                            color: Colors.white,
                          ),
                        ).animate().slideX(begin: -0.3, delay: 300.ms).fadeIn(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Transaction Details Card
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(DesignTokens.spacingMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Transaction Details',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ).animate().slideY(begin: 0.3, delay: 400.ms).fadeIn(),
                  const Gap(DesignTokens.spacingSm),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(DesignTokens.spacingMd),
                      child: Column(
                        children: <Widget>[
                          DetailRow(
                            label: 'Type',
                            value: TransactionUtils.formatTransactionType(transaction.type),
                            valueColor: TransactionUtils.getTransactionColor(transaction.type, theme),
                          ),
                          DetailRow(
                            label: 'Amount',
                            value: '£${transaction.amount.abs().toStringAsFixed(2)}',
                            isMonetary: true,
                          ),
                          DetailRow(
                            label: 'Date & Time',
                            value: DateUtils.formatDateTime(transaction.transactionDate),
                          ),
                          DetailRow(
                            label: 'Account',
                            value: accountAsync.when(
                              data: (Account? account) => account?.name ?? 'Unknown Account',
                              loading: () => 'Loading...',
                              error: (_, _) => 'Unknown Account',
                            ),
                            onTap: accountAsync.value != null ? () => _navigateToAccount(context, transaction.accountId) : null,
                          ),
                          if (transaction.reference != null)
                            DetailRow(
                              label: 'Reference',
                              value: transaction.reference!,
                              isCopyable: true,
                            ),
                          if (transaction.balanceAfter != null)
                            DetailRow(
                              label: 'Balance After',
                              value: '£${transaction.balanceAfter!.toStringAsFixed(2)}',
                              isMonetary: true,
                            ),
                          if (transaction.categoryId != null)
                            DetailRow(
                              label: 'Category',
                              value: CategoryUtils.getCategoryName(transaction.categoryId!),
                              icon: CategoryUtils.getCategoryIcon(transaction.categoryId!),
                            ),
                          DetailRow(
                            label: 'Status',
                            value: TransactionUtils.formatStatus(transaction.status),
                            valueColor: TransactionUtils.getStatusColor(transaction.status, theme),
                          ),
                          DetailRow(
                            label: 'Transaction ID',
                            value: transaction.id,
                            isCopyable: true,
                            isMonospace: true,
                          ),
                          DetailRow(
                            label: 'Created',
                            value: DateUtils.formatDateTime(transaction.createdAt),
                            showDivider: transaction.syncedAt != null,
                          ),
                          if (transaction.syncedAt != null)
                            DetailRow(
                              label: 'Last Synced',
                              value: DateUtils.formatDateTime(transaction.syncedAt!),
                              showDivider: false,
                            ),
                        ],
                      ),
                    ),
                  ).animate().slideY(begin: 0.3, delay: 500.ms).fadeIn(),
                ],
              ),
            ),
          ),

          // Additional Information Section
          if (transaction.balanceAfter != null || transaction.reference != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spacingMd),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Gap(DesignTokens.spacingMd),
                    Text(
                      'Additional Information',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ).animate().slideY(begin: 0.3, delay: 600.ms).fadeIn(),
                    const Gap(DesignTokens.spacingSm),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(DesignTokens.spacingMd),
                        child: Column(
                          children: <Widget>[
                            if (transaction.balanceAfter != null)
                              TransactionInfoRow(
                                icon: Icons.account_balance_wallet_rounded,
                                title: 'Account Balance After Transaction',
                                subtitle: '£${transaction.balanceAfter!.toStringAsFixed(2)}',
                              ),
                            if (transaction.reference != null && transaction.balanceAfter != null)
                              const Divider(),
                            if (transaction.reference != null)
                              TransactionInfoRow(
                                icon: Icons.receipt_long_rounded,
                                title: 'Payment Reference',
                                subtitle: transaction.reference!,
                                isCopyable: true,
                              ),
                          ],
                        ),
                      ),
                    ).animate().slideY(begin: 0.3, delay: 700.ms).fadeIn(),
                  ],
                ),
              ),
            ),

          // Bottom spacing
          const SliverToBoxAdapter(
            child: Gap(DesignTokens.spacingXl),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context, Transaction transaction) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert_rounded, color: Colors.white),
      onSelected: (String value) => _handleMenuAction(context, value, transaction),
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: 'copy_reference',
          child: ListTile(
            leading: Icon(Icons.copy_rounded),
            title: Text('Copy Reference'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        const PopupMenuItem<String>(
          value: 'copy_amount',
          child: ListTile(
            leading: Icon(Icons.monetization_on_rounded),
            title: Text('Copy Amount'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        if (transaction.balanceAfter != null)
          const PopupMenuItem<String>(
            value: 'copy_balance',
            child: ListTile(
              leading: Icon(Icons.account_balance_rounded),
              title: Text('Copy Balance'),
              contentPadding: EdgeInsets.zero,
            ),
          ),
        const PopupMenuDivider(),
        const PopupMenuItem<String>(
          value: 'edit',
          child: ListTile(
            leading: Icon(Icons.edit_rounded),
            title: Text('Edit Transaction'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        const PopupMenuItem<String>(
          value: 'delete',
          child: ListTile(
            leading: Icon(Icons.delete_rounded, color: Colors.red),
            title: Text('Delete Transaction', style: TextStyle(color: Colors.red)),
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }

  void _shareTransaction(BuildContext context, Transaction transaction) {
    final String shareText = '''
Transaction Details:
${transaction.description}
Amount: ${TransactionUtils.formatAmountWithSign(transaction)}
Date: ${DateUtils.formatDateTime(transaction.transactionDate)}
${transaction.reference != null ? 'Reference: ${transaction.reference}' : ''}
''';

    UiUtils.showComingSoon(context, 'Share functionality');
    UiUtils.copyToClipboard(context, shareText);
  }

  void _handleMenuAction(BuildContext context, String action, Transaction transaction) {
    switch (action) {
      case 'copy_reference':
        if (transaction.reference != null) {
          UiUtils.copyToClipboard(context, transaction.reference!);
        }
      case 'copy_amount':
        UiUtils.copyToClipboard(context, '£${transaction.amount.abs().toStringAsFixed(2)}');
      case 'copy_balance':
        if (transaction.balanceAfter != null) {
          UiUtils.copyToClipboard(context, '£${transaction.balanceAfter!.toStringAsFixed(2)}');
        }
      case 'edit':
        UiUtils.showComingSoon(context, 'Edit Transaction');
      case 'delete':
        _showDeleteConfirmation(context, transaction);
    }
  }
  Future<void> _showDeleteConfirmation(BuildContext context, Transaction transaction) async {
    final NavigatorState navigator = Navigator.of(context);
    final bool confirmed = (await UiUtils.showConfirmationDialog(
      context,
      title: 'Delete Transaction',
      message: 'Are you sure you want to delete "${transaction.description}"? This action cannot be undone.',
      confirmText: 'Delete',
      isDestructive: true,
    )) ?? false;

    if (!confirmed || !navigator.mounted) {
      return;
    }

    UiUtils.showComingSoon(navigator.context, 'Delete Transaction');
  }

  void _navigateToAccount(BuildContext context, String accountId) {
    Navigator.of(context).pushNamed('/accounts/$accountId');
  }
}

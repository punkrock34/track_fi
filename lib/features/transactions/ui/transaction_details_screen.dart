// lib/features/transactions/ui/transaction_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../core/models/database/account.dart';
import '../../../core/models/database/transaction.dart';
import '../../../core/theme/design_tokens/design_tokens.dart';
import '../../../core/theme/design_tokens/typography.dart';
import '../../accounts/providers/accounts_provider.dart';
import '../providers/transactions_provider.dart';

class TransactionDetailScreen extends ConsumerWidget {
  const TransactionDetailScreen({super.key, required this.transactionId});

  final String transactionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<Transaction?> transactionAsync = ref.watch(transactionProvider(transactionId));
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      body: transactionAsync.when(
        loading: () => _buildLoadingState(theme),
        error: (Object error, StackTrace stackTrace) => _buildErrorState(error, theme),
        data: (Transaction? transaction) {
          if (transaction == null) {
            return _buildNotFoundState(theme);
          }
          return _buildTransactionDetail(context, ref, transaction, theme);
        },
      ),
    );
  }

  Widget _buildLoadingState(ThemeData theme) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction Details'),
        backgroundColor: theme.colorScheme.surface,
      ),
      body: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorState(Object error, ThemeData theme) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction Details'),
        backgroundColor: theme.colorScheme.surface,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(DesignTokens.spacingMd),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.error_outline,
                size: 64,
                color: theme.colorScheme.error,
              ),
              const Gap(DesignTokens.spacingMd),
              Text(
                'Failed to load transaction',
                style: theme.textTheme.titleLarge,
              ),
              const Gap(DesignTokens.spacingSm),
              Text(
                error.toString(),
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotFoundState(ThemeData theme) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction Details'),
        backgroundColor: theme.colorScheme.surface,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(DesignTokens.spacingMd),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.receipt_long_outlined,
                size: 64,
                color: theme.colorScheme.onSurface.withOpacity(0.4),
              ),
              const Gap(DesignTokens.spacingMd),
              Text(
                'Transaction not found',
                style: theme.textTheme.titleLarge,
              ),
              const Gap(DesignTokens.spacingSm),
              Text(
                'The transaction you are looking for does not exist.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionDetail(BuildContext context, WidgetRef ref, Transaction transaction, ThemeData theme) {
    final bool isDebit = transaction.type == TransactionType.debit;
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
              PopupMenuButton<String>(
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
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: <Color>[
                      if (isDebit) theme.colorScheme.error else theme.colorScheme.primary,
                      if (isDebit) theme.colorScheme.error.withOpacity(0.8) else theme.colorScheme.secondary,
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
                            _getTransactionIcon(transaction.description),
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
                          '${isDebit ? '-' : '+'}£${transaction.amount.abs().toStringAsFixed(2)}',
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
                          _DetailRow(
                            label: 'Type',
                            value: isDebit ? 'Expense' : 'Income',
                            valueColor: isDebit ? theme.colorScheme.error : theme.colorScheme.primary,
                          ),
                          _DetailRow(
                            label: 'Amount',
                            value: '£${transaction.amount.abs().toStringAsFixed(2)}',
                            isMonetary: true,
                          ),
                          _DetailRow(
                            label: 'Date & Time',
                            value: _formatDateTime(transaction.transactionDate),
                          ),
                          _DetailRow(
                            label: 'Account',
                            value: accountAsync.when(
                              data: (Account? account) => account?.name ?? 'Unknown Account',
                              loading: () => 'Loading...',
                              error: (_, _) => 'Unknown Account',
                            ),
                            onTap: accountAsync.value != null ? () => _navigateToAccount(context, transaction.accountId) : null,
                          ),
                          if (transaction.reference != null)
                            _DetailRow(
                              label: 'Reference',
                              value: transaction.reference!,
                              isCopyable: true,
                            ),
                          if (transaction.balanceAfter != null)
                            _DetailRow(
                              label: 'Balance After',
                              value: '£${transaction.balanceAfter!.toStringAsFixed(2)}',
                              isMonetary: true,
                            ),
                          if (transaction.categoryId != null)
                            _DetailRow(
                              label: 'Category',
                              value: _getCategoryName(transaction.categoryId!),
                              showCategoryIcon: true,
                              categoryId: transaction.categoryId,
                            ),
                          _DetailRow(
                            label: 'Status',
                            value: _formatStatus(transaction.status),
                            valueColor: _getStatusColor(transaction.status, theme),
                          ),
                          _DetailRow(
                            label: 'Transaction ID',
                            value: transaction.id,
                            isCopyable: true,
                            isMonospace: true,
                          ),
                          _DetailRow(
                            label: 'Created',
                            value: _formatDateTime(transaction.createdAt),
                            showDivider: transaction.syncedAt != null,
                          ),
                          if (transaction.syncedAt != null)
                            _DetailRow(
                              label: 'Last Synced',
                              value: _formatDateTime(transaction.syncedAt!),
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

          // Related Information Section (if applicable)
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
                              _InfoRow(
                                icon: Icons.account_balance_wallet_rounded,
                                title: 'Account Balance After Transaction',
                                subtitle: '£${transaction.balanceAfter!.toStringAsFixed(2)}',
                                theme: theme,
                              ),
                            if (transaction.reference != null && transaction.balanceAfter != null)
                              const Divider(),
                            if (transaction.reference != null)
                              _InfoRow(
                                icon: Icons.receipt_long_rounded,
                                title: 'Payment Reference',
                                subtitle: transaction.reference!,
                                theme: theme,
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

  IconData _getTransactionIcon(String description) {
    final String lowerDesc = description.toLowerCase();
    
    if (lowerDesc.contains('grocery') || lowerDesc.contains('supermarket') || lowerDesc.contains('food')) {
      return Icons.shopping_cart_rounded;
    } else if (lowerDesc.contains('gas') || lowerDesc.contains('fuel') || lowerDesc.contains('petrol')) {
      return Icons.local_gas_station_rounded;
    } else if (lowerDesc.contains('restaurant') || lowerDesc.contains('cafe') || lowerDesc.contains('dining')) {
      return Icons.restaurant_rounded;
    } else if (lowerDesc.contains('transfer') || lowerDesc.contains('payment')) {
      return Icons.swap_horiz_rounded;
    } else if (lowerDesc.contains('salary') || lowerDesc.contains('income')) {
      return Icons.work_rounded;
    } else if (lowerDesc.contains('atm') || lowerDesc.contains('cash')) {
      return Icons.local_atm_rounded;
    } else if (lowerDesc.contains('subscription') || lowerDesc.contains('recurring')) {
      return Icons.repeat_rounded;
    } else {
      return Icons.receipt_rounded;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatStatus(String status) {
    return status.split('_').map((String word) => 
        word[0].toUpperCase() + word.substring(1).toLowerCase()).join(' ');
  }

  Color _getStatusColor(String status, ThemeData theme) {
    switch (status.toLowerCase()) {
      case 'completed':
        return theme.colorScheme.primary;
      case 'pending':
        return Colors.orange;
      case 'failed':
        return theme.colorScheme.error;
      default:
        return theme.colorScheme.onSurface.withOpacity(0.7);
    }
  }

  String _getCategoryName(String categoryId) {
    switch (categoryId) {
      case 'cat_income_salary':
        return 'Salary';
      case 'cat_expense_groceries':
        return 'Groceries';
      case 'cat_expense_transport':
        return 'Transport';
      case 'cat_expense_dining':
        return 'Dining Out';
      case 'cat_transfer_internal':
        return 'Transfer';
      default:
        return 'Other';
    }
  }

  void _shareTransaction(BuildContext context, Transaction transaction) {
    final String shareText = '''
Transaction Details:
${transaction.description}
Amount: £${transaction.amount.abs().toStringAsFixed(2)}
Date: ${_formatDateTime(transaction.transactionDate)}
${transaction.reference != null ? 'Reference: ${transaction.reference}' : ''}
''';

    // In a real app, you would use the share_plus package
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Share functionality coming soon!'),
        action: SnackBarAction(
          label: 'Copy',
          onPressed: () => _copyToClipboard(context, shareText),
        ),
      ),
    );
  }

  void _handleMenuAction(BuildContext context, String action, Transaction transaction) {
    switch (action) {
      case 'copy_reference':
        if (transaction.reference != null) {
          _copyToClipboard(context, transaction.reference!);
        }
      case 'copy_amount':
        _copyToClipboard(context, '£${transaction.amount.abs().toStringAsFixed(2)}');
      case 'copy_balance':
        if (transaction.balanceAfter != null) {
          _copyToClipboard(context, '£${transaction.balanceAfter!.toStringAsFixed(2)}');
        }
      case 'edit':
        _showComingSoon(context, 'Edit Transaction');
      case 'delete':
        _showDeleteConfirmation(context, transaction);
    }
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature coming soon!'),
        action: SnackBarAction(
          label: 'OK',
          onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Transaction transaction) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Transaction'),
          content: Text(
            'Are you sure you want to delete "${transaction.description}"? This action cannot be undone.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showComingSoon(context, 'Delete Transaction');
              },
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _navigateToAccount(BuildContext context, String accountId) {
    Navigator.of(context).pushNamed('/accounts/$accountId');
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.showDivider = true,
    this.isMonetary = false,
    this.isCopyable = false,
    this.isMonospace = false,
    this.valueColor,
    this.onTap,
    this.showCategoryIcon = false,
    this.categoryId,
  });

  final String label;
  final String value;
  final bool showDivider;
  final bool isMonetary;
  final bool isCopyable;
  final bool isMonospace;
  final Color? valueColor;
  final VoidCallback? onTap;
  final bool showCategoryIcon;
  final String? categoryId;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    
    return Column(
      children: <Widget>[
        InkWell(
          onTap: onTap ?? (isCopyable ? () => _copyValue(context) : null),
          borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                Flexible(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      if (showCategoryIcon && categoryId != null) ...<Widget>[
                        Icon(
                          _getCategoryIcon(categoryId!),
                          size: 16,
                          color: theme.colorScheme.primary,
                        ),
                        const Gap(DesignTokens.spacing2xs),
                      ],
                      Flexible(
                        child: Text(
                          value,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: isMonetary ? FontWeight.w600 : FontWeight.w500,
                            color: valueColor ?? theme.colorScheme.onSurface,
                            fontFamily: isMonospace ? 'monospace' : null,
                            fontFeatures: isMonetary ? const <FontFeature>[FontFeature.tabularFigures()] : null,
                          ),
                          textAlign: TextAlign.end,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isCopyable || onTap != null) ...<Widget>[
                        const Gap(DesignTokens.spacing2xs),
                        Icon(
                          isCopyable ? Icons.copy_rounded : Icons.chevron_right_rounded,
                          size: 16,
                          color: theme.colorScheme.onSurface.withOpacity(0.4),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (showDivider) ...<Widget>[
          const Gap(DesignTokens.spacingSm),
          const Divider(height: 1),
          const Gap(DesignTokens.spacingSm),
        ],
      ],
    );
  }

  IconData _getCategoryIcon(String categoryId) {
    switch (categoryId) {
      case 'cat_income_salary':
        return Icons.work_rounded;
      case 'cat_expense_groceries':
        return Icons.shopping_cart_rounded;
      case 'cat_expense_transport':
        return Icons.directions_car_rounded;
      case 'cat_expense_dining':
        return Icons.restaurant_rounded;
      case 'cat_transfer_internal':
        return Icons.swap_horiz_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  void _copyValue(BuildContext context) {
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.theme,
    this.isCopyable = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final ThemeData theme;
  final bool isCopyable;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isCopyable ? () => _copyValue(context) : null,
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

  void _copyValue(BuildContext context) {
    Clipboard.setData(ClipboardData(text: subtitle));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}

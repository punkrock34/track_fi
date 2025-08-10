import 'package:flutter/material.dart' hide DateUtils;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../../core/models/database/account.dart';
import '../../../../core/models/database/transaction.dart';
import '../../../../core/theme/design_tokens/design_tokens.dart';
import '../../../../core/theme/design_tokens/typography.dart';
import '../../../../shared/utils/category_utils.dart';
import '../../../../shared/utils/currency_utils.dart';
import '../../../../shared/utils/date_utils.dart';
import '../../../../shared/utils/transaction_utils.dart';
import '../../../../shared/utils/ui_utils.dart';
import '../../../accounts/providers/accounts_provider.dart';

class TransactionDetailsView extends ConsumerWidget {
  const TransactionDetailsView({
    super.key,
    required this.transaction,
    required this.onEdit,
    required this.onDelete,
    required this.onNavigateToAccount,
  });

  final Transaction transaction;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onNavigateToAccount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final AsyncValue<Account?> accountAsync = ref.watch(accountProvider(transaction.accountId));
    final String currencySymbol = accountAsync.maybeWhen(
      data: (Account? account) => CurrencyUtils.getCurrencySymbol(account?.currency ?? 'RON'),
      orElse: () => CurrencyUtils.getCurrencySymbol('RON'),
    );
    final Color typeColor = TransactionUtils.getTransactionColor(transaction.type, theme);

    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          // Hero App Bar with Transaction Summary
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: typeColor.withOpacity(0.05),
            foregroundColor: theme.colorScheme.onSurface,
            elevation: 0,
            actions: <Widget>[
              PopupMenuButton<String>(
                onSelected: (String value) => _handleMenuAction(context, value),
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'copy_reference',
                    child: ListTile(
                      leading: Icon(Icons.copy_outlined),
                      title: Text('Copy Reference'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'copy_amount',
                    child: ListTile(
                      leading: Icon(Icons.monetization_on_outlined),
                      title: Text('Copy Amount'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem<String>(
                    value: 'edit',
                    child: ListTile(
                      leading: Icon(Icons.edit_outlined),
                      title: Text('Edit Transaction'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'delete',
                    child: ListTile(
                      leading: Icon(Icons.delete_outline, color: Colors.red),
                      title: Text('Delete Transaction', style: TextStyle(color: Colors.red)),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: _buildHeroSection(context, theme, typeColor, currencySymbol),
            ),
          ),

          // Content Section
          SliverPadding(
            padding: const EdgeInsets.all(DesignTokens.spacingMd),
            sliver: SliverList(
              delegate: SliverChildListDelegate(<Widget>[
                // Quick Actions
                _buildQuickActions(context, theme, typeColor)
                    .animate()
                    .slideY(begin: 0.3, delay: 100.ms)
                    .fadeIn(),
                
                const Gap(DesignTokens.spacingLg),
                
                // Transaction Details
                _buildDetailsSection(context, theme, accountAsync)
                    .animate()
                    .slideY(begin: 0.3, delay: 200.ms)
                    .fadeIn(),
                
                if (transaction.reference != null || transaction.balanceAfter != null) ...<Widget>[
                  const Gap(DesignTokens.spacingLg),
                  _buildAdditionalSection(context, theme)
                      .animate()
                      .slideY(begin: 0.3, delay: 300.ms)
                      .fadeIn(),
                ],
                
                const Gap(DesignTokens.spacingXl),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context, ThemeData theme, Color typeColor, String currencySymbol) {
    return Container(
      padding: const EdgeInsets.all(DesignTokens.spacingLg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Gap(kToolbarHeight),
          
          // Transaction Icon & Type
          Row(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(DesignTokens.spacingMd),
                decoration: BoxDecoration(
                  color: typeColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
                ),
                child: Icon(
                  TransactionUtils.getTransactionIcon(transaction.description),
                  color: typeColor,
                  size: 32,
                ),
              ),
              const Gap(DesignTokens.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      TransactionUtils.formatTransactionType(transaction.type),
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: typeColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      DateUtils.formatDateTime(transaction.transactionDate),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const Gap(DesignTokens.spacingLg),
          
          // Transaction Description
          Text(
            transaction.description,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
          ),
          
          const Gap(DesignTokens.spacingXs),
          
          // Amount
          Text(
            TransactionUtils.formatAmountWithSign(transaction, currency: currencySymbol),
            style: AppTypography.moneyLarge.copyWith(
              color: typeColor,
              fontSize: 36,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, ThemeData theme, Color typeColor) {
    return Row(
      children: <Widget>[
        Expanded(
          child: _buildActionChip(
            context,
            theme,
            icon: Icons.edit_outlined,
            label: 'Edit',
            onTap: onEdit,
            isPrimary: true,
            color: typeColor,
          ),
        ),
        const Gap(DesignTokens.spacingSm),
        Expanded(
          child: _buildActionChip(
            context,
            theme,
            icon: Icons.copy_outlined,
            label: 'Copy ID',
            onTap: () => UiUtils.copyToClipboard(context, transaction.id),
          ),
        ),
      ],
    );
  }

  Widget _buildActionChip(
    BuildContext context,
    ThemeData theme, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isPrimary = false,
    Color? color,
  }) {
    final Color chipColor = isPrimary && color != null 
        ? color 
        : theme.colorScheme.primary;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: DesignTokens.spacingMd,
          horizontal: DesignTokens.spacingSm,
        ),
        decoration: BoxDecoration(
          color: isPrimary 
              ? chipColor.withOpacity(0.1)
              : theme.colorScheme.surfaceVariant.withOpacity(0.5),
          borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
          border: isPrimary 
              ? Border.all(color: chipColor.withOpacity(0.3))
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              icon,
              color: isPrimary ? chipColor : theme.colorScheme.onSurfaceVariant,
              size: 24,
            ),
            const Gap(DesignTokens.spacingXs),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isPrimary ? chipColor : theme.colorScheme.onSurfaceVariant,
                fontWeight: isPrimary ? FontWeight.w600 : FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsSection(BuildContext context, ThemeData theme, AsyncValue<Account?> accountAsync) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Details',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const Gap(DesignTokens.spacingMd),
        
        _buildDetailTile(
          context,
          theme,
          icon: Icons.monetization_on_outlined,
          title: 'Amount',
          subtitle: '£${transaction.amount.abs().toStringAsFixed(2)}',
        ),
        
        _buildDetailTile(
          context,
          theme,
          icon: Icons.account_balance_outlined,
          title: 'Account',
          subtitle: accountAsync.when(
            data: (Account? account) => account?.name ?? 'Unknown Account',
            loading: () => 'Loading...',
            error: (_, _) => 'Unknown Account',
          ),
          onTap: accountAsync.value != null ? onNavigateToAccount : null,
        ),
        
        if (transaction.categoryId != null)
          _buildDetailTile(
            context,
            theme,
            icon: CategoryUtils.getCategoryIcon(transaction.categoryId!),
            title: 'Category',
            subtitle: CategoryUtils.getCategoryName(transaction.categoryId!),
          ),
        
        _buildDetailTile(
          context,
          theme,
          icon: Icons.info_outline,
          title: 'Status',
          subtitle: TransactionUtils.formatStatus(transaction.status),
          subtitleColor: TransactionUtils.getStatusColor(transaction.status, theme),
        ),
        
        _buildDetailTile(
          context,
          theme,
          icon: Icons.fingerprint_outlined,
          title: 'Transaction ID',
          subtitle: transaction.id,
          onCopy: () => UiUtils.copyToClipboard(context, transaction.id),
          isLast: true,
        ),
      ],
    );
  }

  Widget _buildAdditionalSection(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Additional Information',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const Gap(DesignTokens.spacingMd),
        
        if (transaction.reference != null)
          _buildDetailTile(
            context,
            theme,
            icon: Icons.receipt_long_outlined,
            title: 'Reference',
            subtitle: transaction.reference!,
            onCopy: () => UiUtils.copyToClipboard(context, transaction.reference!),
            isLast: transaction.balanceAfter == null,
          ),
        
        if (transaction.balanceAfter != null)
          _buildDetailTile(
            context,
            theme,
            icon: Icons.account_balance_wallet_outlined,
            title: 'Balance After',
            subtitle: '£${transaction.balanceAfter!.toStringAsFixed(2)}',
            isLast: true,
          ),
      ],
    );
  }

  Widget _buildDetailTile(
    BuildContext context,
    ThemeData theme, {
    required IconData icon,
    required String title,
    required String subtitle,
    Color? subtitleColor,
    VoidCallback? onTap,
    VoidCallback? onCopy,
    bool isLast = false,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : DesignTokens.spacingSm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
        child: Container(
          padding: const EdgeInsets.all(DesignTokens.spacingMd),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
            borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          ),
          child: Row(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(DesignTokens.spacingSm),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
              ),
              const Gap(DesignTokens.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Gap(DesignTokens.spacingXs),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: subtitleColor ?? theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              if (onCopy != null) ...<Widget>[
                const Gap(DesignTokens.spacingSm),
                InkWell(
                  onTap: onCopy,
                  borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
                  child: Padding(
                    padding: const EdgeInsets.all(DesignTokens.spacingXs),
                    child: Icon(
                      Icons.copy_outlined,
                      size: 18,
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ),
              ],
              if (onTap != null) ...<Widget>[
                const Gap(DesignTokens.spacingSm),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: theme.colorScheme.onSurface.withOpacity(0.4),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _handleMenuAction(BuildContext context, String action) {
    switch (action) {
      case 'copy_reference':
        if (transaction.reference != null) {
          UiUtils.copyToClipboard(context, transaction.reference!);
        }
      case 'copy_amount':
        UiUtils.copyToClipboard(context, '£${transaction.amount.abs().toStringAsFixed(2)}');
      case 'edit':
        onEdit();
      case 'delete':
        onDelete();
    }
  }
}

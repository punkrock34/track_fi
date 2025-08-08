import 'package:flutter/material.dart' hide DateUtils;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/models/database/account.dart';
import '../../../../core/models/database/transaction.dart';
import '../../../../core/providers/currency/currency_exchange_service_provider.dart';
import '../../../../core/providers/database/storage/transaction_storage_service_provider.dart';
import '../../../../core/theme/design_tokens/design_tokens.dart';
import '../../../../shared/providers/ui/balance_visibility_provider.dart';
import '../../../../shared/utils/date_utils.dart';
import '../../../../shared/utils/ui_utils.dart';
import '../../../../shared/widgets/dashboard/account_balance_card.dart';
import '../../../../shared/widgets/states/empty_state.dart';
import '../../../../shared/widgets/states/error_state.dart';
import '../../../../shared/widgets/states/loading_state.dart';
import '../../../../shared/widgets/transactions/transaction_list_item.dart';

class AccountDetailsView extends ConsumerStatefulWidget {
  const AccountDetailsView({
    super.key,
    required this.account,
    required this.onAddTransaction,
    required this.onEditAccount,
    required this.onDeleteAccount,
  });

  final Account account;
  final VoidCallback onAddTransaction;
  final VoidCallback onEditAccount;
  final VoidCallback onDeleteAccount;

  @override
  ConsumerState<AccountDetailsView> createState() => _AccountDetailsViewState();
}

class _AccountDetailsViewState extends ConsumerState<AccountDetailsView> {
  late final Future<List<Transaction>> _accountTransactions;
  late final String _currentCurrency;

  @override
  Future<void> initState() async {
    super.initState();
    _accountTransactions = ref.read(transactionStorageProvider).getAllByAccount(widget.account.id);
    _currentCurrency = await ref.read(currencyExchangeServiceProvider).getBaseCurrency();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            title: Text(widget.account.name),
            backgroundColor: theme.colorScheme.surface,
            foregroundColor: theme.colorScheme.onSurface,
            elevation: 0,
            floating: true,
            actions: <Widget>[
              PopupMenuButton<String>(
                onSelected: (String value) => _handleMenuAction(context, value),
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'edit',
                    child: ListTile(
                      leading: Icon(Icons.edit_outlined),
                      title: Text('Edit Account'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem<String>(
                    value: 'delete',
                    child: ListTile(
                      leading: Icon(Icons.delete_outline, color: Colors.red),
                      title: Text('Delete Account', style: TextStyle(color: Colors.red)),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(DesignTokens.spacingMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  AccountBalanceCard(
                    totalBalance: widget.account.balance,
                    accounts: <Account>[widget.account],
                    onToggleVisibility: () {
                      final StateController<bool> current = ref.read(balanceVisibilityProvider.notifier);
                      current.state = !current.state;
                    },
                    showActiveAccountsCount: false,
                    currentCurrency: _currentCurrency,
                  ).animate().slideY(begin: -0.3, delay: 100.ms).fadeIn(),

                  const Gap(DesignTokens.spacingMd),
                  _buildQuickActions(context, theme).animate().slideY(begin: 0.3, delay: 200.ms).fadeIn(),
                  const Gap(DesignTokens.spacingMd),
                  _buildAccountInfoCard(context, theme).animate().slideY(begin: 0.3, delay: 300.ms).fadeIn(),
                  const Gap(DesignTokens.spacingLg),

                  // Transactions Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        'Recent Transactions',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      TextButton(
                        onPressed: () => context.pushNamed(
                          'transactions',
                          queryParameters: <String, String>{'accountId': widget.account.id},
                        ),
                        child: const Text('View All'),
                      ),
                    ],
                  ).animate().slideY(begin: 0.3, delay: 400.ms).fadeIn(),
                ],
              ),
            ),
          ),

          // Transactions List
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spacingMd),
            sliver: FutureBuilder<List<Transaction>>(
              future: _accountTransactions,
              builder: (BuildContext context, AsyncSnapshot<List<Transaction>> snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const SliverToBoxAdapter(child: LoadingState());
                }

                if (snapshot.hasError) {
                  return SliverToBoxAdapter(child: ErrorState(
                    title: 'Error loading transactions',
                    message: snapshot.error.toString(),
                    onRetry: () => setState(() {
                      _accountTransactions = ref.read(transactionStorageProvider).getAllByAccount(widget.account.id);
                    }),
                  ));
                }

                final List<Transaction> transactions = snapshot.data ?? <Transaction>[];

                if (transactions.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: EmptyState(
                      title: 'No transactions yet',
                      message: 'Add your first transaction to get started',
                      icon: Icons.receipt_long_outlined,
                    ),
                  );
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      final Transaction transaction = transactions[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: DesignTokens.spacingSm),
                        child: TransactionListItem(
                          transaction: transaction,
                          onTap: () => Navigator.of(context).pushNamed('/transactions/${transaction.id}'),
                          animationDelay: Duration(milliseconds: 500 + (index * 100)),
                          compact: true,
                          visible: ref.watch(balanceVisibilityProvider),
                        ),
                      );
                    },
                    childCount: transactions.length,
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: widget.onAddTransaction,
        tooltip: 'Add Transaction',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, ThemeData theme) {
    return Row(
      children: <Widget>[
        Expanded(
          child: _buildActionButton(
            context,
            theme,
            icon: Icons.add_circle_outline,
            label: 'Add Transaction',
            onTap: widget.onAddTransaction,
          ),
        ),
        const Gap(DesignTokens.spacingSm),
        Expanded(
          child: _buildActionButton(
            context,
            theme,
            icon: Icons.sync_outlined,
            label: 'Sync Account',
            onTap: () => UiUtils.showComingSoon(context, 'Sync Account'),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    ThemeData theme, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
      child: Container(
        padding: const EdgeInsets.all(DesignTokens.spacingSm),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer.withOpacity(0.1),
          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          border: Border.all(
            color: theme.colorScheme.primary.withOpacity(0.2),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(icon, color: theme.colorScheme.primary, size: 20),
            const Gap(DesignTokens.spacingXs),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountInfoCard(BuildContext context, ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(DesignTokens.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Account Information',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const Gap(DesignTokens.spacingSm),
            _buildInfoRow(theme, label: 'Account Type', value: UiUtils.formatAccountType(widget.account.type), icon: Icons.category_outlined),
            if (widget.account.accountNumber != null)
              _buildInfoRow(
                theme,
                label: 'Account Number',
                value: '****${widget.account.accountNumber!.substring(widget.account.accountNumber!.length - 4)}',
                icon: Icons.numbers_outlined,
              ),
            if (widget.account.sortCode != null)
              _buildInfoRow(theme, label: 'Sort Code', value: widget.account.sortCode!, icon: Icons.tag_outlined),
            _buildInfoRow(theme, label: 'Currency', value: widget.account.currency, icon: Icons.monetization_on_outlined),
            _buildInfoRow(
              theme,
              label: 'Status',
              value: widget.account.isActive ? 'Active' : 'Inactive',
              icon: Icons.info_outline,
              valueColor: widget.account.isActive ? theme.colorScheme.primary : theme.colorScheme.error,
            ),
            _buildInfoRow(
              theme,
              label: 'Created',
              value: DateUtils.formatDate(widget.account.createdAt),
              icon: Icons.schedule_outlined,
              showDivider: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    ThemeData theme, {
    required String label,
    required String value,
    required IconData icon,
    Color? valueColor,
    bool showDivider = true,
  }) {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Icon(icon, size: 16, color: theme.colorScheme.onSurface.withOpacity(0.6)),
            const Gap(DesignTokens.spacingXs),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const Spacer(),
            Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: valueColor ?? theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
        if (showDivider) ...<Widget>[
          const Gap(DesignTokens.spacingSm),
          Divider(height: 1, color: theme.colorScheme.outline.withOpacity(0.2)),
          const Gap(DesignTokens.spacingSm),
        ],
      ],
    );
  }

  void _handleMenuAction(BuildContext context, String action) {
    switch (action) {
      case 'edit':
        widget.onEditAccount();
      case 'delete':
        widget.onDeleteAccount();
    }
  }
}

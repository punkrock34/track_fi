import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/database/account.dart';
import '../../../core/models/database/transaction.dart';
import '../../../core/theme/design_tokens/design_tokens.dart';
import '../../../features/accounts/providers/accounts_provider.dart';
import '../providers/transactions_provider.dart';

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> 
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedAccountId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    Future<void>.microtask(() {
      ref.read(transactionsProvider.notifier).loadTransactions();
      ref.read(accountsProvider.notifier).loadAccounts();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<Transaction>> transactionsAsync = ref.watch(transactionsProvider);
    final AsyncValue<List<Account>> accountsAsync = ref.watch(accountsProvider);
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: () => _showFilterDialog(context, accountsAsync.value ?? <Account>[]),
          ),
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => _showComingSoon(context, 'Add Transaction'),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const <Widget>[
            Tab(text: 'All'),
            Tab(text: 'Income'),
            Tab(text: 'Expenses'),
          ],
        ),
      ),
      body: Column(
        children: <Widget>[
          // Filter Chip
          if (_selectedAccountId != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(DesignTokens.spacingMd),
              child: Wrap(
                children: <Widget>[
                  FilterChip(
                    label: Text(_getAccountName(accountsAsync.value, _selectedAccountId!)),
                    selected: true,
                    onSelected: (_) => setState(() => _selectedAccountId = null),
                    deleteIcon: const Icon(Icons.close, size: 18),
                    onDeleted: () => setState(() => _selectedAccountId = null),
                  ).animate().slideX(begin: -0.3, delay: 100.ms).fadeIn(),
                ],
              ),
            ),

          // Transactions List
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: <Widget>[
                _buildTransactionsList(transactionsAsync, null),
                _buildTransactionsList(transactionsAsync, TransactionType.credit),
                _buildTransactionsList(transactionsAsync, TransactionType.debit),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsList(
    AsyncValue<List<Transaction>> transactionsAsync,
    TransactionType? filterType,
  ) {
    return transactionsAsync.when(
      loading: () => _buildLoadingState(),
      error: (Object error, StackTrace stackTrace) => _buildErrorState(error),
      data: (List<Transaction> transactions) {
        List<Transaction> filteredTransactions = transactions;
        
        // Apply type filter
        if (filterType != null) {
          filteredTransactions = transactions
              .where((Transaction t) => t.type == filterType)
              .toList();
        }
        
        // Apply account filter
        if (_selectedAccountId != null) {
          filteredTransactions = filteredTransactions
              .where((Transaction t) => t.accountId == _selectedAccountId)
              .toList();
        }

        if (filteredTransactions.isEmpty) {
          return _buildEmptyState(filterType);
        }

        return RefreshIndicator(
          onRefresh: () => ref.read(transactionsProvider.notifier).refresh(),
          child: _buildTransactionsListView(filteredTransactions),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          CircularProgressIndicator(),
          Gap(DesignTokens.spacingMd),
          Text('Loading transactions...'),
        ],
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    final ThemeData theme = Theme.of(context);
    
    return Center(
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
              'Failed to load transactions',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const Gap(DesignTokens.spacingSm),
            Text(
              error.toString(),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const Gap(DesignTokens.spacingLg),
            ElevatedButton.icon(
              onPressed: () => ref.read(transactionsProvider.notifier).loadTransactions(),
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(TransactionType? filterType) {
    final ThemeData theme = Theme.of(context);
    String message = 'No transactions yet';
    
    if (filterType == TransactionType.credit) {
      message = 'No income transactions';
    } else if (filterType == TransactionType.debit) {
      message = 'No expense transactions';
    }
    
    return Center(
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
              message,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const Gap(DesignTokens.spacingSm),
            Text(
              'Add your first transaction to start tracking',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const Gap(DesignTokens.spacingLg),
            ElevatedButton.icon(
              onPressed: () => _showComingSoon(context, 'Add Transaction'),
              icon: const Icon(Icons.add),
              label: const Text('Add Transaction'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionsListView(List<Transaction> transactions) {
    // Group transactions by date
    final Map<String, List<Transaction>> groupedTransactions = <String, List<Transaction>>{};
    
    for (final Transaction transaction in transactions) {
      final String dateKey = _formatDateKey(transaction.transactionDate);
      groupedTransactions.putIfAbsent(dateKey, () => <Transaction>[]);
      groupedTransactions[dateKey]!.add(transaction);
    }

    final List<String> sortedDates = groupedTransactions.keys.toList()
      ..sort((String a, String b) => b.compareTo(a)); // Most recent first

    return ListView.builder(
      padding: const EdgeInsets.all(DesignTokens.spacingMd),
      itemCount: sortedDates.length,
      itemBuilder: (BuildContext context, int index) {
        final String dateKey = sortedDates[index];
        final List<Transaction> dayTransactions = groupedTransactions[dateKey]!;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _DateHeader(
              date: _parseDateKey(dateKey),
              transactionCount: dayTransactions.length,
              animationDelay: Duration(milliseconds: index * 100),
            ),
            const Gap(DesignTokens.spacingSm),
            ...dayTransactions.asMap().entries.map((MapEntry<int, Transaction> entry) {
              final int transactionIndex = entry.key;
              final Transaction transaction = entry.value;
              
              return Padding(
                padding: const EdgeInsets.only(bottom: DesignTokens.spacingSm),
                child: _TransactionListItem(
                  transaction: transaction,
                  onTap: () => context.go('/transactions/${transaction.id}'),
                  animationDelay: Duration(
                    milliseconds: index * 100 + (transactionIndex * 50) + 100,
                  ),
                ),
              );
            }),
            const Gap(DesignTokens.spacingMd),
          ],
        );
      },
    );
  }

  void _showFilterDialog(BuildContext context, List<Account> accounts) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Filter by Account'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  title: const Text('All Accounts'),
                  leading: Radio<String?>(
                    value: null,
                    groupValue: _selectedAccountId,
                    onChanged: (String? value) {
                      setState(() => _selectedAccountId = value);
                      Navigator.of(context).pop();
                    },
                  ),
                ),
                ...accounts.map((Account account) => ListTile(
                  title: Text(account.name),
                  subtitle: account.bankName != null ? Text(account.bankName!) : null,
                  leading: Radio<String?>(
                    value: account.id,
                    groupValue: _selectedAccountId,
                    onChanged: (String? value) {
                      setState(() => _selectedAccountId = value);
                      Navigator.of(context).pop();
                    },
                  ),
                )),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
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

  String _formatDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  DateTime _parseDateKey(String dateKey) {
    final List<String> parts = dateKey.split('-');
    return DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
  }

  String _getAccountName(List<Account>? accounts, String accountId) {
    if (accounts == null) {
      return 'Unknown Account';
    }
    final Account? account = accounts.cast<Account?>().firstWhere(
      (Account? a) => a?.id == accountId,
      orElse: () => null,
    );
    return account?.name ?? 'Unknown Account';
  }
}

class _DateHeader extends StatelessWidget {
  const _DateHeader({
    required this.date,
    required this.transactionCount,
    required this.animationDelay,
  });

  final DateTime date;
  final int transactionCount;
  final Duration animationDelay;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String formattedDate = _formatDate(date);
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          formattedDate,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface.withOpacity(0.8),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: DesignTokens.spacingXs,
            vertical: DesignTokens.spacing2xs,
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withOpacity(0.3),
            borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
          ),
          child: Text(
            '$transactionCount ${transactionCount == 1 ? 'transaction' : 'transactions'}',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    ).animate(delay: animationDelay)
     .slideX(begin: -0.3)
     .fadeIn();
  }

  String _formatDate(DateTime date) {
    final DateTime now = DateTime.now();
    final Duration difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      final List<String> months = <String>[
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    }
  }
}

class _TransactionListItem extends StatelessWidget {
  const _TransactionListItem({
    required this.transaction,
    required this.onTap,
    required this.animationDelay,
  });

  final Transaction transaction;
  final VoidCallback onTap;
  final Duration animationDelay;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDebit = transaction.type == TransactionType.debit;
    
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
        child: Padding(
          padding: const EdgeInsets.all(DesignTokens.spacingMd),
          child: Row(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDebit 
                      ? theme.colorScheme.errorContainer.withOpacity(0.3)
                      : theme.colorScheme.primaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                ),
                child: Icon(
                  _getTransactionIcon(transaction.description),
                  size: 20,
                  color: isDebit 
                      ? theme.colorScheme.error 
                      : theme.colorScheme.primary,
                ),
              ),
              const Gap(DesignTokens.spacingSm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      transaction.description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Gap(2),
                    Row(
                      children: <Widget>[
                        Text(
                          _formatTime(transaction.transactionDate),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                        if (transaction.reference != null) ...<Widget>[
                          Text(
                            ' • ',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              transaction.reference!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(0.5),
                                fontFamily: 'monospace',
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const Gap(DesignTokens.spacingXs),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text(
                    '${isDebit ? '-' : '+'}£${transaction.amount.abs().toStringAsFixed(2)}',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDebit 
                          ? theme.colorScheme.error 
                          : theme.colorScheme.primary,
                    ),
                  ),
                  if (transaction.categoryId != null) ...<Widget>[
                    const Gap(2),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                      ),
                      child: Text(
                        _getCategoryName(transaction.categoryId!),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const Gap(DesignTokens.spacingXs),
              Icon(
                Icons.chevron_right_rounded,
                size: 16,
                color: theme.colorScheme.onSurface.withOpacity(0.4),
              ),
            ],
          ),
        ),
      ),
    ).animate(delay: animationDelay)
     .slideX(begin: 0.3)
     .fadeIn();
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

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _getCategoryName(String categoryId) {
    // Simple category mapping - in a real app, this would fetch from the database
    switch (categoryId) {
      case 'cat_income_salary':
        return 'Salary';
      case 'cat_expense_groceries':
        return 'Groceries';
      case 'cat_expense_transport':
        return 'Transport';
      case 'cat_expense_dining':
        return 'Dining';
      case 'cat_transfer_internal':
        return 'Transfer';
      default:
        return 'Other';
    }
  }
}

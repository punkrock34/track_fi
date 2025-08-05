import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/models/database/account.dart';
import '../../../../../core/models/database/transaction.dart';
import '../../../../../core/theme/design_tokens/design_tokens.dart';
import '../../../../../shared/utils/transaction_utils.dart';
import '../../../../../shared/widgets/states/empty_state.dart';
import '../../../../../shared/widgets/states/error_state.dart';
import '../../../../../shared/widgets/states/loading_state.dart';
import '../../../../../shared/widgets/transactions/date_header.dart';
import '../../../../../shared/widgets/transactions/transaction_list_item.dart';
import '../../../../shared/widgets/navigation/swipe_navigation_wrapper.dart';
import '../../../accounts/providers/accounts_provider.dart';
import '../../providers/transactions_provider.dart';

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key, this.accountId});

  final String? accountId;

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentTabIndex = 0;
  String? _selectedAccountId;

  @override
  void initState() {
    super.initState();

    _selectedAccountId = widget.accountId;

    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _currentTabIndex = _tabController.index;
        });
      }
    });

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

    return SwipeNavigationWrapper(
      currentRoute: '/transactions',
      useTabLocking: true,
      currentTabIndex: _currentTabIndex,
      totalTabs: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Transactions'),
          backgroundColor: Theme.of(context).colorScheme.surface,
          elevation: 0,
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.filter_list_rounded),
              onPressed: () => _showFilterDialog(context, accountsAsync.value ?? <Account>[]),
            ),
            IconButton(
              icon: const Icon(Icons.add_rounded),
              onPressed: () => context.push('/transactions/add'),
              tooltip: 'Add Transaction',
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
        floatingActionButton: FloatingActionButton(
          onPressed: () => context.push('/transactions/add'),
          tooltip: 'Add Transaction',
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildTransactionsList(
    AsyncValue<List<Transaction>> transactionsAsync,
    TransactionType? filterType,
  ) {
    return transactionsAsync.when(
      loading: () => const LoadingState(message: 'Loading transactions...'),
      error: (Object error, StackTrace stackTrace) => ErrorState(
        title: 'Failed to load transactions',
        message: error.toString(),
        onRetry: () => ref.read(transactionsProvider.notifier).loadTransactions(),
      ),
      data: (List<Transaction> transactions) {
        List<Transaction> filteredTransactions = transactions;
        
        // Apply filters
        filteredTransactions = TransactionUtils.filterByType(filteredTransactions, filterType);
        if (_selectedAccountId != null) {
          filteredTransactions = TransactionUtils.filterByAccount(filteredTransactions, _selectedAccountId);
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

  Widget _buildEmptyState(TransactionType? filterType) {
    String title = 'No transactions yet';
    String message = 'Add your first transaction to start tracking';
    
    if (filterType == TransactionType.credit) {
      title = 'No income transactions';
      message = 'No income transactions found';
    } else if (filterType == TransactionType.debit) {
      title = 'No expense transactions';
      message = 'No expense transactions found';
    }
    
    return EmptyState(
      title: title,
      message: message,
      icon: Icons.receipt_long_outlined,
      actionText: 'Add Transaction',
      onAction: () => context.push('/transactions/add'),
    );
  }

  Widget _buildTransactionsListView(List<Transaction> transactions) {
    // Group transactions by date
    final Map<String, List<Transaction>> groupedTransactions =
        TransactionUtils.groupTransactionsByDate(transactions);

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
            DateHeader(
              date: TransactionUtils.parseDateKey(dateKey),
              transactionCount: dayTransactions.length,
              animationDelay: Duration(milliseconds: index * 100),
            ),
            const Gap(DesignTokens.spacingSm),
            ...dayTransactions.asMap().entries.map((MapEntry<int, Transaction> entry) {
              final int transactionIndex = entry.key;
              final Transaction transaction = entry.value;
              
              return Padding(
                padding: const EdgeInsets.only(bottom: DesignTokens.spacingSm),
                child: TransactionListItem(
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

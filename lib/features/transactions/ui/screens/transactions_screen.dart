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
    final ThemeData theme = Theme.of(context);

    return SwipeNavigationWrapper(
      currentRoute: 'transactions',
      useTabLocking: true,
      currentTabIndex: _currentTabIndex,
      totalTabs: 3,
      child: Scaffold(
        body: CustomScrollView(
          slivers: <Widget>[
            // Custom App Bar matching Dashboard style
            SliverAppBar(
              expandedHeight: 160,
              floating: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: <Color>[
                        theme.colorScheme.primaryContainer.withOpacity(0.1),
                        theme.colorScheme.secondaryContainer.withOpacity(0.05),
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(DesignTokens.spacingMd),
                      child: Column(
                        children: <Widget>[
                          // Top Header Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              // App Title
                              Row(
                                children: <Widget>[
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: <Color>[
                                          theme.colorScheme.primary,
                                          theme.colorScheme.secondary,
                                        ],
                                      ),
                                      borderRadius:
                                          BorderRadius.circular(DesignTokens.radiusMd),
                                    ),
                                    child: Icon(
                                      Icons.receipt_long_rounded,
                                      color: theme.colorScheme.onPrimary,
                                      size: 24,
                                    ),
                                  ),
                                  const Gap(DesignTokens.spacingSm),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        'Transactions',
                                        style: theme.textTheme.titleLarge?.copyWith(
                                          fontWeight: FontWeight.w800,
                                          color: theme.colorScheme.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ).animate().slideX(begin: -0.3, delay: 100.ms).fadeIn(),

                              // Action Buttons
                              Row(
                                children: <Widget>[
                                  Container(
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.surfaceVariant
                                          .withOpacity(0.5),
                                      borderRadius:
                                          BorderRadius.circular(DesignTokens.radiusMd),
                                    ),
                                    child: IconButton(
                                      icon: const Icon(Icons.filter_list_rounded),
                                      onPressed: () => _showFilterDialog(context, accountsAsync.value ?? <Account>[]),
                                    ),
                                  ),
                                  const Gap(DesignTokens.spacingXs),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.surfaceVariant
                                          .withOpacity(0.5),
                                      borderRadius:
                                          BorderRadius.circular(DesignTokens.radiusMd),
                                    ),
                                    child: IconButton(
                                      icon: const Icon(Icons.add_rounded),
                                      onPressed: () => context.pushNamed('add-transaction'),
                                      tooltip: 'Add Transaction',
                                    ),
                                  ),
                                ],
                              ).animate().slideX(begin: 0.3, delay: 150.ms).fadeIn(),
                            ],
                          ),

                          const Gap(DesignTokens.spacingSm),

                          // Transaction Summary Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                _getTransactionSummary(transactionsAsync),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                                ),
                              ).animate().slideX(begin: -0.3, delay: 200.ms).fadeIn(),

                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: DesignTokens.spacingXs,
                                  vertical: DesignTokens.spacing2xs,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                                  border: Border.all(
                                    color: theme.colorScheme.primary.withOpacity(0.3),
                                    width: 0.5,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Icon(
                                      Icons.timeline,
                                      size: 14,
                                      color: theme.colorScheme.primary,
                                    ),
                                    const Gap(DesignTokens.spacing2xs),
                                    Text(
                                      'Recent',
                                      style: theme.textTheme.labelSmall?.copyWith(
                                        color: theme.colorScheme.primary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ).animate().slideX(begin: 0.3, delay: 250.ms).fadeIn(),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              bottom: TabBar(
                controller: _tabController,
                tabs: const <Widget>[
                  Tab(text: 'All'),
                  Tab(text: 'Income'),
                  Tab(text: 'Expenses'),
                ],
              ),
            ),

            // Filter Chip
            if (_selectedAccountId != null)
              SliverToBoxAdapter(
                child: Container(
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
              ),

            // Transactions List
            SliverFillRemaining(
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
          onPressed: () => context.pushNamed('add-transaction'),
          tooltip: 'Add Transaction',
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  String _getTransactionSummary(AsyncValue<List<Transaction>> transactionsAsync) {
    return transactionsAsync.maybeWhen(
      data: (List<Transaction> transactions) {
        final int total = transactions.length;
        if (total == 0) {
          return 'No transactions yet';
        }
        return '$total ${total == 1 ? 'transaction' : 'transactions'}';
      },
      orElse: () => 'Loading transactions...',
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
      onAction: () => context.pushNamed('add-transaction'),
    );
  }

  Widget _buildTransactionsListView(List<Transaction> transactions) {
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
                  onTap: () => context.pushNamed(
                    'transaction-details',
                    pathParameters: <String, String>{'transactionId': transaction.id},
                  ),
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

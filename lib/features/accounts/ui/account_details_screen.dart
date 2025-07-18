import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../core/models/database/account.dart';
import '../../../core/models/database/transaction.dart';
import '../../../core/providers/database/storage/transaction_storage_service_provider.dart';
import '../../../core/theme/design_tokens/design_tokens.dart';
import '../../../core/theme/design_tokens/typography.dart';
import '../providers/accounts_provider.dart';

class AccountDetailScreen extends ConsumerStatefulWidget {
  const AccountDetailScreen({super.key, required this.accountId});

  final String accountId;

  @override
  ConsumerState<AccountDetailScreen> createState() => _AccountDetailScreenState();
}

class _AccountDetailScreenState extends ConsumerState<AccountDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final AsyncValue<Account?> accountAsync = ref.watch(accountProvider(widget.accountId));
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      body: accountAsync.when(
        loading: () => _buildLoadingState(theme),
        error: (Object error, StackTrace stackTrace) => _buildErrorState(error, theme),
        data: (Account? account) {
          if (account == null) {
            return _buildNotFoundState(theme);
          }
          return _buildAccountDetail(account, theme);
        },
      ),
    );
  }

  Widget _buildLoadingState(ThemeData theme) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Details'),
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
        title: const Text('Account Details'),
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
                'Failed to load account',
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
        title: const Text('Account Details'),
        backgroundColor: theme.colorScheme.surface,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(DesignTokens.spacingMd),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.account_balance_outlined,
                size: 64,
                color: theme.colorScheme.onSurface.withOpacity(0.4),
              ),
              const Gap(DesignTokens.spacingMd),
              Text(
                'Account not found',
                style: theme.textTheme.titleLarge,
              ),
              const Gap(DesignTokens.spacingSm),
              Text(
                'The account you are looking for does not exist.',
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

  Widget _buildAccountDetail(Account account, ThemeData theme) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          // App Bar with Account Info
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: theme.colorScheme.surface,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: <Color>[
                      theme.colorScheme.primary,
                      theme.colorScheme.secondary,
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
                        Text(
                          account.name,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ).animate().slideX(begin: -0.3, delay: 100.ms).fadeIn(),
                        const Gap(DesignTokens.spacingXs),
                        if (account.bankName != null)
                          Text(
                            account.bankName!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ).animate().slideX(begin: -0.3, delay: 200.ms).fadeIn(),
                        const Gap(DesignTokens.spacingSm),
                        Text(
                          '${account.currency}${account.balance.toStringAsFixed(2)}',
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

          // Account Details
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(DesignTokens.spacingMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Account Information',
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
                            label: 'Account Type',
                            value: _formatAccountType(account.type),
                          ),
                          if (account.accountNumber != null)
                            _DetailRow(
                              label: 'Account Number',
                              value: '****${account.accountNumber!.substring(account.accountNumber!.length - 4)}',
                            ),
                          if (account.sortCode != null)
                            _DetailRow(
                              label: 'Sort Code',
                              value: account.sortCode!,
                            ),
                          _DetailRow(
                            label: 'Currency',
                            value: account.currency,
                          ),
                          _DetailRow(
                            label: 'Status',
                            value: account.isActive ? 'Active' : 'Inactive',
                          ),
                          _DetailRow(
                            label: 'Created',
                            value: _formatDate(account.createdAt),
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

          // Recent Transactions Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spacingMd),
              child: Text(
                'Recent Transactions',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ).animate().slideY(begin: 0.3, delay: 600.ms).fadeIn(),
            ),
          ),

          // Transactions List
          SliverPadding(
            padding: const EdgeInsets.all(DesignTokens.spacingMd),
            sliver: Consumer(
              builder: (BuildContext context, WidgetRef ref, Widget? child) {
                return FutureBuilder<List<Transaction>>(
                  future: ref.read(transactionStorageProvider).getAllByAccount(account.id),
                  builder: (BuildContext context, AsyncSnapshot<List<Transaction>> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SliverToBoxAdapter(
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    
                    if (snapshot.hasError) {
                      return SliverToBoxAdapter(
                        child: Center(
                          child: Text('Failed to load transactions: ${snapshot.error}'),
                        ),
                      );
                    }

                    final List<Transaction> transactions = snapshot.data ?? <Transaction>[];
                    
                    if (transactions.isEmpty) {
                      return SliverToBoxAdapter(
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(DesignTokens.spacingLg),
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
                        ),
                      );
                    }

                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                          final Transaction transaction = transactions[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: DesignTokens.spacingSm),
                            child: _TransactionCard(
                              transaction: transaction,
                              animationDelay: Duration(milliseconds: 700 + (index * 100)),
                            ),
                          );
                        },
                        childCount: transactions.length,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _formatAccountType(String type) {
    return type.split('_').map((String word) => 
        word[0].toUpperCase() + word.substring(1).toLowerCase()).join(' ');
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.showDivider = true,
  });

  final String label;
  final String value;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        if (showDivider) ...<Widget>[
          const Gap(DesignTokens.spacingSm),
          const Divider(height: 1),
          const Gap(DesignTokens.spacingSm),
        ],
      ],
    );
  }
}

class _TransactionCard extends StatelessWidget {
  const _TransactionCard({
    required this.transaction,
    required this.animationDelay,
  });

  final Transaction transaction;
  final Duration animationDelay;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDebit = transaction.type == TransactionType.debit;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(DesignTokens.spacingMd),
        child: Row(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDebit 
                    ? theme.colorScheme.errorContainer.withOpacity(0.3)
                    : theme.colorScheme.primaryContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
              ),
              child: Icon(
                isDebit ? Icons.arrow_outward : Icons.arrow_downward,
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
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Gap(2),
                  Text(
                    _formatDate(transaction.transactionDate),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  if (transaction.reference != null) ...<Widget>[
                    const Gap(2),
                    Text(
                      'Ref: ${transaction.reference}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ],
              ),
            ),
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
                if (transaction.balanceAfter != null) ...<Widget>[
                  const Gap(2),
                  Text(
                    'Bal: £${transaction.balanceAfter!.toStringAsFixed(2)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    ).animate(delay: animationDelay)
     .slideX(begin: 0.3)
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
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

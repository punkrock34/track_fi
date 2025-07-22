import 'package:flutter/material.dart' hide DateUtils;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../../../core/models/database/account.dart';
import '../../../../../core/models/database/transaction.dart';
import '../../../../../core/providers/database/storage/transaction_storage_service_provider.dart';
import '../../../../../core/theme/design_tokens/design_tokens.dart';
import '../../../../../core/theme/design_tokens/typography.dart';
import '../../../../../shared/utils/currency_utils.dart';
import '../../../../../shared/utils/date_utils.dart';
import '../../../../../shared/utils/ui_utils.dart';
import '../../../../../shared/widgets/common/detail_row.dart';
import '../../../../../shared/widgets/states/empty_state.dart';
import '../../../../../shared/widgets/states/error_state.dart';
import '../../../../../shared/widgets/states/loading_state.dart';
import '../../../../../shared/widgets/transactions/transaction_list_item.dart';
import '../../providers/accounts_provider.dart';

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
      body: const LoadingState(),
    );
  }

  Widget _buildErrorState(Object error, ThemeData theme) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Details'),
        backgroundColor: theme.colorScheme.surface,
      ),
      body: ErrorState(
        title: 'Failed to load account',
        message: error.toString(),
      ),
    );
  }

  Widget _buildNotFoundState(ThemeData theme) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Details'),
        backgroundColor: theme.colorScheme.surface,
      ),
      body: const ErrorState(
        title: 'Account not found',
        message: 'The account you are looking for does not exist.',
        icon: Icons.account_balance_outlined,
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
                        ).animate().slideX(begin: -0.3, delay: DesignTokens.durationFast).fadeIn(),
                        const Gap(DesignTokens.spacingXs),
                        if (account.bankName != null)
                          Text(
                            account.bankName!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ).animate().slideX(begin: -0.3, delay: DesignTokens.durationMedium).fadeIn(),
                        const Gap(DesignTokens.spacingSm),
                        Text(
                          CurrencyUtils.formatAmount(
                            account.balance,
                            currency: CurrencyUtils.getCurrencySymbol(account.currency),
                          ),
                          style: AppTypography.moneyLarge.copyWith(
                            color: Colors.white,
                          ),
                        ).animate().slideX(begin: -0.3, delay: DesignTokens.durationSlow).fadeIn(),
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
                  ).animate().slideY(begin: 0.3, delay: DesignTokens.durationSlow).fadeIn(),
                  const Gap(DesignTokens.spacingSm),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(DesignTokens.spacingMd),
                      child: Column(
                        children: <Widget>[
                          DetailRow(
                            label: 'Account Type',
                            value: UiUtils.formatAccountType(account.type),
                          ),
                          if (account.accountNumber != null)
                            DetailRow(
                              label: 'Account Number',
                              value: '****${account.accountNumber!.substring(account.accountNumber!.length - 4)}',
                            ),
                          if (account.sortCode != null)
                            DetailRow(
                              label: 'Sort Code',
                              value: account.sortCode!,
                            ),
                          DetailRow(
                            label: 'Currency',
                            value: account.currency,
                          ),
                          DetailRow(
                            label: 'Status',
                            value: account.isActive ? 'Active' : 'Inactive',
                          ),
                          DetailRow(
                            label: 'Created',
                            value: DateUtils.formatDate(account.createdAt),
                            showDivider: false,
                          ),
                        ],
                      ),
                    ),
                  ).animate().slideY(begin: 0.3, delay: DesignTokens.durationSlow).fadeIn(),
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
              ).animate().slideY(begin: 0.3, delay: DesignTokens.durationSlow).fadeIn(),
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
                        child: LoadingState(),
                      );
                    }
                    
                    if (snapshot.hasError) {
                      return SliverToBoxAdapter(
                        child: ErrorState(
                          title: 'Failed to load transactions',
                          message: snapshot.error.toString(),
                        ),
                      );
                    }

                    final List<Transaction> transactions = snapshot.data ?? <Transaction>[];
                    
                    if (transactions.isEmpty) {
                      return const SliverToBoxAdapter(
                        child: EmptyState(
                          title: 'No transactions yet',
                          message: 'No transactions found for this account',
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
                              animationDelay: Duration(milliseconds: 700 + (index * 100)),
                              compact: true,
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
}

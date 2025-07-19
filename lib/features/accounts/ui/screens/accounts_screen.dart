import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/models/database/account.dart';
import '../../../../../core/theme/design_tokens/design_tokens.dart';
import '../../../../../core/theme/design_tokens/typography.dart';
import '../../../../../shared/utils/currency_utils.dart';
import '../../../../../shared/utils/ui_utils.dart';
import '../../../../../shared/widgets/accounts/account_card.dart';
import '../../../../../shared/widgets/states/empty_state.dart';
import '../../../../../shared/widgets/states/error_state.dart';
import '../../../../../shared/widgets/states/loading_state.dart';
import '../../providers/accounts_provider.dart';

class AccountsScreen extends ConsumerStatefulWidget {
  const AccountsScreen({super.key});

  @override
  ConsumerState<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends ConsumerState<AccountsScreen> {
  @override
  void initState() {
    super.initState();
    Future<void>.microtask(() => ref.read(accountsProvider.notifier).loadAccounts());
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<Account>> accountsAsync = ref.watch(accountsProvider);
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Accounts'),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => UiUtils.showComingSoon(context, 'Add Account'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(accountsProvider.notifier).refresh(),
        child: accountsAsync.when(
          loading: () => const LoadingState(message: 'Loading accounts...'),
          error: (Object error, StackTrace stackTrace) => ErrorState(
            title: 'Failed to load accounts',
            message: error.toString(),
            onRetry: () => ref.read(accountsProvider.notifier).loadAccounts(),
          ),
          data: (List<Account> accounts) => _buildAccountsList(accounts, theme),
        ),
      ),
    );
  }

  Widget _buildAccountsList(List<Account> accounts, ThemeData theme) {
    if (accounts.isEmpty) {
      return const EmptyState(
        title: 'No accounts yet',
        message: 'Add your first account to start tracking your finances',
        icon: Icons.account_balance_outlined,
        actionText: 'Add Account',
      );
    }

    final double totalBalance = accounts.fold(0.0, (double sum, Account account) => sum + account.balance);

    return CustomScrollView(
      slivers: <Widget>[
        // Total Balance Header
        SliverToBoxAdapter(
          child: Container(
            margin: const EdgeInsets.all(DesignTokens.spacingMd),
            padding: const EdgeInsets.all(DesignTokens.spacingMd),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: <Color>[
                  theme.colorScheme.primary,
                  theme.colorScheme.secondary,
                ],
              ),
              borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Total Balance',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Gap(DesignTokens.spacingXs),
                Text(
                  CurrencyUtils.formatAmount(totalBalance),
                  style: AppTypography.moneyLarge.copyWith(
                    color: Colors.white,
                  ),
                ),
                const Gap(DesignTokens.spacingXs),
                Text(
                  '${accounts.length} ${accounts.length == 1 ? 'account' : 'accounts'}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ).animate().slideY(begin: -0.3, delay: 100.ms).fadeIn(),
        ),

        // Accounts List
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spacingMd),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                final Account account = accounts[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: DesignTokens.spacingSm),
                  child: AccountCard(
                    account: account,
                    onTap: () => context.go('/accounts/${account.id}'),
                    animationDelay: Duration(milliseconds: 200 + (index * 100)),
                  ),
                );
              },
              childCount: accounts.length,
            ),
          ),
        ),

        // Bottom padding
        const SliverToBoxAdapter(
          child: Gap(DesignTokens.spacingXl),
        ),
      ],
    );
  }
}

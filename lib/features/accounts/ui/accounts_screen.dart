import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/database/account.dart';
import '../../../core/theme/design_tokens/design_tokens.dart';
import '../../../core/theme/design_tokens/typography.dart';
import '../providers/accounts_provider.dart';

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
            onPressed: () => _showComingSoon(context, 'Add Account'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(accountsProvider.notifier).refresh(),
        child: accountsAsync.when(
          loading: () => _buildLoadingState(theme),
          error: (Object error, StackTrace stackTrace) => _buildErrorState(error, theme),
          data: (List<Account> accounts) => _buildAccountsList(accounts, theme),
        ),
      ),
    );
  }

  Widget _buildLoadingState(ThemeData theme) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          CircularProgressIndicator(),
          Gap(DesignTokens.spacingMd),
          Text('Loading accounts...'),
        ],
      ),
    );
  }

  Widget _buildErrorState(Object error, ThemeData theme) {
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
              'Failed to load accounts',
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
              onPressed: () => ref.read(accountsProvider.notifier).loadAccounts(),
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountsList(List<Account> accounts, ThemeData theme) {
    if (accounts.isEmpty) {
      return _buildEmptyState(theme);
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
                  '£${totalBalance.toStringAsFixed(2)}',
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
                  child: _AccountCard(
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

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
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
              'No accounts yet',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const Gap(DesignTokens.spacingSm),
            Text(
              'Add your first account to start tracking your finances',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const Gap(DesignTokens.spacingLg),
            ElevatedButton.icon(
              onPressed: () => _showComingSoon(context, 'Add Account'),
              icon: const Icon(Icons.add),
              label: const Text('Add Account'),
            ),
          ],
        ),
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
}

class _AccountCard extends StatelessWidget {
  const _AccountCard({
    required this.account,
    required this.onTap,
    required this.animationDelay,
  });

  final Account account;
  final VoidCallback onTap;
  final Duration animationDelay;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
        child: Padding(
          padding: const EdgeInsets.all(DesignTokens.spacingMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          account.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (account.bankName != null) ...<Widget>[
                          const Gap(2),
                          Text(
                            account.bankName!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ).animate(delay: animationDelay)
     .slideX(begin: 0.3)
     .fadeIn();
  }
}

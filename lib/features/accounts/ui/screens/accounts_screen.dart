import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/models/database/account.dart';
import '../../../../../core/theme/design_tokens/design_tokens.dart';
import '../../../../../shared/utils/currency_utils.dart';
import '../../../../../shared/widgets/navigation/swipe_navigation_wrapper.dart';
import '../../../../../shared/widgets/states/empty_state.dart';
import '../../../../../shared/widgets/states/error_state.dart';
import '../../../../../shared/widgets/states/loading_state.dart';
import '../../../../core/providers/financial/active_accounts_provider.dart';
import '../../../../core/providers/financial/base_currency_provider.dart';
import '../../../../core/providers/financial/inactive_accounts_provider.dart';
import '../../../../core/providers/financial/total_balance_provider.dart';
import '../../../../shared/providers/ui/balance_visibility_provider.dart';
import '../../../../shared/widgets/currency/currency_selector_button.dart';
import '../../../../shared/widgets/dashboard/account_balance_card.dart';
import '../widgets/accounts_view.dart';

class AccountsScreen extends ConsumerWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Account>> activeAsync = ref.watch(activeAccountsProvider);
    final AsyncValue<List<Account>> inactiveAsync = ref.watch(inactiveAccountsProvider);
    final AsyncValue<double> totalAsync = ref.watch(totalBalanceProvider);
    final AsyncValue<String> baseCurAsync = ref.watch(baseCurrencyProvider);
    final ThemeData theme = Theme.of(context);

    final String currentCurrencySymbol = baseCurAsync.maybeWhen(
      data: (String c) => CurrencyUtils.getCurrencySymbol(c),
      orElse: () => CurrencyUtils.getCurrencySymbol('RON'),
    );

    return SwipeNavigationWrapper(
      currentRoute: 'accounts',
      child: Scaffold(
        body: activeAsync.when(
          loading: () => const LoadingState(message: 'Loading accounts...'),
          error: (Object e, StackTrace st) => ErrorState(
            title: 'Failed to load active accounts',
            message: e.toString(),
            onRetry: () => ref.refresh(activeAccountsProvider),
          ),
          data: (List<Account> active) => inactiveAsync.when(
            loading: () => const LoadingState(message: 'Loading accounts...'),
            error: (Object e, StackTrace st) => ErrorState(
              title: 'Failed to load inactive accounts',
              message: e.toString(),
              onRetry: () => ref.refresh(inactiveAccountsProvider),
            ),
            data: (List<Account> inactive) {
              // Check if there are no accounts at all
              if (active.isEmpty && inactive.isEmpty) {
                return _buildEmptyState(context, theme);
              }
              
              return totalAsync.when(
                loading: () => const LoadingState(),
                error: (Object e, StackTrace st) => ErrorState(
                  title: 'Failed to compute total',
                  message: e.toString(),
                  onRetry: () => ref.refresh(totalBalanceProvider),
                ),
                data: (double total) => CustomScrollView(
                  slivers: <Widget>[
                    SliverAppBar(
                      expandedHeight: 140,
                      floating: true,
                      backgroundColor: Colors.transparent,
                      elevation: 0,
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
                                  // Header (overflow-safe)
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Expanded(
                                        child: Row(
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
                                                borderRadius: BorderRadius.circular(
                                                  DesignTokens.radiusMd,
                                                ),
                                              ),
                                              child: Icon(
                                                Icons.account_balance_rounded,
                                                color: theme.colorScheme.onPrimary,
                                                size: 24,
                                              ),
                                            ),
                                            const Gap(DesignTokens.spacingSm),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Text(
                                                    'Accounts',
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: theme.textTheme.titleLarge?.copyWith(
                                                      fontWeight: FontWeight.w800,
                                                      color: theme.colorScheme.primary,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          const CurrencySelectorButton(),
                                          const Gap(DesignTokens.spacingXs),
                                          Container(
                                            decoration: BoxDecoration(
                                              color: theme.colorScheme.surfaceVariant
                                                  .withOpacity(0.5),
                                              borderRadius: BorderRadius.circular(
                                                DesignTokens.radiusMd,
                                              ),
                                            ),
                                            child: IconButton(
                                              icon: const Icon(Icons.add_rounded),
                                              onPressed: () => context.pushNamed('add-account'),
                                              tooltip: 'Add Account',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),

                                  const Gap(DesignTokens.spacingSm),

                                  // Summary
                                  Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: Text(
                                          '${active.length} active • ${inactive.length} inactive',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: theme.textTheme.bodyMedium?.copyWith(
                                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                                          ),
                                        ).animate().slideX(begin: -0.3, delay: 200.ms).fadeIn(),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Total balance card - only show if there are active accounts
                    if (active.isNotEmpty)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(DesignTokens.spacingMd),
                          child: AccountBalanceCard(
                            totalBalance: total,
                            accounts: active,
                            onToggleVisibility: () {
                              final StateController<bool> notifier =
                                  ref.read(balanceVisibilityProvider.notifier);
                              notifier.state = !notifier.state;
                            },
                            currentCurrency: currentCurrencySymbol,
                          ).animate().slideY(begin: -0.3, delay: 100.ms).fadeIn(),
                        ),
                      ),

                    // ACTIVE section
                    if (active.isNotEmpty)
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: DesignTokens.spacingMd),
                          child: Text('Active', style: TextStyle(fontWeight: FontWeight.w700)),
                        ),
                      ),
                    if (active.isNotEmpty)
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spacingMd),
                        sliver: AccountsView(
                          accounts: active,
                          totalBalance: total,
                          currentCurrency: currentCurrencySymbol,
                          onAccountTap: (Account a) => context.goNamed(
                            'account-details',
                            pathParameters: <String, String>{'accountId': a.id},
                          ),
                          onAddAccount: () => context.pushNamed('add-account'),
                        ).slivers.first,
                      ),

                    // INACTIVE section
                    if (inactive.isNotEmpty)
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(
                            DesignTokens.spacingMd,
                            DesignTokens.spacingMd,
                            DesignTokens.spacingMd,
                            0,
                          ),
                          child: Text('Inactive', style: TextStyle(fontWeight: FontWeight.w700)),
                        ),
                      ),
                    if (inactive.isNotEmpty)
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spacingMd),
                        sliver: SliverOpacity(
                          opacity: 0.7,
                          sliver: AccountsView(
                            accounts: inactive,
                            totalBalance: total,
                            currentCurrency: currentCurrencySymbol,
                            onAccountTap: (Account a) => context.goNamed(
                              'account-details',
                              pathParameters: <String, String>{'accountId': a.id},
                            ),
                            onAddAccount: () => context.pushNamed('add-account'),
                          ).slivers.first,
                        ),
                      ),

                    const SliverToBoxAdapter(child: Gap(DesignTokens.spacingXl)),
                  ],
                ),
              );
            },
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => context.pushNamed('add-account'),
          tooltip: 'Add Account',
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ThemeData theme) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 120,
            floating: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
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
                    child: Row(
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
                            borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                          ),
                          child: Icon(
                            Icons.account_balance_rounded,
                            color: theme.colorScheme.onPrimary,
                            size: 24,
                          ),
                        ),
                        const Gap(DesignTokens.spacingSm),
                        Text(
                          'Accounts',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverFillRemaining(
            child: EmptyState(
              title: 'No accounts yet',
              message: 'Add your first account to start tracking your finances',
              icon: Icons.account_balance_outlined,
              actionText: 'Add Account',
              onAction: () => context.pushNamed('add-account'),
            ).animate().slideY(begin: 0.3, delay: 100.ms).fadeIn(),
          ),
        ],
      ),
    );
  }
}

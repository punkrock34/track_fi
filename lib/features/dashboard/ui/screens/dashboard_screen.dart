import 'package:flutter/material.dart' hide DateUtils;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/theme/design_tokens/design_tokens.dart';
import '../../../../../shared/utils/date_utils.dart';
import '../../../../../shared/widgets/navigation/swipe_navigation_wrapper.dart';
import '../../../../../shared/widgets/states/error_state.dart';
import '../../../../../shared/widgets/states/loading_state.dart';
import '../../../../core/providers/financial/base_currency_provider.dart';
import '../../../../shared/providers/ui/balance_visibility_provider.dart';
import '../../../../shared/utils/currency_utils.dart';
import '../../../../shared/widgets/currency/currency_selector_button.dart';
import '../../../../shared/widgets/dashboard/account_balance_card.dart';
import '../../models/dashboard_state.dart';
import '../../providers/dashboard_provider.dart';
import '../widgets/quick_actions_row.dart';
import '../widgets/recent_transactions_cart.dart';
import '../widgets/spending_overview_card.dart';
import '../widgets/sync_status_card.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(dashboardProvider.notifier).loadDashboardData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final DashboardState state = ref.watch(dashboardProvider);
    final AsyncValue<String> baseCurrencyAsync = ref.watch(baseCurrencyProvider);
    final ThemeData theme = Theme.of(context);

    return SwipeNavigationWrapper(
      currentRoute: 'dashboard',
      child: Scaffold(
        body: RefreshIndicator(
          key: _refreshIndicatorKey,
          onRefresh: () => _handleRefresh(),
          child: baseCurrencyAsync.when(
            data: (String baseCurrency) =>
                _buildContent(context, state, theme, baseCurrency),
            loading: () => const LoadingState(message: 'Loading currency...'),
            error: (Object e, StackTrace _) => ErrorState(
              title: 'Error loading currency',
              message: e.toString(),
              onRetry: () => ref.refresh(baseCurrencyProvider),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleRefresh() async {
    await ref.read(dashboardProvider.notifier).refresh();
  }

  Widget _buildContent(
      BuildContext context, DashboardState state, ThemeData theme, String baseCurrency) {
    if (state.isLoading && state.error == null) {
      return const LoadingState(message: 'Loading your financial data...');
    }

    if (state.error != null) {
      return ErrorState(
        title: 'Something went wrong',
        message: state.error!,
        onRetry: () => ref.read(dashboardProvider.notifier).loadDashboardData(),
      );
    }

    return CustomScrollView(
      slivers: <Widget>[
        // Custom App Bar
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
                                  Icons.account_balance_wallet_rounded,
                                  color: theme.colorScheme.onPrimary,
                                  size: 24,
                                ),
                              ),
                              const Gap(DesignTokens.spacingSm),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    'TrackFi',
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                  Text(
                                    DateUtils.getGreeting(),
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurface
                                          .withOpacity(0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ).animate().slideX(begin: -0.3, delay: 100.ms).fadeIn(),

                          // Action Buttons
                          Row(
                            children: <Widget>[
                              const CurrencySelectorButton(),
                              const Gap(DesignTokens.spacingXs),
                              Container(
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surfaceVariant
                                      .withOpacity(0.5),
                                  borderRadius:
                                      BorderRadius.circular(DesignTokens.radiusMd),
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.analytics_outlined),
                                  onPressed: () => context.goNamed('analytics'),
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
                                  icon: const Icon(Icons.account_circle_outlined),
                                  onPressed: () => context.goNamed('settings'),
                                ),
                              ),
                            ],
                          ).animate().slideX(begin: 0.3, delay: 150.ms).fadeIn(),
                        ],
                      ),

                      const Gap(DesignTokens.spacingSm),

                      // Sync Status Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            "Here's your financial overview",
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ).animate().slideX(begin: -0.3, delay: 200.ms).fadeIn(),

                          SyncStatusCard(
                            syncStatus: state.lastSyncStatus,
                            lastRefresh: state.lastRefresh,
                          ).animate().slideX(begin: 0.3, delay: 250.ms).fadeIn(),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(DesignTokens.spacingMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Account Balance Overview
                AccountBalanceCard(
                  totalBalance: state.totalBalance,
                  accounts: state.accounts,
                  isLoading: state.isLoading,
                  onToggleVisibility: () {
                    final StateController<bool> current =
                        ref.read(balanceVisibilityProvider.notifier);
                    current.state = !current.state;
                  },
                  currentCurrency: CurrencyUtils.getCurrencySymbol(baseCurrency),
                ).animate().slideY(begin: 0.3, delay: 300.ms).fadeIn(),

                const Gap(DesignTokens.spacingLg),

                // Quick Actions
                QuickActionsRow(
                  onViewAccounts: () => context.goNamed('accounts'),
                  onViewTransactions: () => context.goNamed('transactions'),
                ).animate().slideY(begin: 0.3, delay: 400.ms).fadeIn(),

                const Gap(DesignTokens.spacingLg),

                // Financial Insights Row
                Row(
                  children: <Widget>[
                    Expanded(
                      child: SpendingOverviewCard(
                        monthlySpending: state.monthlySpending,
                        recentTransactions: state.recentTransactions,
                        onToggleVisibility: () {
                          final StateController<bool> current =
                              ref.read(balanceVisibilityProvider.notifier);
                          current.state = !current.state;
                        },
                        currentCurrency:
                            CurrencyUtils.getCurrencySymbol(baseCurrency),
                      ),
                    ),
                  ],
                ).animate().slideY(begin: 0.3, delay: 500.ms).fadeIn(),

                const Gap(DesignTokens.spacingLg),

                // Recent Transactions
                RecentTransactionsCard(
                  transactions: state.recentTransactions,
                  onViewAll: () => context.goNamed('transactions'),
                  isLoading: state.isLoading,
                  onToggleVisibility: () {
                    final StateController<bool> current =
                        ref.read(balanceVisibilityProvider.notifier);
                    current.state = !current.state;
                  },
                ).animate().slideY(begin: 0.3, delay: 600.ms).fadeIn(),

                const Gap(DesignTokens.spacingXl),

                // Bottom Spacer for FAB
                const Gap(DesignTokens.spacingXl),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

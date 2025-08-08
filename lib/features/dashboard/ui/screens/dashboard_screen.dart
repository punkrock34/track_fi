import 'package:flutter/material.dart' hide DateUtils;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/theme/design_tokens/design_tokens.dart';
import '../../../../../shared/utils/date_utils.dart';
import '../../../../../shared/utils/ui_utils.dart';
import '../../../../../shared/widgets/navigation/swipe_navigation_wrapper.dart';
import '../../../../../shared/widgets/states/error_state.dart';
import '../../../../../shared/widgets/states/loading_state.dart';
import '../../../../shared/providers/ui/balance_visibility_provider.dart';
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
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(() => ref.read(dashboardProvider.notifier).loadDashboardData());
  }

  @override
  Widget build(BuildContext context) {
    final DashboardState state = ref.watch(dashboardProvider);
    final ThemeData theme = Theme.of(context);

    return SwipeNavigationWrapper(
      currentRoute: 'dashboard',
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'TrackFi',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          backgroundColor: theme.colorScheme.surface,
          elevation: 0,
          actions: <Widget>[
            const CurrencySelectorButton(),
            const Gap(DesignTokens.spacingXs),
            
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () => UiUtils.showComingSoon(context, 'Notifications'),
            ),
            IconButton(
              icon: const Icon(Icons.account_circle_outlined),
              onPressed: () => context.goNamed('settings'),
            ),
          ],
        ),
        body: RefreshIndicator(
          key: _refreshIndicatorKey,
          onRefresh: () => _handleRefresh(),
          child: _buildContent(context, state, theme),
        ),
      ),
    );
  }

  Future<void> _handleRefresh() async {
    await ref.read(dashboardProvider.notifier).refresh();
  }

  Widget _buildContent(BuildContext context, DashboardState state, ThemeData theme) {
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
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(DesignTokens.spacingMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Greeting and Sync Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            DateUtils.getGreeting(),
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ).animate().slideX(begin: -0.3, delay: 100.ms).fadeIn(),
                          Text(
                            "Here's your financial overview",
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ).animate().slideX(begin: -0.3, delay: 200.ms).fadeIn(),
                        ],
                      ),
                    ),
                    SyncStatusCard(
                      syncStatus: state.lastSyncStatus,
                      lastRefresh: state.lastRefresh,
                    ).animate().slideX(begin: 0.3, delay: 150.ms).fadeIn(),
                  ],
                ),
                
                const Gap(DesignTokens.spacingLg),
                
                // Account Balance Overview - Now shows converted amounts!
                AccountBalanceCard(
                  totalBalance: state.totalBalance,
                  accounts: state.accounts,
                  isLoading: state.isLoading,
                  onToggleVisibility: () {
                    final StateController<bool> current = ref.read(balanceVisibilityProvider.notifier);
                    current.state = !current.state;
                  },
                ).animate().slideY(begin: 0.3, delay: 300.ms).fadeIn(),
                
                const Gap(DesignTokens.spacingMd),
                
                // Quick Actions
                QuickActionsRow(
                  onViewAccounts: () => context.goNamed('accounts'),
                  onViewTransactions: () => context.goNamed('transactions'),
                ).animate().slideY(begin: 0.3, delay: 400.ms).fadeIn(),
                
                const Gap(DesignTokens.spacingMd),
                
                // Spending Overview - Now shows converted amounts!
                SpendingOverviewCard(
                  monthlySpending: state.monthlySpending,
                  recentTransactions: state.recentTransactions,
                  onToggleVisibility: () {
                    final StateController<bool> current = ref.read(balanceVisibilityProvider.notifier);
                    current.state = !current.state;
                  },
                ).animate().slideY(begin: 0.3, delay: 500.ms).fadeIn(),
                
                const Gap(DesignTokens.spacingMd),
                
                // Recent Transactions
                RecentTransactionsCard(
                  transactions: state.recentTransactions,
                  onViewAll: () => context.goNamed('transactions'),
                  isLoading: state.isLoading,
                  onToggleVisibility: () {
                    final StateController<bool> current = ref.read(balanceVisibilityProvider.notifier);
                    current.state = !current.state;
                  },
                ).animate().slideY(begin: 0.3, delay: 600.ms).fadeIn(),
                
                const Gap(DesignTokens.spacingXl),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

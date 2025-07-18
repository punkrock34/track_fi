import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/design_tokens/design_tokens.dart';
import '../models/dashboard_state.dart';
import '../providers/dashboard_provider.dart';
import 'widgets/account_balance_card.dart';
import 'widgets/quick_actions_row.dart';
import 'widgets/recent_transactions_cart.dart';
import 'widgets/spending_overview_card.dart';
import 'widgets/sync_status_card.dart';

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

    return Scaffold(
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
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Navigate to notifications
            },
          ),
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () => context.go('/settings'),
          ),
        ],
      ),
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: () => ref.read(dashboardProvider.notifier).refresh(),
        child: _buildContent(context, state, theme),
      ),
    );
  }

  Widget _buildContent(BuildContext context, DashboardState state, ThemeData theme) {
    if (state.isFirstLoad) {
      return _buildLoadingState(theme);
    }

    if (state.error != null) {
      return _buildErrorState(state.error!, theme);
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
                            _getGreeting(),
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
                
                // Account Balance Overview
                AccountBalanceCard(
                  totalBalance: state.totalBalance,
                  accounts: state.accounts,
                  isLoading: state.isLoading,
                ).animate().slideY(begin: 0.3, delay: 300.ms).fadeIn(),
                
                const Gap(DesignTokens.spacingMd),
                
                // Quick Actions
                QuickActionsRow(
                  onViewAccounts: () => context.go('/accounts'),
                  onViewTransactions: () => context.go('/transactions'),
                  onAddTransaction: () {
                    // TODO: Implement add transaction
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Add transaction coming soon!')),
                    );
                  },
                ).animate().slideY(begin: 0.3, delay: 400.ms).fadeIn(),
                
                const Gap(DesignTokens.spacingMd),
                
                // Spending Overview
                SpendingOverviewCard(
                  monthlySpending: state.monthlySpending,
                  recentTransactions: state.recentTransactions,
                ).animate().slideY(begin: 0.3, delay: 500.ms).fadeIn(),
                
                const Gap(DesignTokens.spacingMd),
                
                // Recent Transactions
                RecentTransactionsCard(
                  transactions: state.recentTransactions,
                  onViewAll: () => context.go('/transactions'),
                  isLoading: state.isLoading,
                ).animate().slideY(begin: 0.3, delay: 600.ms).fadeIn(),
                
                const Gap(DesignTokens.spacingXl),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          CircularProgressIndicator(
            color: theme.colorScheme.primary,
          ),
          const Gap(DesignTokens.spacingMd),
          Text(
            'Loading your financial data...',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error, ThemeData theme) {
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
              'Something went wrong',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const Gap(DesignTokens.spacingSm),
            Text(
              error,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const Gap(DesignTokens.spacingLg),
            ElevatedButton.icon(
              onPressed: () => ref.read(dashboardProvider.notifier).loadDashboardData(),
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  String _getGreeting() {
    final int hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning';
    }
    if (hour < 17) {
      return 'Good afternoon';
    }
    return 'Good evening';
  }
}

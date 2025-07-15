import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../core/theme/design_tokens/design_tokens.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  @override
  Widget build(BuildContext context) {
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
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () {
              // Navigate to profile/settings
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: _handleRefresh,
        child: CustomScrollView(
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
                        Column(
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
                        // const SyncStatusCard().animate().slideX(begin: 0.3, delay: 150.ms).fadeIn(),
                      ],
                    ),
                    
                    const Gap(DesignTokens.spacingLg),
                    
                    // Account Balance Overview
                    // const AccountBalanceCard().animate().slideY(begin: 0.3, delay: 300.ms).fadeIn(),
                    
                    const Gap(DesignTokens.spacingMd),
                    
                    // Quick Actions
                    // const QuickActionsRow().animate().slideY(begin: 0.3, delay: 400.ms).fadeIn(),
                    
                    const Gap(DesignTokens.spacingMd),
                    
                    // Spending Overview
                    // const SpendingOverviewCard().animate().slideY(begin: 0.3, delay: 500.ms).fadeIn(),
                    
                    const Gap(DesignTokens.spacingMd),
                    
                    // Recent Transactions
                    // const RecentTransactionsCard().animate().slideY(begin: 0.3, delay: 600.ms).fadeIn(),
                    
                    const Gap(DesignTokens.spacingXl),
                  ],
                ),
              ),
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

  Future<void> _handleRefresh() async {
    // Trigger data sync
    await Future<void>.delayed(const Duration(seconds: 1)); // Placeholder
    // TODO(sync): Implement actual sync logic. (issue: #12345)
  }
}

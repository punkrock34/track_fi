import 'package:flutter/material.dart';
import 'package:trackfi/features/dashboard/logic/dashboard_controller.dart';
import 'package:trackfi/shared/widgets/account_card.dart';
import 'package:trackfi/features/dashboard/ui/sections/balance_header.dart';
import 'package:trackfi/features/dashboard/ui/sections/quick_actions.dart';
import 'package:trackfi/features/dashboard/ui/sections/transaction_list.dart';
import 'package:trackfi/features/dashboard/ui/sections/dashboard_title_bar.dart';
import 'package:trackfi/app/theme/theme_extensions.dart';
import 'package:trackfi/shared/widgets/app_nav_bar.dart';

final class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = DashboardController();
    final accounts = controller.getMockAccounts();
    final total = controller.getTotalBalance(accounts);
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              expandedHeight: 200,
              elevation: 0,
              backgroundColor: Colors.transparent,
              flexibleSpace: LayoutBuilder(
                builder: (context, constraints) {
                  final appBarHeight = constraints.maxHeight;
                  final collapsedHeight = MediaQuery.of(context).padding.top + kToolbarHeight;
                  final expandRatio = ((appBarHeight - collapsedHeight) / (200 - collapsedHeight)).clamp(0.0, 1.0);

                  return Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [theme.backgroundGradientStart, theme.backgroundGradientEnd],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Balance background
                        Opacity(
                          opacity: expandRatio,
                          child: BalanceHeader(total: total),
                        ),

                        // Title bar
                        Positioned(
                          top: expandRatio > 0.5
                              ? 40
                              : MediaQuery.of(context).padding.top + 12,
                          left: 20,
                          right: 20,
                          child: IgnorePointer(
                            ignoring: expandRatio == 0,
                            child: DashboardTitleBar(),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Accounts',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...accounts.map((acc) => AccountCard(account: acc)),
                    const SizedBox(height: 24),
                    const QuickActions(),
                    const SizedBox(height: 24),
                    const TransactionList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppNavBar(),
    );
  }
}

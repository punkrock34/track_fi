import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';

import '../../../../../core/models/database/account.dart';
import '../../../../../core/theme/design_tokens/design_tokens.dart';
import '../../../../../shared/widgets/accounts/account_card.dart';
import '../../../../../shared/widgets/states/empty_state.dart';
import '../../../../shared/widgets/dashboard/account_balance_card.dart';

class AccountsView extends StatelessWidget {
  const AccountsView({
    super.key,
    required this.accounts,
    required this.onAccountTap,
    required this.onAddAccount,
  });

  final List<Account> accounts;
  final void Function(Account account) onAccountTap;
  final VoidCallback onAddAccount;

  @override
  Widget build(BuildContext context) {
    if (accounts.isEmpty) {
      return EmptyState(
        title: 'No accounts yet',
        message: 'Add your first account to start tracking your finances',
        icon: Icons.account_balance_outlined,
        actionText: 'Add Account',
        onAction: onAddAccount,
      );
    }

    return CustomScrollView(
      slivers: <Widget>[
        // Total Balance Header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(DesignTokens.spacingMd),
            child: AccountBalanceCard(
              totalBalance: _calculateTotalBalance(),
              accounts: accounts,
            ).animate().slideY(begin: -0.3, delay: 100.ms).fadeIn(),
          ),
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
                    onTap: () => onAccountTap(account),
                    animationDelay: Duration(milliseconds: 200 + (index * 100)),
                  ),
                );
              },
              childCount: accounts.length,
            ),
          ),
        ),

        const SliverToBoxAdapter(
          child: Gap(DesignTokens.spacingXl),
        ),
      ],
    );
  }

  double _calculateTotalBalance() {
    return accounts.fold(0.0, (double sum, Account account) => sum + account.balance);
  }
}

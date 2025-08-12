import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../../../core/models/database/account.dart';
import '../../../../../core/theme/design_tokens/design_tokens.dart';
import '../../../../../shared/widgets/accounts/account_card.dart';
import '../../../../../shared/widgets/states/empty_state.dart';

class AccountsView extends ConsumerWidget {
  const AccountsView({
    super.key,
    required this.accounts,
    required this.totalBalance,
    required this.currentCurrency,
    required this.onAccountTap,
    required this.onAddAccount,
    required this.showBalance,
  });

  final List<Account> accounts;
  final double totalBalance;
  final String currentCurrency;
  final void Function(Account account) onAccountTap;
  final VoidCallback onAddAccount;
  final bool showBalance;

  List<Widget> get slivers {
    if (accounts.isEmpty) {
      return <Widget>[
        SliverFillRemaining(
          child: EmptyState(
            title: 'No accounts yet',
            message: 'Add your first account to start tracking your finances',
            icon: Icons.account_balance_outlined,
            actionText: 'Add Account',
            onAction: onAddAccount,
          ),
        ),
      ];
    }

    return <Widget>[
      SliverList(
        delegate: SliverChildBuilderDelegate(
          (BuildContext context, int index) {
            final Account account = accounts[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: DesignTokens.spacingSm),
              child: AccountCard(
                account: account,
                onTap: () => onAccountTap(account),
                animationDelay: Duration(milliseconds: 200 + (index * 100)),
                showBalance: showBalance,
              ),
            );
          },
          childCount: accounts.length,
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                    showBalance: showBalance,
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
}

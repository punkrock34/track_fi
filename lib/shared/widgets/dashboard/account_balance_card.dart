import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../core/models/database/account.dart';
import '../../../core/theme/design_tokens/design_tokens.dart';
import '../../../core/theme/design_tokens/typography.dart';
import '../../providers/ui/balance_visibility_provider.dart';
import '../../utils/currency_utils.dart';

class AccountBalanceCard extends ConsumerWidget {
  const AccountBalanceCard({
    super.key,
    required this.totalBalance,
    required this.accounts,
    this.isLoading = false,
    this.showActiveAccountsCount = true,
    required this.onToggleVisibility,
    required this.currentCurrency,
  });

  final double totalBalance;
  final List<Account> accounts;
  final bool isLoading;
  final bool showActiveAccountsCount;
  final VoidCallback onToggleVisibility;
  final String currentCurrency;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final bool showBalance = ref.watch(balanceVisibilityProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(DesignTokens.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Total Balance',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    showBalance ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    size: 20,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                  onPressed: onToggleVisibility,
                ),
              ],
            ),
            const Gap(DesignTokens.spacingSm),
            if (isLoading)
              Container(
                height: 40,
                width: 200,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                ),
              )
            else
              Text(
                showBalance ? CurrencyUtils.formatAmount(totalBalance, currency: currentCurrency) : '••••••',
                style: AppTypography.moneyLarge.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
            if (showActiveAccountsCount) ...<Widget>[
              const Gap(DesignTokens.spacingSm),
              Text(
              '${accounts.length} active ${accounts.length == 1 ? 'account' : 'accounts'}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

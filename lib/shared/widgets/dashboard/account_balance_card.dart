import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../core/models/database/account.dart';
import '../../../core/theme/design_tokens/design_tokens.dart';
import '../../../core/theme/design_tokens/typography.dart';

class AccountBalanceCard extends StatelessWidget {
  const AccountBalanceCard({
    super.key,
    required this.totalBalance,
    required this.accounts,
    this.isLoading = false,
  });

  final double totalBalance;
  final List<Account> accounts;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    
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
                Icon(
                  Icons.visibility_outlined,
                  size: 20,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
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
                '£${totalBalance.toStringAsFixed(2)}',
                style: AppTypography.moneyLarge.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
            const Gap(DesignTokens.spacingSm),
            Text(
              '${accounts.length} active ${accounts.length == 1 ? 'account' : 'accounts'}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';

import '../../../core/models/database/account.dart';
import '../../../core/theme/design_tokens/design_tokens.dart';
import '../../utils/currency_utils.dart';
import '../../utils/ui_utils.dart';

class AccountCard extends StatelessWidget {
  const AccountCard({
    super.key,
    required this.account,
    required this.onTap,
    this.animationDelay = Duration.zero,
    this.showBalance = true,
  });

  final Account account;
  final VoidCallback onTap;
  final Duration animationDelay;
  final bool showBalance;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
        child: Padding(
          padding: const EdgeInsets.all(DesignTokens.spacingMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          account.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (account.bankName != null) ...<Widget>[
                          const Gap(2),
                          Text(
                            account.bankName!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                        const Gap(DesignTokens.spacingXs),
                        Text(
                          UiUtils.formatAccountType(account.type),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (showBalance)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Text(
                          CurrencyUtils.formatAmount(
                            account.balance,
                            currency: CurrencyUtils.getCurrencySymbol(account.currency),
                          ),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
                          ),
                        ),
                        const Gap(2),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: account.isActive
                                ? theme.colorScheme.primaryContainer.withOpacity(0.3)
                                : theme.colorScheme.errorContainer.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                          ),
                          child: Text(
                            account.isActive ? 'Active' : 'Inactive',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: account.isActive
                                  ? theme.colorScheme.onPrimaryContainer
                                  : theme.colorScheme.onErrorContainer,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    ).animate(delay: animationDelay)
     .slideX(begin: 0.3)
     .fadeIn();
  }
}

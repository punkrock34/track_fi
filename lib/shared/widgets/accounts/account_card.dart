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
    this.onSyncTap,
  });

  final Account account;
  final VoidCallback onTap;
  final Duration animationDelay;
  final bool showBalance;
  final VoidCallback? onSyncTap;

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
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                account.name,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            // Source indicator
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: account.isManual
                                    ? theme.colorScheme.surfaceVariant
                                    : theme.colorScheme.primaryContainer.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Icon(
                                    account.isManual ? Icons.edit_outlined : Icons.sync_outlined,
                                    size: 12,
                                    color: account.isManual
                                        ? theme.colorScheme.onSurfaceVariant
                                        : theme.colorScheme.primary,
                                  ),
                                  const Gap(2),
                                  Text(
                                    account.isManual ? 'Manual' : account.source.toUpperCase(),
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: account.isManual
                                          ? theme.colorScheme.onSurfaceVariant
                                          : theme.colorScheme.primary,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
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
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
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
                            // Future: Sync button for non-manual accounts
                            if (!account.isManual && onSyncTap != null) ...<Widget>[
                              const Gap(DesignTokens.spacingXs),
                              InkWell(
                                onTap: onSyncTap,
                                borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  child: Icon(
                                    Icons.sync,
                                    size: 16,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ),
                            ],
                          ],
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

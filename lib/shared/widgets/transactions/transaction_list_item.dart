import 'package:flutter/material.dart' hide DateUtils;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';

import '../../../core/models/database/transaction.dart';
import '../../../core/theme/design_tokens/design_tokens.dart';
import '../../utils/category_utils.dart';
import '../../utils/date_utils.dart';
import '../../utils/transaction_utils.dart';

class TransactionListItem extends StatelessWidget {
  const TransactionListItem({
    super.key,
    required this.transaction,
    required this.onTap,
    this.animationDelay = Duration.zero,
    this.showCategory = true,
    this.compact = false,
    this.visible = true,
  });

  final Transaction transaction;
  final VoidCallback onTap;
  final Duration animationDelay;
  final bool showCategory;
  final bool compact;
  final bool visible;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
        child: Padding(
          padding: EdgeInsets.all(compact ? DesignTokens.spacingSm : DesignTokens.spacingMd),
          child: Row(
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(compact ? 8 : 10),
                decoration: BoxDecoration(
                  color: TransactionUtils.getTransactionColor(transaction.type, theme)
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                ),
                child: Icon(
                  TransactionUtils.getTransactionIcon(transaction.description),
                  size: compact ? 16 : 20,
                  color: TransactionUtils.getTransactionColor(transaction.type, theme),
                ),
              ),
              Gap(compact ? DesignTokens.spacingXs : DesignTokens.spacingSm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      transaction.description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        fontSize: compact ? 14 : null,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Gap(compact ? 1 : 2),
                    Row(
                      children: <Widget>[
                        Text(
                          DateUtils.formatTime(transaction.transactionDate),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                            fontSize: compact ? 11 : null,
                          ),
                        ),
                        if (transaction.reference != null && !compact) ...<Widget>[
                          Text(
                            ' • ',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              transaction.reference!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(0.5),
                                fontFamily: 'monospace',
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Gap(compact ? DesignTokens.spacing2xs : DesignTokens.spacingXs),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text(
                    visible ? TransactionUtils.formatAmountWithSign(transaction) : '****',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: TransactionUtils.getTransactionColor(transaction.type, theme),
                      fontSize: compact ? 14 : null,
                    ),
                  ),
                  if (showCategory && transaction.categoryId != null && !compact) ...<Widget>[
                    const Gap(2),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                      ),
                      child: Text(
                        CategoryUtils.getCategoryName(transaction.categoryId!),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              if (!compact) ...<Widget>[
                const Gap(DesignTokens.spacingXs),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 16,
                  color: theme.colorScheme.onSurface.withOpacity(0.4),
                ),
              ],
            ],
          ),
        ),
      ),
    ).animate(delay: animationDelay)
     .slideX(begin: 0.3)
     .fadeIn();
  }
}

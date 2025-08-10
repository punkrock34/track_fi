import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../core/theme/design_tokens/design_tokens.dart';
import '../../../../shared/utils/category_utils.dart';
import '../../../../shared/utils/currency_utils.dart';
import '../../models/analytics_data.dart';

class TopCategoriesList extends StatelessWidget {
  const TopCategoriesList({
    super.key,
    required this.data,
    required this.currencySymbol,
  });

  final AnalyticsData data;
  final String currencySymbol;

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
                  'Top Spending Categories',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (data.topCategories.isNotEmpty)
                  Text(
                    '${data.topCategories.length} categories',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
              ],
            ),
            
            const Gap(DesignTokens.spacingMd),

            if (data.topCategories.isNotEmpty)
              ...data.topCategories.map((CategoryData category) {
                return Container(
                  margin: const EdgeInsets.only(bottom: DesignTokens.spacingSm),
                  padding: const EdgeInsets.all(DesignTokens.spacingSm),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                    border: Border.all(
                      color: theme.colorScheme.outline.withOpacity(0.1),
                    ),
                  ),
                  child: Row(
                    children: <Widget>[
                      // Category icon
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: CategoryUtils.getCategoryColor(category.categoryId, theme).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                        ),
                        child: Icon(
                          CategoryUtils.getCategoryIcon(category.categoryId),
                          size: 20,
                          color: CategoryUtils.getCategoryColor(category.categoryId, theme),
                        ),
                      ),

                      const Gap(DesignTokens.spacingSm),

                      // Category info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              category.categoryName,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Gap(2),
                            Row(
                              children: <Widget>[
                                Text(
                                  '${category.transactionCount} transaction${category.transactionCount == 1 ? '' : 's'}',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                                  ),
                                ),
                                Text(
                                  ' • ',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                                  ),
                                ),
                                Text(
                                  '${category.percentage.toStringAsFixed(1)}%',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: CategoryUtils.getCategoryColor(category.categoryId, theme),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Amount
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Text(
                            CurrencyUtils.formatAmount(category.amount, currency: currencySymbol),
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const Gap(2),
                          // Progress bar
                          Container(
                            width: 60,
                            height: 4,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.outline.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: category.percentage / 100,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: CategoryUtils.getCategoryColor(category.categoryId, theme),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              })
            else
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(DesignTokens.spacingLg),
                  child: Column(
                    children: <Widget>[
                      Icon(
                        Icons.category_outlined,
                        size: 48,
                        color: theme.colorScheme.onSurface.withOpacity(0.4),
                      ),
                      const Gap(DesignTokens.spacingSm),
                      Text(
                        'No spending categories yet',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

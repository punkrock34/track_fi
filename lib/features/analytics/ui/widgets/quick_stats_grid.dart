import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../core/theme/design_tokens/design_tokens.dart';
import '../../../../shared/utils/currency_utils.dart';
import '../../models/analytics_data.dart';

class QuickStatsGrid extends StatelessWidget {
  const QuickStatsGrid({
    super.key,
    required this.data,
    required this.currencySymbol,
  });

  final AnalyticsData data;
  final String currencySymbol;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    
    final double avgSpending = data.monthlyData.isNotEmpty 
        ? data.monthlyData.map((MonthlyData e) => e.expenses).reduce((double a, double b) => a + b) / data.monthlyData.length
        : 0.0;
    
    final int totalTransactions = data.categoryBreakdown
        .fold(0, (int sum, CategoryData category) => sum + category.transactionCount);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Quick Stats',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const Gap(DesignTokens.spacingSm),
        Row(
          children: <Widget>[
            Expanded(
              child: _buildStatCard(
                theme,
                'Categories',
                '${data.categoryBreakdown.length}',
                Icons.category_outlined,
                theme.colorScheme.primary,
              ),
            ),
            const Gap(DesignTokens.spacingSm),
            Expanded(
              child: _buildStatCard(
                theme,
                'Transactions',
                '$totalTransactions',
                Icons.receipt_long_outlined,
                theme.colorScheme.secondary,
              ),
            ),
            const Gap(DesignTokens.spacingSm),
            Expanded(
              child: _buildStatCard(
                theme,
                'Avg Spending',
                CurrencyUtils.formatLargeAmount(avgSpending, currency: currencySymbol),
                Icons.trending_flat,
                theme.colorScheme.tertiary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    ThemeData theme,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(DesignTokens.spacingSm),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
            ),
            child: Icon(
              icon,
              size: 20,
              color: color,
            ),
          ),
          const Gap(DesignTokens.spacingXs),
          Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const Gap(2),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

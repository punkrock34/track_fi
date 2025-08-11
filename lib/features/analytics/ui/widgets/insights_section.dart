import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../core/theme/design_tokens/design_tokens.dart';
import '../../models/analytics_data.dart';

class InsightsSection extends StatelessWidget {
  const InsightsSection({
    super.key,
    required this.data,
    required this.currencySymbol,
  });

  final AnalyticsData data;
  final String currencySymbol;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final List<InsightItem> insights = _generateInsights();

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
        side: BorderSide(
          color: theme.colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(DesignTokens.spacingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: <Color>[
                        theme.colorScheme.primary.withOpacity(0.2),
                        theme.colorScheme.secondary.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                  ),
                  child: Icon(
                    Icons.lightbulb_outline,
                    size: 20,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const Gap(DesignTokens.spacingSm),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Financial Insights',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Key patterns from your spending data',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            const Gap(DesignTokens.spacingLg),

            if (insights.isNotEmpty)
              ...insights.map((InsightItem insight) => _buildInsightCard(theme, insight))
            else
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(DesignTokens.spacingLg),
                  child: Column(
                    children: <Widget>[
                      Icon(
                        Icons.insights,
                        size: 48,
                        color: theme.colorScheme.onSurface.withOpacity(0.3),
                      ),
                      const Gap(DesignTokens.spacingSm),
                      Text(
                        'Not enough data for insights yet',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      const Gap(DesignTokens.spacingXs),
                      Text(
                        'Keep tracking your expenses to unlock personalized insights',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
                        textAlign: TextAlign.center,
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

  Widget _buildInsightCard(ThemeData theme, InsightItem insight) {
    return Container(
      margin: const EdgeInsets.only(bottom: DesignTokens.spacingSm),
      padding: const EdgeInsets.all(DesignTokens.spacingSm),
      decoration: BoxDecoration(
        color: insight.color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
        border: Border.all(
          color: insight.color.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: insight.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
            ),
            child: Icon(
              insight.icon,
              size: 20,
              color: insight.color,
            ),
          ),
          const Gap(DesignTokens.spacingSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  insight.title,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const Gap(2),
                Text(
                  insight.description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          if (insight.value != null)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: insight.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
              ),
              child: Text(
                insight.value!,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: insight.color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  List<InsightItem> _generateInsights() {
    final List<InsightItem> insights = <InsightItem>[];

    if (data.categoryBreakdown.isEmpty) {
      return insights;
    }

    final CategoryData topCategory = data.categoryBreakdown.first;
    if (topCategory.percentage > 30) {
      insights.add(InsightItem(
        icon: Icons.warning_amber_rounded,
        title: 'High Category Concentration',
        description: '${topCategory.categoryName} accounts for ${topCategory.percentage.toStringAsFixed(1)}% of your expenses. Consider diversifying your spending or budgeting more carefully for this category.',
        color: Colors.orange,
        value: '${topCategory.percentage.toStringAsFixed(0)}%',
      ));
    }

    if (data.monthlyData.length >= 2) {
      final MonthlyData latest = data.monthlyData.last;
      final MonthlyData previous = data.monthlyData[data.monthlyData.length - 2];
      final double expenseChange = ((latest.expenses - previous.expenses) / previous.expenses) * 100;
      
      if (expenseChange > 20) {
        insights.add(InsightItem(
          icon: Icons.trending_up,
          title: 'Spending Increase',
          description: 'Your expenses increased by ${expenseChange.toStringAsFixed(1)}% compared to the previous period. Review your recent purchases to identify areas for improvement.',
          color: Colors.red,
          value: '+${expenseChange.toStringAsFixed(0)}%',
        ));
      } else if (expenseChange < -10) {
        insights.add(InsightItem(
          icon: Icons.trending_down,
          title: 'Great Savings!',
          description: 'You reduced your expenses by ${expenseChange.abs().toStringAsFixed(1)}% compared to the previous period. Keep up the excellent financial discipline!',
          color: Colors.green,
          value: '${expenseChange.toStringAsFixed(0)}%',
        ));
      }
    }

    final num savingsRate = data.totalIncome > 0 ? (data.netIncome / data.totalIncome) * 100 : 0;
    if (savingsRate > 20) {
      insights.add(InsightItem(
        icon: Icons.savings_outlined,
        title: 'Excellent Savings Rate',
        description: "You're saving ${savingsRate.toStringAsFixed(1)}% of your income. This puts you ahead of most people and on track for strong financial health.",
        color: Colors.blue,
        value: '${savingsRate.toStringAsFixed(0)}%',
      ));
    } else if (savingsRate < 5 && data.totalIncome > 0) {
      insights.add(InsightItem(
        icon: Icons.savings_outlined,
        title: 'Low Savings Rate',
        description: "You're saving only ${savingsRate.toStringAsFixed(1)}% of your income. Consider reviewing your expenses to increase your savings rate to at least 10-20%.",
        color: Colors.orange,
        value: '${savingsRate.toStringAsFixed(0)}%',
      ));
    }

    if (data.categoryBreakdown.length >= 3) {
      final int totalTransactions = data.categoryBreakdown
          .fold(0, (int sum, CategoryData category) => sum + category.transactionCount);
      final double avgPerCategory = totalTransactions / data.categoryBreakdown.length;
      
      if (avgPerCategory < 3) {
        insights.add(InsightItem(
          icon: Icons.category_outlined,
          title: 'Spending Diversity',
          description: 'Your spending is well-diversified across ${data.categoryBreakdown.length} categories. This indicates balanced financial habits.',
          color: Colors.purple,
        ));
      }
    }

    return insights;
  }
}

class InsightItem {

  InsightItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    this.value,
  });
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final String? value;
}

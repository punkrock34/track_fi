import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../core/theme/design_tokens/design_tokens.dart';
import '../../../../core/theme/design_tokens/typography.dart';
import '../../../../shared/utils/currency_utils.dart';
import '../../models/analytics_data.dart';

class AnalyticsOverviewCards extends StatelessWidget {
  const AnalyticsOverviewCards({
    super.key,
    required this.data,
    required this.currencySymbol,
  });

  final AnalyticsData data;
  final String currencySymbol;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(DesignTokens.spacingLg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: data.netIncome >= 0
              ? <Color>[
                  theme.colorScheme.primary.withOpacity(0.9),
                  theme.colorScheme.secondary.withOpacity(0.7),
                ]
              : <Color>[
                  theme.colorScheme.error.withOpacity(0.9),
                  theme.colorScheme.error.withOpacity(0.7),
                ],
        ),
        borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: (data.netIncome >= 0 ? theme.colorScheme.primary : theme.colorScheme.error)
                .withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Net ${data.netIncome >= 0 ? 'Income' : 'Loss'}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Gap(DesignTokens.spacingXs),
                  Text(
                    CurrencyUtils.formatAmount(data.netIncome.abs(), currency: currencySymbol),
                    style: AppTypography.moneyLarge.copyWith(
                      color: Colors.white,
                      fontSize: 36,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
                ),
                child: Icon(
                  data.netIncome >= 0 ? Icons.trending_up : Icons.trending_down,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ],
          ),
          const Gap(DesignTokens.spacingMd),
          Row(
            children: <Widget>[
              Expanded(
                child: _buildStatCard(
                  theme,
                  'Income',
                  data.totalIncome,
                  currencySymbol,
                  Icons.arrow_upward,
                ),
              ),
              const Gap(DesignTokens.spacingSm),
              Expanded(
                child: _buildStatCard(
                  theme,
                  'Expenses',
                  data.totalExpenses,
                  currencySymbol,
                  Icons.arrow_downward,
                ),
              ),
            ],
          ),
          const Gap(DesignTokens.spacingSm),
          Text(
            'For ${data.period.label.toLowerCase()}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    ThemeData theme,
    String label,
    double amount,
    String currency,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(DesignTokens.spacingSm),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                icon,
                size: 16,
                color: Colors.white.withOpacity(0.9),
              ),
              const Gap(DesignTokens.spacingXs),
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const Gap(DesignTokens.spacingXs),
          Text(
            CurrencyUtils.formatAmount(amount, currency: currency),
            style: AppTypography.moneyMedium.copyWith(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}

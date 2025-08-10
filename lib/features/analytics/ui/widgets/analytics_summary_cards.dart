import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../core/theme/design_tokens/design_tokens.dart';
import '../../../../core/theme/design_tokens/typography.dart';
import '../../../../shared/utils/currency_utils.dart';
import '../../models/analytics_data.dart';

class AnalyticsSummaryCards extends StatelessWidget {
  const AnalyticsSummaryCards({
    super.key,
    required this.data,
    required this.currencySymbol,
  });

  final AnalyticsData data;
  final String currencySymbol;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Column(
      children: <Widget>[
        // Net Income Card (Main)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(DesignTokens.spacingMd),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: data.netIncome >= 0
                  ? <Color>[
                      theme.colorScheme.primary.withOpacity(0.8),
                      theme.colorScheme.secondary.withOpacity(0.6),
                    ]
                  : <Color>[
                      theme.colorScheme.error.withOpacity(0.8),
                      theme.colorScheme.error.withOpacity(0.6),
                    ],
            ),
            borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: (data.netIncome >= 0 ? theme.colorScheme.primary : theme.colorScheme.error)
                    .withOpacity(0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'Net ${data.netIncome >= 0 ? 'Income' : 'Loss'}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Icon(
                    data.netIncome >= 0 ? Icons.trending_up : Icons.trending_down,
                    color: Colors.white,
                    size: 24,
                  ),
                ],
              ),
              const Gap(DesignTokens.spacingSm),
              Text(
                CurrencyUtils.formatAmount(data.netIncome.abs(), currency: currencySymbol),
                style: AppTypography.moneyLarge.copyWith(
                  color: Colors.white,
                  fontSize: 32,
                ),
              ),
              const Gap(DesignTokens.spacingXs),
              Text(
                'For ${data.period.label.toLowerCase()}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),

        const Gap(DesignTokens.spacingMd),

        // Income & Expenses Row
        Row(
          children: <Widget>[
            // Income Card
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(DesignTokens.spacingMd),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
                  border: Border.all(
                    color: theme.colorScheme.primary.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                          ),
                          child: Icon(
                            Icons.arrow_upward,
                            size: 16,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const Gap(DesignTokens.spacingXs),
                        Text(
                          'Income',
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: theme.colorScheme.onSurface.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                    const Gap(DesignTokens.spacingSm),
                    Text(
                      CurrencyUtils.formatAmount(data.totalIncome, currency: currencySymbol),
                      style: AppTypography.moneyMedium.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const Gap(DesignTokens.spacingSm),

            // Expenses Card
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(DesignTokens.spacingMd),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
                  border: Border.all(
                    color: theme.colorScheme.error.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.error.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                          ),
                          child: Icon(
                            Icons.arrow_downward,
                            size: 16,
                            color: theme.colorScheme.error,
                          ),
                        ),
                        const Gap(DesignTokens.spacingXs),
                        Text(
                          'Expenses',
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: theme.colorScheme.onSurface.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                    const Gap(DesignTokens.spacingSm),
                    Text(
                      CurrencyUtils.formatAmount(data.totalExpenses, currency: currencySymbol),
                      style: AppTypography.moneyMedium.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

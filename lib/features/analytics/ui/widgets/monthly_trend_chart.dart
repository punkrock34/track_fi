import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../core/theme/design_tokens/design_tokens.dart';
import '../../../../shared/utils/currency_utils.dart';
import '../../models/analytics_data.dart';

class MonthlyTrendChart extends StatelessWidget {
  const MonthlyTrendChart({
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
      elevation: DesignTokens.elevationCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
        side: BorderSide(
          color: theme.colorScheme.outline.withOpacity(0.1),
          width: 0.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(DesignTokens.spacingLg),
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
                        'Financial Trend',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Gap(2),
                      Text(
                        'Income vs Expenses comparison',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: DesignTokens.spacingXs,
                    vertical: DesignTokens.spacing2xs,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                  ),
                  child: Text(
                    data.period.label,
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            
            const Gap(DesignTokens.spacingLg),

            LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final double chartHeight = constraints.maxWidth < 400 ? 220 : 280;
                
                return SizedBox(
                  height: chartHeight,
                  child: data.monthlyData.isNotEmpty
                      ? BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            maxY: _getMaxValue() * 1.1,
                            barTouchData: BarTouchData(
                              touchTooltipData: BarTouchTooltipData(
                                getTooltipColor: (BarChartGroupData group) => theme.colorScheme.inverseSurface,
                                getTooltipItem: (BarChartGroupData group, int groupIndex, BarChartRodData rod, int rodIndex) {
                                  final String label = rodIndex == 0 ? 'Income' : 'Expenses';
                                  final String period = groupIndex < data.monthlyData.length 
                                      ? data.monthlyData[groupIndex].month 
                                      : '';
                                  return BarTooltipItem(
                                    '$label ($period)\n${CurrencyUtils.formatAmount(rod.toY, currency: currencySymbol)}',
                                    TextStyle(
                                      color: theme.colorScheme.onInverseSurface,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 12,
                                    ),
                                  );
                                },
                              ),
                            ),
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 60,
                                  getTitlesWidget: (double value, TitleMeta meta) {
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 4),
                                      child: Text(
                                        CurrencyUtils.formatLargeAmount(value, currency: currencySymbol),
                                        style: theme.textTheme.labelSmall?.copyWith(
                                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                                          fontSize: 10,
                                        ),
                                        textAlign: TextAlign.right,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (double value, TitleMeta meta) {
                                    final int index = value.toInt();
                                    if (index >= 0 && index < data.monthlyData.length) {
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 8),
                                        child: Text(
                                          data.monthlyData[index].month,
                                          style: theme.textTheme.labelSmall?.copyWith(
                                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                                            fontSize: 10,
                                          ),
                                        ),
                                      );
                                    }
                                    return const Text('');
                                  },
                                ),
                              ),
                              rightTitles: const AxisTitles(),
                              topTitles: const AxisTitles(),
                            ),
                            borderData: FlBorderData(show: false),
                            gridData: FlGridData(
                              drawVerticalLine: false,
                              horizontalInterval: _getMaxValue() / 4,
                              getDrawingHorizontalLine: (double value) {
                                return FlLine(
                                  color: theme.colorScheme.outline.withOpacity(0.1),
                                  strokeWidth: 1,
                                );
                              },
                            ),
                            barGroups: _getBarGroups(theme),
                          ),
                        )
                      : _buildEmptyState(theme),
                );
              },
            ),

            const Gap(DesignTokens.spacingSm),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _buildLegendItem(theme, 'Income', theme.colorScheme.primary),
                const Gap(DesignTokens.spacingMd),
                _buildLegendItem(theme, 'Expenses', theme.colorScheme.error),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.bar_chart,
            size: 48,
            color: theme.colorScheme.onSurface.withOpacity(0.3),
          ),
          const Gap(DesignTokens.spacingSm),
          Text(
            'No financial data available',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(ThemeData theme, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const Gap(DesignTokens.spacingXs),
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  List<BarChartGroupData> _getBarGroups(ThemeData theme) {
    return data.monthlyData.asMap().entries.map((MapEntry<int, MonthlyData> entry) {
      final int index = entry.key;
      final MonthlyData monthData = entry.value;
      
      return BarChartGroupData(
        x: index,
        barRods: <BarChartRodData>[
          BarChartRodData(
            toY: monthData.income,
            color: theme.colorScheme.primary,
            width: 16,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: _getMaxValue(),
              color: theme.colorScheme.primary.withOpacity(0.1),
            ),
          ),
          BarChartRodData(
            toY: monthData.expenses,
            color: theme.colorScheme.error,
            width: 16,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: _getMaxValue(),
              color: theme.colorScheme.error.withOpacity(0.1),
            ),
          ),
        ],
        barsSpace: 4,
      );
    }).toList();
  }

  double _getMaxValue() {
    double max = 0;
    for (final MonthlyData month in data.monthlyData) {
      if (month.income > max) {
        max = month.income;
      }
      if (month.expenses > max) {
        max = month.expenses;
      }
    }
    return max == 0 ? 1000 : max; // Prevent division by zero
  }
}

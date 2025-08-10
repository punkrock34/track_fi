import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../core/theme/design_tokens/design_tokens.dart';
import '../../../../shared/utils/currency_utils.dart';
import '../../models/analytics_data.dart';

class SpendingChart extends StatelessWidget {
  const SpendingChart({
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
                  'Income vs Expenses',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
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

            // Chart
            SizedBox(
              height: 200,
              child: data.monthlyData.isNotEmpty
                  ? BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: _getMaxValue() * 1.2,
                        barTouchData: BarTouchData(
                          touchTooltipData: BarTouchTooltipData(
                            getTooltipItem: (BarChartGroupData group, int groupIndex, BarChartRodData rod, int rodIndex) {
                              final MonthlyData monthData = data.monthlyData[group.x];
                              final String label = rodIndex == 0 ? 'Income' : 'Expenses';
                              final double value = rodIndex == 0 ? monthData.income : monthData.expenses;
                              
                              return BarTooltipItem(
                                '$label\n${CurrencyUtils.formatAmount(value, currency: currencySymbol)}',
                                TextStyle(
                                  color: theme.colorScheme.onInverseSurface,
                                  fontWeight: FontWeight.w500,
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
                                return Text(
                                  CurrencyUtils.formatLargeAmount(value, currency: currencySymbol),
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.colorScheme.onSurface.withOpacity(0.6),
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
                                  return Text(
                                    data.monthlyData[index].month,
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: theme.colorScheme.onSurface.withOpacity(0.6),
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
                        barGroups: data.monthlyData.asMap().entries.map((MapEntry<int, MonthlyData> entry) {
                          final int index = entry.key;
                          final MonthlyData monthData = entry.value;
                          
                          return BarChartGroupData(
                            x: index,
                            barRods: <BarChartRodData>[
                              BarChartRodData(
                                toY: monthData.income,
                                color: theme.colorScheme.primary,
                                width: 16,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(4),
                                  topRight: Radius.circular(4),
                                ),
                              ),
                              BarChartRodData(
                                toY: monthData.expenses,
                                color: theme.colorScheme.error,
                                width: 16,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(4),
                                  topRight: Radius.circular(4),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    )
                  : Center(
                      child: Text(
                        'No data available',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ),
            ),

            const Gap(DesignTokens.spacingSm),

            // Legend
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
    return max;
  }
}

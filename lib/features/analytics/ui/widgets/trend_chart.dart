import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../core/models/database/transaction.dart';
import '../../../../core/theme/design_tokens/design_tokens.dart';
import '../../../../shared/utils/currency_utils.dart';
import '../../models/analytics_data.dart';

class TrendChart extends StatelessWidget {
  const TrendChart({
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
            Text(
              'Daily Trend',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            
            const Gap(DesignTokens.spacingLg),

            // Chart
            SizedBox(
              height: 200,
              child: data.weeklyTrend.isNotEmpty
                  ? LineChart(
                      LineChartData(
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
                                final List<DateTime> uniqueDates = _getUniqueDates();
                                
                                if (index >= 0 && index < uniqueDates.length) {
                                  final DateTime date = uniqueDates[index];
                                  return Text(
                                    '${date.day}/${date.month}',
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
                        lineBarsData: <LineChartBarData>[
                          // Income line
                          LineChartBarData(
                            spots: _getIncomeSpots(),
                            color: theme.colorScheme.primary,
                            barWidth: 3,
                            isStrokeCapRound: true,
                            dotData: const FlDotData(show: false),
                            belowBarData: BarAreaData(
                              show: true,
                              color: theme.colorScheme.primary.withOpacity(0.1),
                            ),
                          ),
                          // Expenses line
                          LineChartBarData(
                            spots: _getExpenseSpots(),
                            color: theme.colorScheme.error,
                            barWidth: 3,
                            isStrokeCapRound: true,
                            dotData: const FlDotData(show: false),
                            belowBarData: BarAreaData(
                              show: true,
                              color: theme.colorScheme.error.withOpacity(0.1),
                            ),
                          ),
                        ],
                        lineTouchData: LineTouchData(
                          touchTooltipData: LineTouchTooltipData(
                            getTooltipItems: (List<LineBarSpot> touchedSpots) {
                              return touchedSpots.map((LineBarSpot spot) {
                                final String label = spot.barIndex == 0 ? 'Income' : 'Expenses';
                                return LineTooltipItem(
                                  '$label\n${CurrencyUtils.formatAmount(spot.y, currency: currencySymbol)}',
                                  TextStyle(
                                    color: theme.colorScheme.onInverseSurface,
                                    fontWeight: FontWeight.w500,
                                  ),
                                );
                              }).toList();
                            },
                          ),
                        ),
                      ),
                    )
                  : Center(
                      child: Text(
                        'No trend data available',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  List<DateTime> _getUniqueDates() {
    final Set<DateTime> dates = <DateTime>{};
    for (final DailyData daily in data.weeklyTrend) {
      dates.add(DateTime(daily.date.year, daily.date.month, daily.date.day));
    }
    return dates.toList()..sort();
  }

  List<FlSpot> _getIncomeSpots() {
    final List<DateTime> uniqueDates = _getUniqueDates();
    final Map<DateTime, double> incomeByDate = <DateTime, double>{};
    
    for (final DailyData daily in data.weeklyTrend) {
      if (daily.type == TransactionType.credit) {
        final DateTime dateKey = DateTime(daily.date.year, daily.date.month, daily.date.day);
        incomeByDate[dateKey] = (incomeByDate[dateKey] ?? 0) + daily.amount;
      }
    }
    
    return uniqueDates.asMap().entries.map((MapEntry<int, DateTime> entry) {
      final int index = entry.key;
      final DateTime date = entry.value;
      final double amount = incomeByDate[date] ?? 0;
      return FlSpot(index.toDouble(), amount);
    }).toList();
  }

  List<FlSpot> _getExpenseSpots() {
    final List<DateTime> uniqueDates = _getUniqueDates();
    final Map<DateTime, double> expensesByDate = <DateTime, double>{};
    
    for (final DailyData daily in data.weeklyTrend) {
      if (daily.type == TransactionType.debit) {
        final DateTime dateKey = DateTime(daily.date.year, daily.date.month, daily.date.day);
        expensesByDate[dateKey] = (expensesByDate[dateKey] ?? 0) + daily.amount;
      }
    }
    
    return uniqueDates.asMap().entries.map((MapEntry<int, DateTime> entry) {
      final int index = entry.key;
      final DateTime date = entry.value;
      final double amount = expensesByDate[date] ?? 0;
      return FlSpot(index.toDouble(), amount);
    }).toList();
  }

  double _getMaxValue() {
    double max = 0;
    for (final DailyData daily in data.weeklyTrend) {
      if (daily.amount > max) {
        max = daily.amount;
      }
    }
    return max;
  }
}

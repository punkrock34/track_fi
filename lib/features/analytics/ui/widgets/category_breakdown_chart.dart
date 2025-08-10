import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../core/theme/design_tokens/design_tokens.dart';
import '../../../../shared/utils/category_utils.dart';
import '../../../../shared/utils/currency_utils.dart';
import '../../models/analytics_data.dart';

class CategoryBreakdownChart extends StatefulWidget {
  const CategoryBreakdownChart({
    super.key,
    required this.data,
    required this.currencySymbol,
  });

  final AnalyticsData data;
  final String currencySymbol;

  @override
  State<CategoryBreakdownChart> createState() => _CategoryBreakdownChartState();
}

class _CategoryBreakdownChartState extends State<CategoryBreakdownChart> {
  int touchedIndex = -1;

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
              'Spending by Category',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            
            const Gap(DesignTokens.spacingLg),

            // Chart
            SizedBox(
              height: 200,
              child: widget.data.categoryBreakdown.isNotEmpty
                  ? Row(
                      children: <Widget>[
                        Expanded(
                          flex: 2,
                          child: PieChart(
                            PieChartData(
                              pieTouchData: PieTouchData(
                                touchCallback: (FlTouchEvent event, PieTouchResponse? pieTouchResponse) {
                                  setState(() {
                                    if (!event.isInterestedForInteractions ||
                                        pieTouchResponse == null ||
                                        pieTouchResponse.touchedSection == null) {
                                      touchedIndex = -1;
                                      return;
                                    }
                                    touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                                  });
                                },
                              ),
                              borderData: FlBorderData(show: false),
                              sectionsSpace: 2,
                              centerSpaceRadius: 40,
                              sections: _getPieChartSections(theme),
                            ),
                          ),
                        ),
                        
                        const Gap(DesignTokens.spacingMd),
                        
                        // Legend
                        Expanded(
                          flex: 3,
                          child: SingleChildScrollView(
                            child: Column(
                              children: widget.data.categoryBreakdown.take(6).map((CategoryData category) {
                                final int index = widget.data.categoryBreakdown.indexOf(category);
                                final bool isSelected = index == touchedIndex;
                                
                                return Container(
                                  margin: const EdgeInsets.only(bottom: DesignTokens.spacingXs),
                                  padding: const EdgeInsets.all(DesignTokens.spacingXs),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? theme.colorScheme.primaryContainer.withOpacity(0.3)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                                  ),
                                  child: Row(
                                    children: <Widget>[
                                      Container(
                                        width: 12,
                                        height: 12,
                                        decoration: BoxDecoration(
                                          color: CategoryUtils.getCategoryColor(category.categoryId, theme),
                                          borderRadius: BorderRadius.circular(2),
                                        ),
                                      ),
                                      const Gap(DesignTokens.spacingXs),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text(
                                              category.categoryName,
                                              style: theme.textTheme.labelMedium?.copyWith(
                                                fontWeight: FontWeight.w500,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              '${category.percentage.toStringAsFixed(1)}%',
                                              style: theme.textTheme.labelSmall?.copyWith(
                                                color: theme.colorScheme.onSurface.withOpacity(0.6),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        CurrencyUtils.formatLargeAmount(category.amount, currency: widget.currencySymbol),
                                        style: theme.textTheme.labelMedium?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: theme.colorScheme.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Center(
                      child: Text(
                        'No spending data available',
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

  List<PieChartSectionData> _getPieChartSections(ThemeData theme) {
    final List<CategoryData> topCategories = widget.data.categoryBreakdown.take(6).toList();
    
    return topCategories.asMap().entries.map((MapEntry<int, CategoryData> entry) {
      final int index = entry.key;
      final CategoryData category = entry.value;
      final bool isTouched = index == touchedIndex;
      final double fontSize = isTouched ? 16 : 12;
      final double radius = isTouched ? 60 : 50;
      
      return PieChartSectionData(
        color: CategoryUtils.getCategoryColor(category.categoryId, theme),
        value: category.percentage,
        title: isTouched ? '${category.percentage.toStringAsFixed(1)}%' : '',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }
}

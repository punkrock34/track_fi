import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../core/theme/design_tokens/design_tokens.dart';
import '../../../../shared/utils/category_utils.dart';
import '../../../../shared/utils/currency_utils.dart';
import '../../models/analytics_data.dart';

class CategorySpendingChart extends StatefulWidget {
  const CategorySpendingChart({
    super.key,
    required this.data,
    required this.currencySymbol,
  });

  final AnalyticsData data;
  final String currencySymbol;

  @override
  State<CategorySpendingChart> createState() => _CategorySpendingChartState();
}

class _CategorySpendingChartState extends State<CategorySpendingChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Spending by Category',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Gap(2),
                    Text(
                      'Top spending categories breakdown',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
                if (widget.data.categoryBreakdown.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: DesignTokens.spacingXs,
                      vertical: DesignTokens.spacing2xs,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                    ),
                    child: Text(
                      '${widget.data.categoryBreakdown.length} categories',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
            
            const Gap(DesignTokens.spacingLg),

            SizedBox(
              height: 280,
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
                              centerSpaceRadius: 50,
                              sections: _getPieChartSections(theme),
                            ),
                          ),
                        ),
                        
                        const Gap(DesignTokens.spacingLg),
                        
                        Expanded(
                          flex: 3,
                          child: Column(
                            children: <Widget>[
                              Expanded(
                                child: ListView.builder(
                                  itemCount: widget.data.categoryBreakdown.take(6).length,
                                  itemBuilder: (BuildContext context, int index) {
                                    final CategoryData category = widget.data.categoryBreakdown[index];
                                    final bool isSelected = index == touchedIndex;
                                    
                                    return Container(
                                      margin: const EdgeInsets.only(bottom: DesignTokens.spacingXs),
                                      padding: const EdgeInsets.all(DesignTokens.spacingSm),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? theme.colorScheme.primaryContainer.withOpacity(0.3)
                                            : theme.colorScheme.surface,
                                        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                                        border: Border.all(
                                          color: isSelected
                                              ? theme.colorScheme.primary.withOpacity(0.5)
                                              : theme.colorScheme.outline.withOpacity(0.1),
                                        ),
                                      ),
                                      child: Row(
                                        children: <Widget>[
                                          Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: CategoryUtils.getCategoryColor(category.categoryId, theme).withOpacity(0.2),
                                              borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                                            ),
                                            child: Icon(
                                              CategoryUtils.getCategoryIcon(category.categoryId),
                                              size: 16,
                                              color: CategoryUtils.getCategoryColor(category.categoryId, theme),
                                            ),
                                          ),
                                          const Gap(DesignTokens.spacingSm),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Text(
                                                  category.categoryName,
                                                  style: theme.textTheme.labelLarge?.copyWith(
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                const Gap(2),
                                                Text(
                                                  '${category.percentage.toStringAsFixed(1)}% • ${category.transactionCount} txn',
                                                  style: theme.textTheme.labelSmall?.copyWith(
                                                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Text(
                                            CurrencyUtils.formatLargeAmount(category.amount, currency: widget.currencySymbol),
                                            style: theme.textTheme.labelLarge?.copyWith(
                                              fontWeight: FontWeight.w600,
                                              color: CategoryUtils.getCategoryColor(category.categoryId, theme),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.pie_chart_outline,
                            size: 48,
                            color: theme.colorScheme.onSurface.withOpacity(0.3),
                          ),
                          const Gap(DesignTokens.spacingSm),
                          Text(
                            'No spending data available',
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

  List<PieChartSectionData> _getPieChartSections(ThemeData theme) {
    final List<CategoryData> topCategories = widget.data.categoryBreakdown.take(6).toList();
    
    return topCategories.asMap().entries.map((MapEntry<int, CategoryData> entry) {
      final int index = entry.key;
      final CategoryData category = entry.value;
      final bool isTouched = index == touchedIndex;
      final double radius = isTouched ? 65.0 : 55.0;
      
      return PieChartSectionData(
        color: CategoryUtils.getCategoryColor(category.categoryId, theme),
        value: category.percentage,
        title: isTouched ? '${category.percentage.toStringAsFixed(1)}%' : '',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: <Shadow>[
            Shadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 2,
            ),
          ],
        ),
        badgeWidget: isTouched
            ? Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  shape: BoxShape.circle,
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Icon(
                  CategoryUtils.getCategoryIcon(category.categoryId),
                  size: 16,
                  color: CategoryUtils.getCategoryColor(category.categoryId, theme),
                ),
              )
            : null,
        badgePositionPercentageOffset: 1.3,
      );
    }).toList();
  }
}

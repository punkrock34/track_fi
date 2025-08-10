import 'package:flutter/material.dart';

import '../../../../core/theme/design_tokens/design_tokens.dart';
import '../../models/analytics_data.dart';

class PeriodSelector extends StatelessWidget {
  const PeriodSelector({
    super.key,
    required this.selectedPeriod,
    required this.onPeriodChanged,
  });

  final AnalyticsPeriod selectedPeriod;
  final ValueChanged<AnalyticsPeriod> onPeriodChanged;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: AnalyticsPeriod.values.map((AnalyticsPeriod period) {
          final bool isSelected = period == selectedPeriod;
          
          return Expanded(
            child: GestureDetector(
              onTap: () => onPeriodChanged(period),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  vertical: DesignTokens.spacingXs,
                  horizontal: DesignTokens.spacing2xs,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                  boxShadow: isSelected ? <BoxShadow>[
                    BoxShadow(
                      color: theme.colorScheme.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ] : null,
                ),
                child: Text(
                  _getPeriodShortLabel(period),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: isSelected
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.onSurface.withOpacity(0.7),
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _getPeriodShortLabel(AnalyticsPeriod period) {
    switch (period) {
      case AnalyticsPeriod.week:
        return 'Week';
      case AnalyticsPeriod.month:
        return 'Month';
      case AnalyticsPeriod.quarter:
        return 'Quarter';
      case AnalyticsPeriod.year:
        return 'Year';
      case AnalyticsPeriod.all:
        return 'All';
    }
  }
}

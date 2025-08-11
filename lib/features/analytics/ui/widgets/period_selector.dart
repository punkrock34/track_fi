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
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final bool isSmallScreen = constraints.maxWidth < 400;
          if (isSmallScreen) {
            return _buildCompactSelector(theme);
          } else {
            return _buildFullSelector(theme);
          }
        },
      ),
    );
  }

  Widget _buildFullSelector(ThemeData theme) {
    return Row(
      children: AnalyticsPeriod.values.map((AnalyticsPeriod period) {
        final bool isSelected = period == selectedPeriod;
        return Expanded(
          child: GestureDetector(
            onTap: () => onPeriodChanged(period),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(
                vertical: DesignTokens.spacingSm,
                horizontal: DesignTokens.spacingXs,
              ),
              decoration: BoxDecoration(
                color: isSelected ? theme.colorScheme.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                boxShadow: isSelected
                    ? <BoxShadow>[
                        BoxShadow(
                          color: theme.colorScheme.primary.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Text(
                _getPeriodShortLabel(period),
                style: theme.textTheme.labelMedium?.copyWith(
                  color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface.withOpacity(0.7),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCompactSelector(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spacingSm),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<AnalyticsPeriod>(
          value: selectedPeriod,
          isExpanded: true,
          onChanged: (AnalyticsPeriod? newPeriod) {
            if (newPeriod != null) {
              onPeriodChanged(newPeriod);
            }
          },
          items: AnalyticsPeriod.values.map((AnalyticsPeriod period) {
            return DropdownMenuItem<AnalyticsPeriod>(
              value: period,
              child: Text(
                period.label,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList(),
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
          icon: Icon(
            Icons.expand_more,
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
          dropdownColor: theme.colorScheme.surface,
        ),
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

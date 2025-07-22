import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../core/models/database/transaction.dart';
import '../../../../core/theme/design_tokens/design_tokens.dart';

class TransactionTypeToggle extends StatelessWidget {
  const TransactionTypeToggle({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
  });

  final TransactionType selectedType;
  final ValueChanged<TransactionType> onTypeChanged;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Transaction Type',
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const Gap(DesignTokens.spacingXs),
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
            border: Border.all(
              color: theme.colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: _buildTypeOption(
                  context,
                  type: TransactionType.debit,
                  label: 'Expense',
                  icon: Icons.remove_circle_outline,
                  color: theme.colorScheme.error,
                  isSelected: selectedType == TransactionType.debit,
                  isFirst: true,
                ),
              ),
              Expanded(
                child: _buildTypeOption(
                  context,
                  type: TransactionType.credit,
                  label: 'Income',
                  icon: Icons.add_circle_outline,
                  color: theme.colorScheme.primary,
                  isSelected: selectedType == TransactionType.credit,
                  isLast: true,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTypeOption(
    BuildContext context, {
    required TransactionType type,
    required String label,
    required IconData icon,
    required Color color,
    required bool isSelected,
    bool isFirst = false,
    bool isLast = false,
  }) {
    final ThemeData theme = Theme.of(context);

    return InkWell(
      onTap: () => onTypeChanged(type),
      borderRadius: BorderRadius.only(
        topLeft: isFirst ? const Radius.circular(DesignTokens.radiusMd) : Radius.zero,
        bottomLeft: isFirst ? const Radius.circular(DesignTokens.radiusMd) : Radius.zero,
        topRight: isLast ? const Radius.circular(DesignTokens.radiusMd) : Radius.zero,
        bottomRight: isLast ? const Radius.circular(DesignTokens.radiusMd) : Radius.zero,
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          vertical: DesignTokens.spacingSm,
          horizontal: DesignTokens.spacingXs,
        ),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.only(
            topLeft: isFirst ? const Radius.circular(DesignTokens.radiusMd) : Radius.zero,
            bottomLeft: isFirst ? const Radius.circular(DesignTokens.radiusMd) : Radius.zero,
            topRight: isLast ? const Radius.circular(DesignTokens.radiusMd) : Radius.zero,
            bottomRight: isLast ? const Radius.circular(DesignTokens.radiusMd) : Radius.zero,
          ),
          border: isSelected ? Border.all(color: color, width: 1.5) : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              icon,
              size: 20,
              color: isSelected ? color : theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            const Gap(DesignTokens.spacingXs),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? color : theme.colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

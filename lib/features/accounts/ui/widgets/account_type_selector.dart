import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../core/theme/design_tokens/design_tokens.dart';

class AccountTypeSelector extends StatelessWidget {
  const AccountTypeSelector({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
  });

  final String selectedType;
  final ValueChanged<String> onTypeChanged;

  static const List<AccountTypeOption> _accountTypes = <AccountTypeOption>[
    AccountTypeOption(
      value: 'current',
      label: 'Current Account',
      description: 'Day-to-day banking account',
      icon: Icons.account_balance_outlined,
    ),
    AccountTypeOption(
      value: 'savings',
      label: 'Savings Account',
      description: 'Interest-earning savings',
      icon: Icons.savings_outlined,
    ),
    AccountTypeOption(
      value: 'credit',
      label: 'Credit Card',
      description: 'Credit card account',
      icon: Icons.credit_card_outlined,
    ),
    AccountTypeOption(
      value: 'investment',
      label: 'Investment Account',
      description: 'Stocks, bonds, and investments',
      icon: Icons.trending_up_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Account Type',
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const Gap(DesignTokens.spacingXs),
        Column(
          children: _accountTypes.map((AccountTypeOption option) {
            final bool isSelected = selectedType == option.value;
            
            return Padding(
              padding: const EdgeInsets.only(bottom: DesignTokens.spacingXs),
              child: InkWell(
                onTap: () => onTypeChanged(option.value),
                borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(DesignTokens.spacingSm),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.colorScheme.primaryContainer.withOpacity(0.3)
                        : theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                    border: Border.all(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outline.withOpacity(0.3),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? theme.colorScheme.primary.withOpacity(0.1)
                              : theme.colorScheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                        ),
                        child: Icon(
                          option.icon,
                          size: 20,
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const Gap(DesignTokens.spacingSm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              option.label,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                                color: isSelected
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.onSurface,
                              ),
                            ),
                            Text(
                              option.description,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        Icon(
                          Icons.check_circle,
                          color: theme.colorScheme.primary,
                          size: 20,
                        ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class AccountTypeOption {
  const AccountTypeOption({
    required this.value,
    required this.label,
    required this.description,
    required this.icon,
  });

  final String value;
  final String label;
  final String description;
  final IconData icon;
}

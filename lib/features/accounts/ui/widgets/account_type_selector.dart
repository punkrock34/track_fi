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

  static const Map<String, AccountTypeInfo> _accountTypes = <String, AccountTypeInfo>{
    'current': AccountTypeInfo(
      label: 'Current Account',
      icon: Icons.account_balance_outlined,
    ),
    'savings': AccountTypeInfo(
      label: 'Savings Account',
      icon: Icons.savings_outlined,
    ),
    'credit': AccountTypeInfo(
      label: 'Credit Card',
      icon: Icons.credit_card_outlined,
    ),
    'investment': AccountTypeInfo(
      label: 'Investment Account',
      icon: Icons.trending_up_outlined,
    ),
  };

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AccountTypeInfo? selectedTypeInfo = _accountTypes[selectedType];

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
        InkWell(
          onTap: () => _showTypePicker(context),
          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(DesignTokens.spacingSm),
            decoration: BoxDecoration(
              color: theme.inputDecorationTheme.fillColor,
              borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
              border: Border.all(
                color: theme.colorScheme.outline.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: <Widget>[
                if (selectedTypeInfo != null) ...<Widget>[
                  Icon(
                    selectedTypeInfo.icon,
                    size: 20,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                  const Gap(DesignTokens.spacingSm),
                  Expanded(
                    child: Text(
                      selectedTypeInfo.label,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ] else
                  Expanded(
                    child: Text(
                      'Select account type',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ),
                Icon(
                  Icons.expand_more,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showTypePicker(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(DesignTokens.radiusLg),
        ),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(DesignTokens.spacingMd),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Text(
                    'Select Account Type',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const Gap(DesignTokens.spacingSm),
              ..._accountTypes.entries.map((MapEntry<String, AccountTypeInfo> entry) {
                final bool isSelected = entry.key == selectedType;
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: DesignTokens.spacingXs),
                  child: InkWell(
                    onTap: () {
                      onTypeChanged(entry.key);
                      Navigator.of(context).pop();
                    },
                    borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(DesignTokens.spacingSm),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                        border: isSelected ? Border.all(
                          color: Theme.of(context).colorScheme.primary,
                        ) : null,
                      ),
                      child: Row(
                        children: <Widget>[
                          Icon(
                            entry.value.icon,
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                          ),
                          const Gap(DesignTokens.spacingSm),
                          Expanded(
                            child: Text(
                              entry.value.label,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                                color: isSelected
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ),
                          if (isSelected)
                            Icon(
                              Icons.check_circle,
                              color: Theme.of(context).colorScheme.primary,
                              size: 20,
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              Gap(MediaQuery.of(context).padding.bottom),
            ],
          ),
        );
      },
    );
  }
}

class AccountTypeInfo {
  const AccountTypeInfo({
    required this.label,
    required this.icon,
  });

  final String label;
  final IconData icon;
}

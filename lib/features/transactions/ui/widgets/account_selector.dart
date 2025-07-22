import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../core/models/database/account.dart';
import '../../../../core/theme/design_tokens/design_tokens.dart';
import '../../../../shared/utils/currency_utils.dart';

class AccountSelector extends StatelessWidget {
  const AccountSelector({
    super.key,
    required this.selectedAccountId,
    required this.accounts,
    required this.onAccountChanged,
    this.isLoading = false,
  });

  final String? selectedAccountId;
  final List<Account> accounts;
  final ValueChanged<String> onAccountChanged;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Account? selectedAccount = selectedAccountId != null
        ? accounts.cast<Account?>().firstWhere(
            (Account? a) => a?.id == selectedAccountId,
            orElse: () => null,
          )
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        RichText(
          text: TextSpan(
            children: <InlineSpan>[
              TextSpan(
                text: 'Account',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              TextSpan(
                text: ' *',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.error,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const Gap(DesignTokens.spacingXs),
        if (isLoading)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(DesignTokens.spacingSm),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
              borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
              border: Border.all(
                color: theme.colorScheme.outline.withOpacity(0.3),
              ),
            ),
            child: const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          )
        else if (accounts.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(DesignTokens.spacingSm),
            decoration: BoxDecoration(
              color: theme.colorScheme.errorContainer.withOpacity(0.1),
              borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
              border: Border.all(
                color: theme.colorScheme.error.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.warning_outlined,
                  color: theme.colorScheme.error,
                  size: 20,
                ),
                const Gap(DesignTokens.spacingXs),
                Expanded(
                  child: Text(
                    'No accounts available. Please add an account first.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          InkWell(
            onTap: () => _showAccountPicker(context),
            borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(DesignTokens.spacingSm),
              decoration: BoxDecoration(
                color: theme.inputDecorationTheme.fillColor,
                borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                border: Border.all(
                  color: selectedAccountId != null
                      ? theme.colorScheme.primary.withOpacity(0.5)
                      : theme.colorScheme.outline.withOpacity(0.3),
                  width: selectedAccountId != null ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: selectedAccount != null
                          ? theme.colorScheme.primaryContainer.withOpacity(0.3)
                          : theme.colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                    ),
                    child: Icon(
                      Icons.account_balance_outlined,
                      size: 16,
                      color: selectedAccount != null
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const Gap(DesignTokens.spacingSm),
                  Expanded(
                    child: selectedAccount != null
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                selectedAccount.name,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Row(
                                children: <Widget>[
                                  if (selectedAccount.bankName != null) ...<Widget>[
                                    Text(
                                      selectedAccount.bankName!,
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                                      ),
                                    ),
                                    Text(
                                      ' • ',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                                      ),
                                    ),
                                  ],
                                  Text(
                                    CurrencyUtils.formatAmount(selectedAccount.balance),
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          )
                        : Text(
                            'Select an account',
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

  void _showAccountPicker(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(DesignTokens.radiusLg),
        ),
      ),
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          minChildSize: 0.3,
          expand: false,
          builder: (BuildContext context, ScrollController scrollController) {
            return Column(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(DesignTokens.spacingMd),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                      ),
                    ),
                  ),
                  child: Row(
                    children: <Widget>[
                      Text(
                        'Select Account',
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
                ),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.all(DesignTokens.spacingMd),
                    itemCount: accounts.length,
                    itemBuilder: (BuildContext context, int index) {
                      final Account account = accounts[index];
                      final bool isSelected = account.id == selectedAccountId;
                      
                      return Padding(
                        padding: const EdgeInsets.only(bottom: DesignTokens.spacingXs),
                        child: InkWell(
                          onTap: () {
                            onAccountChanged(account.id);
                            Navigator.of(context).pop();
                          },
                          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                          child: Container(
                            padding: const EdgeInsets.all(DesignTokens.spacingSm),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3)
                                  : Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                              border: Border.all(
                                color: isSelected
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).colorScheme.outline.withOpacity(0.2),
                                width: isSelected ? 1.5 : 1,
                              ),
                            ),
                            child: Row(
                              children: <Widget>[
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                                  ),
                                  child: Icon(
                                    Icons.account_balance_outlined,
                                    size: 20,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                                const Gap(DesignTokens.spacingSm),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        account.name,
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const Gap(2),
                                      Row(
                                        children: <Widget>[
                                          if (account.bankName != null) ...<Widget>[
                                            Text(
                                              account.bankName!,
                                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                              ),
                                            ),
                                            Text(
                                              ' • ',
                                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                              ),
                                            ),
                                          ],
                                          Text(
                                            CurrencyUtils.formatAmount(account.balance),
                                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              color: Theme.of(context).colorScheme.primary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
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
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

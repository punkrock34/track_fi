import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../core/theme/design_tokens/design_tokens.dart';
import '../../utils/currency_utils.dart';
import 'currency_picker.dart';

class AccountCurrencySelector extends StatelessWidget {
  const AccountCurrencySelector({
    super.key,
    required this.label,
    required this.currency,
    required this.onChanged,
    this.enabled = true,
  });

  final String label;
  final String currency; // e.g. 'RON'
  final ValueChanged<String> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(label, style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w500)),
        const Gap(DesignTokens.spacingXs),
        InkWell(
          onTap: enabled ? () => _showPicker(context) : null,
          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          child: InputDecorator(
            decoration: const InputDecoration(),
            child: Row(
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                  ),
                  child: Text(
                    CurrencyUtils.getCurrencySymbol(currency),
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                const Gap(DesignTokens.spacingSm),
                Text(
                  currency,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                Icon(Icons.expand_more, color: theme.colorScheme.onSurfaceVariant),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showPicker(BuildContext context) async {
    final String? selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(DesignTokens.radiusLg)),
      ),
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(DesignTokens.radiusLg)),
        ),
        child: CurrencyPicker(currentCurrency: currency),
      ),
    );

    if (selected != null && selected != currency) {
      onChanged(selected);
    }
  }
}

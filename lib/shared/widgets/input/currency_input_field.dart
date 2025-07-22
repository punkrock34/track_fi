import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/design_tokens/design_tokens.dart';
import '../../utils/currency_utils.dart';

class CurrencyInputField extends StatelessWidget {
  const CurrencyInputField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.currency = 'GBP',
    this.onChanged,
    this.enabled = true,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final String currency;
  final ValueChanged<double>? onChanged;
  final bool enabled;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String currencySymbol = CurrencyUtils.getCurrencySymbol(currency);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: DesignTokens.spacingXs),
        TextFormField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
          ],
          onChanged: (String value) {
            final double? amount = double.tryParse(value);
            if (amount != null && onChanged != null) {
              onChanged!(amount);
            }
          },
          enabled: enabled,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Container(
              padding: const EdgeInsets.all(12),
              child: Text(
                currencySymbol,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface.withOpacity(0.8),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

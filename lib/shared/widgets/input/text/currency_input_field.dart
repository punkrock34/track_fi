import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/design_tokens/design_tokens.dart';
import '../../../utils/currency_utils.dart';

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
    this.required = false,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final String currency;
  final ValueChanged<double>? onChanged;
  final bool enabled;
  final String? Function(String?)? validator;
  final bool required;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String currencySymbol = CurrencyUtils.getCurrencySymbol(currency);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        RichText(
          text: TextSpan(
            children: <InlineSpan>[
              TextSpan(
                text: label,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (required)
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
          validator: validator ?? (required ? _defaultValidator : null),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Container(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      currencySymbol,
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  String? _defaultValidator(String? value) {
    if (value?.trim().isEmpty ?? true) {
      return '$label is required';
    }
    final double? amount = double.tryParse(value!);
    if (amount == null || amount <= 0) {
      return 'Enter a valid amount greater than 0';
    }
    return null;
  }
}

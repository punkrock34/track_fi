import 'package:flutter/material.dart';
import '../../../../core/theme/design_tokens/design_tokens.dart';

class DropdownField<T> extends StatelessWidget {
  const DropdownField({
    super.key,
    required this.value,
    required this.label,
    required this.items,
    required this.onChanged,
    required this.itemBuilder,
    this.enabled = true,
    this.validator,
  });

  final T? value;
  final String label;
  final List<T> items;
  final ValueChanged<T> onChanged;
  final Widget Function(T) itemBuilder;
  final bool enabled;
  final String? Function(T?)? validator;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final T? safeValue = (value != null && items.contains(value)) ? value : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(label, style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w500)),
        const SizedBox(height: DesignTokens.spacingXs),
        DropdownButtonFormField<T>(
          value: safeValue,
          items: items.map((T item) {
            return DropdownMenuItem<T>(
              value: item,
              child: itemBuilder(item),
            );
          }).toList(),
          onChanged: enabled
              ? (T? newValue) {
                  if (newValue != null) {
                    onChanged(newValue);
                  }
                }
              : null,
          validator: validator,
          decoration: const InputDecoration(),
        ),
      ],
    );
  }
}

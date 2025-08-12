import 'package:flutter/material.dart' hide DateUtils;
import 'package:gap/gap.dart';

import '../../../../core/theme/design_tokens/design_tokens.dart';
import '../../../utils/date_utils.dart';

class DatePicker extends StatelessWidget {
  const DatePicker({
    super.key,
    required this.selectedDate,
    required this.onDateChanged,
    this.label = 'Date',
    this.required = true,
  });

  final DateTime? selectedDate;
  final ValueChanged<DateTime> onDateChanged;
  final String label;
  final bool required;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    
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
        InkWell(
          onTap: () => _selectDate(context),
          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(DesignTokens.spacingSm),
            decoration: BoxDecoration(
              color: theme.inputDecorationTheme.fillColor,
              borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
              border: Border.all(
                color: selectedDate != null
                    ? theme.colorScheme.primary.withOpacity(0.5)
                    : theme.colorScheme.outline.withOpacity(0.3),
                width: selectedDate != null ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.calendar_today_outlined,
                  size: 16,
                  color: selectedDate != null
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                const Gap(DesignTokens.spacingXs),
                Expanded(
                  child: Text(
                    selectedDate != null
                        ? DateUtils.formatDate(selectedDate!)
                        : 'Select date',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 14,
                      fontWeight: selectedDate != null ? FontWeight.w500 : null,
                      color: selectedDate != null
                          ? theme.colorScheme.onSurface
                          : theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ),
                Icon(
                  Icons.expand_more,
                  size: 16,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).colorScheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedDate != null) {
      onDateChanged(selectedDate);
    }
  }
}

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../core/theme/design_tokens/design_tokens.dart';
import '../../../../core/theme/design_tokens/typography.dart';
import '../../../../shared/utils/currency_utils.dart';

class SpendingMetric extends StatelessWidget {
  const SpendingMetric({
    super.key,
    required this.label,
    required this.amount,
    required this.currency,
    required this.visible,
  });

  final String label;
  final double amount;
  final String currency;
  final bool visible;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        const Gap(DesignTokens.spacing2xs),
        Text(
          visible ? CurrencyUtils.formatAmount(amount) : '****',
          style: AppTypography.moneyMedium.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}

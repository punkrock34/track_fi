import 'package:flutter/material.dart' hide DateUtils;
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/design_tokens/design_tokens.dart';
import '../../utils/date_utils.dart';

class DateHeader extends StatelessWidget {
  const DateHeader({
    super.key,
    required this.date,
    required this.transactionCount,
    this.animationDelay = Duration.zero,
  });

  final DateTime date;
  final int transactionCount;
  final Duration animationDelay;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String formattedDate = DateUtils.formatRelativeDate(date);
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          formattedDate,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface.withOpacity(0.8),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: DesignTokens.spacingXs,
            vertical: DesignTokens.spacing2xs,
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withOpacity(0.3),
            borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
          ),
          child: Text(
            '$transactionCount ${transactionCount == 1 ? 'transaction' : 'transactions'}',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    ).animate(delay: animationDelay)
     .slideX(begin: -0.3)
     .fadeIn();
  }
}

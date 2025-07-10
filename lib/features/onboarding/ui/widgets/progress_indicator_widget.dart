import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/design_tokens/design_tokens.dart';

class ProgressIndicatorWidget extends StatelessWidget {
  const ProgressIndicatorWidget({
    super.key,
    required this.progress,
    required this.totalSteps,
  });
  
  final int progress;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              'Setup Progress',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '$progress / $totalSteps',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: DesignTokens.spacingXs),
        Container(
          height: 6,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
            color: theme.colorScheme.surfaceContainerHighest,
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress / totalSteps,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                gradient: LinearGradient(
                  colors: <Color>[
                    theme.colorScheme.primary,
                    theme.colorScheme.secondary,
                  ],
                ),
              ),
            ),
          ),
        ).animate().scaleX(
          begin: 0,
          duration: 500.ms,
          curve: Curves.easeOutCubic,
        ),
      ],
    );
  }
}

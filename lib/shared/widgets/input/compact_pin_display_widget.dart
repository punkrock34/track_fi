import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../core/theme/design_tokens/design_tokens.dart';

class CompactPinDisplay extends StatelessWidget {
  const CompactPinDisplay({
    super.key,
    required this.pin,
    required this.maxLength,
  });

  final String pin;
  final int maxLength;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List<Widget>.generate(maxLength, (int index) {
            final bool isFilled = index < pin.length;
            
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isFilled
                    ? theme.colorScheme.primary
                    : Colors.transparent,
                border: Border.all(
                  color: isFilled
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outline.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
            );
          }),
        ),
        const Gap(DesignTokens.spacingXs),
        Text(
          '${pin.length}/$maxLength',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

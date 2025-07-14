import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';

import '../../../../core/theme/design_tokens/design_tokens.dart';

class PinDisplayWidget extends StatelessWidget {
  const PinDisplayWidget({
    super.key,
    required this.pin,
    this.maxLength = 6,
    this.minLength = 4,
    this.obscureText = true,
    this.showValidation = true,
    this.animationDelay = Duration.zero,
  });

  final String pin;
  final int maxLength;
  final int minLength;
  final bool obscureText;
  final bool showValidation;
  final Duration animationDelay;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isMinimumMet = pin.length >= minLength;
    
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List<Widget>.generate(maxLength, (int index) {
            final bool isFilled = index < pin.length;
            final bool isActive = index == pin.length && pin.length < maxLength;
            
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 6),
              width: 15,
              height: 15,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isFilled
                    ? theme.colorScheme.primary
                    : Colors.transparent,
                border: Border.all(
                  color: isFilled
                          ? theme.colorScheme.primary
                          : isActive
                              ? theme.colorScheme.primary.withOpacity(0.5)
                              : theme.colorScheme.outline.withOpacity(0.3),
                  width: isActive ? 2 : 1.5,
                ),
              ),
              child: obscureText && isFilled
                  ? Container(
                      margin: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onPrimary,
                        shape: BoxShape.circle,
                      ),
                    )
                  : (isFilled && !obscureText)
                      ? Center(
                          child: Text(
                            pin[index],
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: theme.colorScheme.onPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      : null,
            ).animate(delay: animationDelay + Duration(milliseconds: index * 50))
             .scale(begin: const Offset(0.5, 0.5), curve: Curves.easeOutBack)
             .fadeIn();
          }),
        ),
        
        const Gap(DesignTokens.spacingSm),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              '${pin.length}/$maxLength',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
                fontWeight: FontWeight.w500,
              ),
            ),
            if (showValidation && isMinimumMet) ...<Widget>[
              const Gap(DesignTokens.spacingXs),
              Icon(
                Icons.check_circle,
                size: 16,
                color: theme.colorScheme.primary,
              ),
            ],
          ],
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';

import '../../../core/theme/design_tokens/design_tokens.dart';
import '../../models/card_enums.dart';

class FeatureCard extends StatelessWidget {
  const FeatureCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.onTap,
    this.gradient,
    this.animationDelay = Duration.zero,
    this.style = FeatureCardStyle.standard,
  });

  final IconData icon;
  final String title;
  final String description;
  final VoidCallback? onTap;
  final Gradient? gradient;
  final Duration animationDelay;
  final FeatureCardStyle style;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool hasGradient = gradient != null;

    return Card(
      elevation: style.elevation,
      margin: const EdgeInsets.symmetric(
        horizontal: DesignTokens.spacingXs,
        vertical: DesignTokens.spacing2xs,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
        child: Container(
          padding: EdgeInsets.all(style.padding),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
            border: Border.all(
              color: theme.colorScheme.outline.withOpacity(0.1),
              width: 0.5,
            ),
          ),
          child: Row(
            children: <Widget>[
              // Icon container
              Container(
                padding: EdgeInsets.all(style.iconPadding),
                decoration: BoxDecoration(
                  color: hasGradient
                      ? theme.colorScheme.surface.withOpacity(0.2)
                      : theme.colorScheme.primaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                  boxShadow: style.showIconShadow ? <BoxShadow>[
                    BoxShadow(
                      color: theme.colorScheme.primary.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ] : null,
                ),
                child: Icon(
                  icon,
                  size: style.iconSize,
                  color: hasGradient
                      ? theme.colorScheme.onSurface
                      : theme.colorScheme.primary,
                ),
              ),
              
              Gap(style.spacing),
              
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: hasGradient 
                            ? theme.colorScheme.onSurface
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                    const Gap(DesignTokens.spacing2xs),
                    Text(
                      description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: hasGradient 
                            ? theme.colorScheme.onSurface.withOpacity(0.8)
                            : theme.colorScheme.onSurface.withOpacity(0.7),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Arrow indicator (if tappable)
              if (onTap != null) ...<Widget>[
                const Gap(DesignTokens.spacingXs),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: hasGradient 
                      ? theme.colorScheme.onSurface.withOpacity(0.5)
                      : theme.colorScheme.onSurface.withOpacity(0.5),
                ),
              ],
            ],
          ),
        ),
      ),
    )
        .animate(delay: animationDelay)
        .slideX(begin: 0.3, curve: Curves.easeOutCubic)
        .fadeIn();
  }
}

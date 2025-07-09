import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';

import '../../core/theme/design_tokens/design_tokens.dart';
import '../../core/theme/schemes/color_schemes.dart';

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
                  color: gradient != null
                      ? Colors.white.withOpacity(0.2)
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
                  color: gradient != null
                      ? Colors.white
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
                        color: gradient != null 
                            ? Colors.white
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                    const Gap(DesignTokens.spacing2xs),
                    Text(
                      description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: gradient != null 
                            ? Colors.white.withOpacity(0.8)
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
                  color: gradient != null 
                      ? Colors.white.withOpacity(0.7)
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

class FinancialCard extends StatelessWidget {
  const FinancialCard({
    super.key,
    required this.title,
    required this.amount,
    required this.currency,
    this.subtitle,
    this.trend,
    this.trendPercentage,
    this.onTap,
    this.animationDelay = Duration.zero,
  });

  final String title;
  final double amount;
  final String currency;
  final String? subtitle;
  final FinancialTrend? trend;
  final double? trendPercentage;
  final VoidCallback? onTap;
  final Duration animationDelay;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final FinTechColors finTechColors = theme.finTechColors;

    Color? trendColor;
    IconData? trendIcon;
    
    if (trend != null && trendPercentage != null) {
      switch (trend!) {
        case FinancialTrend.up:
          trendColor = finTechColors.success;
          trendIcon = Icons.trending_up_rounded;
        case FinancialTrend.down:
          trendColor = finTechColors.error;
          trendIcon = Icons.trending_down_rounded;
        case FinancialTrend.neutral:
          trendColor = finTechColors.neutral;
          trendIcon = Icons.trending_flat_rounded;
      }
    }

    return Card(
      elevation: DesignTokens.elevationCard,
      margin: const EdgeInsets.all(DesignTokens.spacingXs),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
        child: Padding(
          padding: const EdgeInsets.all(DesignTokens.spacingMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    title,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (trendIcon != null && trendColor != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: trendColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Icon(
                            trendIcon,
                            size: 14,
                            color: trendColor,
                          ),
                          const Gap(4),
                          Text(
                            '${trendPercentage!.toStringAsFixed(1)}%',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: trendColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              
              const Gap(DesignTokens.spacingXs),
              
              // Amount
              RichText(
                text: TextSpan(
                  children: <InlineSpan>[
                    TextSpan(
                      text: currency,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TextSpan(
                      text: _formatAmount(amount),
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w700,
                        fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ),
              
              if (subtitle != null) ...<Widget>[
                const Gap(DesignTokens.spacing2xs),
                Text(
                  subtitle!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    )
        .animate(delay: animationDelay)
        .scale(begin: const Offset(0.9, 0.9), curve: Curves.easeOutBack)
        .fadeIn();
  }

  String _formatAmount(double amount) {
    if (amount.abs() >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount.abs() >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    } else {
      return amount.toStringAsFixed(2);
    }
  }
}

enum FeatureCardStyle {
  compact(
    padding: DesignTokens.spacingSm,
    iconPadding: 8.0,
    iconSize: 20.0,
    spacing: DesignTokens.spacingXs,
    elevation: 1.0,
    showIconShadow: false,
  ),
  standard(
    padding: DesignTokens.spacingMd,
    iconPadding: 12.0,
    iconSize: 24.0,
    spacing: DesignTokens.spacingSm,
    elevation: 2.0,
    showIconShadow: true,
  ),
  large(
    padding: DesignTokens.spacingLg,
    iconPadding: 16.0,
    iconSize: 32.0,
    spacing: DesignTokens.spacingMd,
    elevation: 4.0,
    showIconShadow: true,
  );

  const FeatureCardStyle({
    required this.padding,
    required this.iconPadding,
    required this.iconSize,
    required this.spacing,
    required this.elevation,
    required this.showIconShadow,
  });

  final double padding;
  final double iconPadding;
  final double iconSize;
  final double spacing;
  final double elevation;
  final bool showIconShadow;
}

enum FinancialTrend {
  up,
  down,
  neutral,
}

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/design_tokens/design_tokens.dart';

class WorkInProgressScreen extends StatelessWidget {
  const WorkInProgressScreen({
    super.key,
    this.title = 'Work In Progress',
    this.subtitle = 'This feature is currently being developed',
    this.showBackButton = true,
  });

  final String title;
  final String subtitle;
  final bool showBackButton;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: showBackButton
          ? AppBar(
              title: const Text('TrackFi'),
              backgroundColor: Colors.transparent,
              elevation: 0,
            )
          : null,
      extendBodyBehindAppBar: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              theme.colorScheme.primary.withOpacity(0.1),
              theme.colorScheme.secondary.withOpacity(0.05),
              theme.colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(DesignTokens.spacingMd),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // Animated construction icon
                Container(
                  padding: const EdgeInsets.all(DesignTokens.spacingLg),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
                    border: Border.all(
                      color: theme.colorScheme.primary.withOpacity(0.2),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.construction_rounded,
                    size: 72,
                    color: theme.colorScheme.primary,
                  ),
                )
                    .animate(onPlay: (AnimationController controller) => controller.repeat(reverse: true))
                    .scale(
                      begin: const Offset(0.9, 0.9),
                      end: const Offset(1.1, 1.1),
                      duration: 2000.ms,
                    ),
                
                const Gap(DesignTokens.spacingXl),
                
                // Title
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                )
                    .animate()
                    .slideY(begin: 0.3, delay: 200.ms)
                    .fadeIn(delay: 200.ms),
                
                const Gap(DesignTokens.spacingSm),
                
                // Subtitle
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                    height: 1.5,
                  ),
                )
                    .animate()
                    .slideY(begin: 0.3, delay: 400.ms)
                    .fadeIn(delay: 400.ms),
                
                const Gap(DesignTokens.spacingXl),
                
                // Progress indicator
                _buildProgressIndicator(theme),
                
                const Gap(DesignTokens.spacing2xl),
                
                // Action button
                if (showBackButton)
                  SizedBox(
                    width: size.width * 0.6,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.goNamed('onboarding');
                        }
                      },
                      icon: const Icon(Icons.arrow_back_rounded),
                      label: const Text('Go Back'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: DesignTokens.spacingSm,
                        ),
                      ),
                    ),
                  )
                      .animate()
                      .slideY(begin: 0.5, delay: 800.ms)
                      .fadeIn(delay: 800.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(ThemeData theme) {
    return Column(
      children: <Widget>[
        Text(
          'Development Progress',
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.8),
            fontWeight: FontWeight.w600,
          ),
        )
            .animate()
            .slideY(begin: 0.3, delay: 600.ms)
            .fadeIn(delay: 600.ms),
        
        const Gap(DesignTokens.spacingSm),
        
        // Progress bar
        Container(
          width: 200,
          height: 8,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
          ),
          child: Stack(
            children: <Widget>[
              Container(
                width: 120, // 60% progress
                height: 8,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: <Color>[
                      theme.colorScheme.primary,
                      theme.colorScheme.primary.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                ),
              )
                  .animate()
                  .scaleX(
                    begin: 0,
                    delay: 700.ms,
                    duration: 1000.ms,
                    curve: Curves.easeOutCubic,
                  ),
            ],
          ),
        ),
        
        const Gap(DesignTokens.spacingXs),
        
        Text(
          '60% Complete',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
            fontWeight: FontWeight.w500,
          ),
        )
            .animate()
            .slideY(begin: 0.3, delay: 1200.ms)
            .fadeIn(delay: 1200.ms),
      ],
    );
  }
}

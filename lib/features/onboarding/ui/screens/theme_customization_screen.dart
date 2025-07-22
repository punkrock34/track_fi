import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../../core/theme/design_tokens/design_tokens.dart';
import '../../../../shared/models/theme_enums.dart';
import '../../../../shared/widgets/theme/theme_toggle.dart';
import '../../providers/onboarding_provider.dart';

class ThemeCustomizationScreen extends ConsumerWidget {
  const ThemeCustomizationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final OnboardingNotifier onboardingNotifier = ref.read(onboardingProvider.notifier);
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(DesignTokens.spacingMd),
          child: Column(
            children: <Widget>[
              const Gap(DesignTokens.spacingXl),
              
              Icon(
                Icons.palette_rounded,
                size: 80,
                color: theme.colorScheme.primary,
              ).animate().scale(delay: 200.ms, curve: Curves.easeOutBack),
              
              const Gap(DesignTokens.spacingLg),
              
              Text(
                'Customize Your Experience',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ).animate().slideY(begin: 0.3, delay: 400.ms).fadeIn(delay: 400.ms),
              
              const Gap(DesignTokens.spacingSm),
              
              Text(
                'Choose your preferred theme mode. You can always change this later in settings.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ).animate().slideY(begin: 0.3, delay: 600.ms).fadeIn(delay: 600.ms),
              
              const Gap(DesignTokens.spacing2xl),
              
              // Theme Mode Section
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Appearance',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ).animate().slideX(begin: 0.3, delay: 800.ms).fadeIn(delay: 800.ms),
              ),
              
              const Gap(DesignTokens.spacingMd),
              
              // Use the working theme toggle
              const Center(
                child: ThemeToggle(
                  showLabel: false,
                  size: ThemeToggleSize.large,
                ),
              ).animate().slideY(begin: 0.3, delay: 1000.ms).fadeIn(delay: 1000.ms),
              
              const Gap(DesignTokens.spacingMd),
              
              // Theme descriptions
              _buildThemeDescription(context),
              
              const Gap(DesignTokens.spacingXl),
              
              // Info Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(DesignTokens.spacingSm),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
                ),
                child: Row(
                  children: <Widget>[
                    Icon(
                      Icons.lightbulb_outline_rounded,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                    const Gap(DesignTokens.spacingXs),
                    Expanded(
                      child: Text(
                        'Your theme preference will be saved and applied across the entire app.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().slideY(begin: 0.3, delay: 1600.ms).fadeIn(delay: 1600.ms),
              
              const Gap(DesignTokens.spacingXl),
              
              // Bottom buttons
              Row(
                children: <Widget>[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onboardingNotifier.previousStep,
                      child: const Text('Back'),
                    ),
                  ),
                  const Gap(DesignTokens.spacingSm),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: onboardingNotifier.nextStep,
                      child: const Text('Complete Setup'),
                    ),
                  ),
                ],
              ).animate().slideY(begin: 0.5, delay: 1800.ms).fadeIn(delay: 1800.ms),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeDescription(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(DesignTokens.spacingSm),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: <Widget>[
          _buildThemeDescriptionItem(
            context,
            Icons.light_mode_rounded,
            'Light Mode',
            'Clean and bright interface for daytime use',
          ),
          const Gap(DesignTokens.spacingXs),
          _buildThemeDescriptionItem(
            context,
            Icons.auto_mode_rounded,
            'Auto Mode',
            'Automatically switches based on your device settings',
          ),
          const Gap(DesignTokens.spacingXs),
          _buildThemeDescriptionItem(
            context,
            Icons.dark_mode_rounded,
            'Dark Mode',
            'Easy on the eyes for low-light environments',
          ),
        ],
      ),
    ).animate().slideY(begin: 0.3, delay: 1200.ms).fadeIn(delay: 1200.ms);
  }

  Widget _buildThemeDescriptionItem(
    BuildContext context,
    IconData icon,
    String title,
    String description,
  ) {
    final ThemeData theme = Theme.of(context);
    
    return Row(
      children: <Widget>[
        Icon(
          icon,
          size: 20,
          color: theme.colorScheme.primary,
        ),
        const Gap(DesignTokens.spacingXs),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

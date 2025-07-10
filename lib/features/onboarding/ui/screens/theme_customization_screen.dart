// lib/features/onboarding/ui/screens/theme_customization_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../../core/theme/design_tokens/design_tokens.dart';
import '../../models/onboarding_state.dart';
import '../../providers/onboarding_provider.dart';

class ThemeCustomizationScreen extends ConsumerWidget {
  const ThemeCustomizationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final OnboardingState state = ref.watch(onboardingProvider);
    final OnboardingNotifier notifier = ref.read(onboardingProvider.notifier);
    final ThemeData theme = Theme.of(context);

    final List<Map<String, String>> colors = <Map<String, String>>[
      <String, String>{'name': 'Blue', 'value': '#3366FF'},
      <String, String>{'name': 'Purple', 'value': '#8B5CF6'},
      <String, String>{'name': 'Green', 'value': '#10B981'},
      <String, String>{'name': 'Orange', 'value': '#F59E0B'},
      <String, String>{'name': 'Pink', 'value': '#EC4899'},
      <String, String>{'name': 'Teal', 'value': '#14B8A6'},
    ];

    return Scaffold(
      body: SafeArea(
        child: Padding(
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
                'Customize Your Theme',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ).animate().slideY(begin: 0.3, delay: 400.ms).fadeIn(delay: 400.ms),
              
              const Gap(DesignTokens.spacingSm),
              
              Text(
                'Choose your preferred appearance and colors',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ).animate().slideY(begin: 0.3, delay: 600.ms).fadeIn(delay: 600.ms),
              
              const Gap(DesignTokens.spacing2xl),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // Theme Mode Section
                    Text(
                      'Appearance',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ).animate().slideX(begin: 0.3, delay: 800.ms).fadeIn(delay: 800.ms),
                    
                    const Gap(DesignTokens.spacingSm),
                    
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(DesignTokens.spacingSm),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
                        border: Border.all(
                          color: theme.colorScheme.outline.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: _buildThemeOption(
                              context,
                              ref,
                              'Light',
                              Icons.light_mode_rounded,
                              false,
                              !state.isDarkMode,
                            ),
                          ),
                          const Gap(DesignTokens.spacingXs),
                          Expanded(
                            child: _buildThemeOption(
                              context,
                              ref,
                              'Dark',
                              Icons.dark_mode_rounded,
                              true,
                              state.isDarkMode,
                            ),
                          ),
                        ],
                      ),
                    ).animate().slideX(begin: 0.3, delay: 1000.ms).fadeIn(delay: 1000.ms),
                    
                    const Gap(DesignTokens.spacingLg),
                    
                    // Color Selection Section
                    Text(
                      'Primary Color',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ).animate().slideX(begin: 0.3, delay: 1200.ms).fadeIn(delay: 1200.ms),
                    
                    const Gap(DesignTokens.spacingSm),
                    
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(DesignTokens.spacingSm),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
                        border: Border.all(
                          color: theme.colorScheme.outline.withOpacity(0.3),
                        ),
                      ),
                      child: Wrap(
                        spacing: DesignTokens.spacingSm,
                        runSpacing: DesignTokens.spacingSm,
                        children: colors.asMap().entries.map((MapEntry<int, Map<String, String>> entry) {
                          final int index = entry.key;
                          final Map<String, String> color = entry.value;
                          final bool isSelected = state.primaryColorHex == color['value'];
                          
                          return GestureDetector(
                            onTap: () => notifier.setTheme(
                              state.isDarkMode,
                              color['value'],
                            ),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Color(int.parse('0xFF${color['value']!.substring(1)}')),
                                borderRadius: BorderRadius.circular(25),
                                border: Border.all(
                                  color: isSelected
                                      ? theme.colorScheme.onSurface
                                      : Colors.transparent,
                                  width: 3,
                                ),
                                boxShadow: isSelected
                                    ? <BoxShadow>[
                                        BoxShadow(
                                          color: theme.colorScheme.onSurface.withOpacity(0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: isSelected
                                  ? const Icon(
                                      Icons.check_rounded,
                                      color: Colors.white,
                                      size: 24,
                                    )
                                  : null,
                            ).animate().scale(
                              delay: Duration(milliseconds: 1400 + (index * 100)),
                              curve: Curves.easeOutBack,
                            ).fadeIn(delay: Duration(milliseconds: 1400 + (index * 100))),
                          );
                        }).toList(),
                      ),
                    ),
                    
                    const Gap(DesignTokens.spacingSm),
                    
                    Text(
                      'Selected: ${colors.firstWhere(
                        (Map<String, String> c) => c['value'] == state.primaryColorHex,
                        orElse: () => <String, String>{'name': 'Blue'},
                      )['name']}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                        fontStyle: FontStyle.italic,
                      ),
                    ).animate().slideX(begin: 0.3, delay: 1800.ms).fadeIn(delay: 1800.ms),
                    
                    const Spacer(),
                    
                    // Preview Section
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
                            Icons.preview_rounded,
                            color: theme.colorScheme.primary,
                            size: 20,
                          ),
                          const Gap(DesignTokens.spacingXs),
                          Expanded(
                            child: Text(
                              'You can always change these settings later in the app.',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ).animate().slideY(begin: 0.3, delay: 2000.ms).fadeIn(delay: 2000.ms),
                  ],
                ),
              ),
              
              const Gap(DesignTokens.spacingSm),
              
              Row(
                children: <Widget>[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: notifier.previousStep,
                      child: const Text('Back'),
                    ),
                  ),
                  const Gap(DesignTokens.spacingSm),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: notifier.nextStep,
                      child: const Text('Complete Setup'),
                    ),
                  ),
                ],
              ).animate().slideY(begin: 0.5, delay: 2200.ms).fadeIn(delay: 2200.ms),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    WidgetRef ref,
    String label,
    IconData icon,
    bool isDark,
    bool isSelected,
  ) {
    final ThemeData theme = Theme.of(context);
    final OnboardingNotifier notifier = ref.read(onboardingProvider.notifier);
    final OnboardingState state = ref.watch(onboardingProvider);
    
    return GestureDetector(
      onTap: () => notifier.setTheme(isDark, state.primaryColorHex),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(DesignTokens.spacingSm),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primaryContainer.withOpacity(0.3)
              : theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: <Widget>[
            Icon(
              icon,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withOpacity(0.7),
              size: 28,
            ),
            const Gap(DesignTokens.spacingXs),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

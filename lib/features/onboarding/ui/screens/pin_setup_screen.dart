import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../../core/theme/design_tokens/design_tokens.dart';
import '../../../../shared/widgets/input/pin/pin_input_widget.dart';
import '../../models/onboarding_state.dart';
import '../../providers/onboarding_provider.dart';

class PinSetupScreen extends ConsumerWidget {
  const PinSetupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final OnboardingState state = ref.watch(onboardingProvider);
    final OnboardingNotifier notifier = ref.read(onboardingProvider.notifier);
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              
              return Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spacingMd),
                    child: Column(
                      children: <Widget>[
                        Icon(
                          Icons.lock_outline_rounded,
                          size: 48,
                          color: theme.colorScheme.primary,
                        ).animate().scale(delay: 200.ms, curve: Curves.easeOutBack),
                        
                        Text(
                          'Create Your PIN',
                          style: theme.textTheme.headlineSmall?.copyWith( // Smaller headline
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.center,
                        ).animate().slideY(begin: 0.3, delay: 400.ms).fadeIn(delay: 400.ms),
                        
                        Text(
                          'Choose a 4-6 digit PIN to secure your financial data',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                          textAlign: TextAlign.center,
                        ).animate().slideY(begin: 0.3, delay: 600.ms).fadeIn(delay: 600.ms),
                        
                        Container(
                          padding: const EdgeInsets.all(DesignTokens.spacingXs),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                          ),
                          child: Row(
                            children: <Widget>[
                              Icon(
                                Icons.info_outline,
                                color: theme.colorScheme.primary,
                                size: 16,
                              ),
                              const Gap(DesignTokens.spacingXs),
                              Text(
                                'Your PIN is stored securely and never shared.',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onPrimaryContainer,
                                ),
                              ),
                            ],
                          ),
                        ).animate().slideY(begin: 0.3, delay: 800.ms).fadeIn(delay: 800.ms),
                      ],
                    ),
                  ),
          
                  const Gap(DesignTokens.spacingSm),
                  
                  SizedBox(
                    child: PinInputWidget(
                      pin: state.pin ?? '',
                      onChanged: notifier.updatePin,
                      animationDelay: 1000.ms,
                    ),
                  ),
          
                  const Gap(DesignTokens.spacingXl),
                  
                  // Actions - fixed height
                  Padding(
                    padding: const EdgeInsets.all(DesignTokens.spacingMd),
                    child: Row(
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
                            onPressed: state.isPinValid ? notifier.nextStep : null,
                            child: state.isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Text('Continue'),
                          ),
                        ),
                      ],
                    ).animate().slideY(begin: 0.5, delay: 1200.ms).fadeIn(delay: 1200.ms),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

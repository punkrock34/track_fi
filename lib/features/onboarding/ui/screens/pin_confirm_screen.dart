// lib/features/onboarding/ui/screens/pin_confirm_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../../core/theme/design_tokens/design_tokens.dart';
import '../../models/onboarding_state.dart';
import '../../providers/onboarding_provider.dart';
import '../widgets/pin_input_widget.dart';

class PinConfirmScreen extends ConsumerWidget {
  const PinConfirmScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final OnboardingState state = ref.watch(onboardingProvider);
    final OnboardingNotifier notifier = ref.read(onboardingProvider.notifier);
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(DesignTokens.spacingMd),
          child: Column(
            children: <Widget>[
              const Gap(DesignTokens.spacingXl),
              
              Icon(
                Icons.verified_outlined,
                size: 80,
                color: theme.colorScheme.primary,
              ).animate().scale(delay: 200.ms, curve: Curves.easeOutBack),
              
              const Gap(DesignTokens.spacingLg),
              
              Text(
                'Confirm Your PIN',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ).animate().slideY(begin: 0.3, delay: 400.ms).fadeIn(delay: 400.ms),
              
              const Gap(DesignTokens.spacingSm),
              
              Text(
                'Enter your PIN again to confirm',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ).animate().slideY(begin: 0.3, delay: 600.ms).fadeIn(delay: 600.ms),
              
              const Gap(DesignTokens.spacing2xl),
              
              PinInputWidget(
                pin: state.confirmPin ?? '',
                onChanged: notifier.updateConfirmPin,
                errorText: state.error,
              ).animate().slideY(begin: 0.5, delay: 800.ms).fadeIn(delay: 800.ms),
              
              if (state.confirmPin != null && state.confirmPin!.isNotEmpty) ...<Widget>[
                const Gap(DesignTokens.spacingXl),
                Container(
                  padding: const EdgeInsets.all(DesignTokens.spacingSm),
                  decoration: BoxDecoration(
                    color: state.pinsMatch
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                  ),
                  child: Row(
                    children: <Widget>[
                      Icon(
                        state.pinsMatch ? Icons.check_circle : Icons.error,
                        color: state.pinsMatch ? Colors.green : Colors.red,
                        size: 20,
                      ),
                      const Gap(DesignTokens.spacingXs),
                      Expanded(
                        child: Text(
                          state.pinsMatch ? 'PINs match!' : 'PINs do not match',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: state.pinsMatch ? Colors.green : Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate().slideY(begin: 0.3, delay: 100.ms).fadeIn(delay: 100.ms),
              ],
              
              const Spacer(),
              
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
                      onPressed: state.pinsMatch && (state.confirmPin?.length ?? 0) >= 4
                          ? () async {
                              final bool success = await notifier.validateAndSavePin();
                              if (success) {
                                notifier.nextStep();
                              }
                            }
                          : null,
                      child: state.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Save PIN'),
                    ),
                  ),
                ],
              ).animate().slideY(begin: 0.5, delay: 1000.ms).fadeIn(delay: 1000.ms),
            ],
          ),
        ),
      ),
    );
  }
}

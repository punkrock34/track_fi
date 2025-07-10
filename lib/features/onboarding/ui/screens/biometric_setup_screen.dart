import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../../core/theme/design_tokens/design_tokens.dart';
import '../../providers/onboarding_provider.dart';

class BiometricSetupScreen extends ConsumerWidget {
  const BiometricSetupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final OnboardingNotifier notifier = ref.read(onboardingProvider.notifier);
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(DesignTokens.spacingMd),
          child: Column(
            children: <Widget>[
              const Gap(DesignTokens.spacingXl),
              
              Icon(
                Icons.fingerprint,
                size: 80,
                color: theme.colorScheme.primary,
              ).animate().scale(delay: 200.ms, curve: Curves.easeOutBack),
              
              const Gap(DesignTokens.spacingLg),
              
              Text(
                'Setup Biometric Authentication',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ).animate().slideY(begin: 0.3, delay: 400.ms).fadeIn(delay: 400.ms),
              
              const Gap(DesignTokens.spacingSm),
              
              Text(
                'Enable biometric authentication for quick and secure access',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ).animate().slideY(begin: 0.3, delay: 600.ms).fadeIn(delay: 600.ms),
              
              const Gap(DesignTokens.spacing3xl),
              
              Row(
                children: <Widget>[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        notifier.setBiometric(false);
                        notifier.nextStep();
                      },
                      child: const Text('Skip'),
                    ),
                  ),
                  const Gap(DesignTokens.spacingSm),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () async {
                        notifier.setBiometric(true);
                        final bool success = await notifier.setupBiometric();
                        if (success) {
                          notifier.nextStep();
                        }
                      },
                      child: const Text('Enable'),
                    ),
                  ),
                ],
              ).animate().slideY(begin: 0.5, delay: 800.ms).fadeIn(delay: 800.ms),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/secure_storage/pin_storage_provider.dart';
import '../../../core/theme/design_tokens/design_tokens.dart';
import '../models/onboarding_state.dart';
import '../providers/onboarding_provider.dart';
import 'screens/biometric_setup_screen.dart';
import 'screens/onboarding_complete_screen.dart';
import 'screens/pin_confirm_screen.dart';
import 'screens/pin_setup_screen.dart';
import 'screens/theme_customization_screen.dart';
import 'screens/welcome_screen.dart';
import 'widgets/progress_indicator_widget.dart';

class OnboardingCoordinator extends ConsumerWidget {
  const OnboardingCoordinator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final OnboardingState state = ref.watch(onboardingProvider);
    
  ref.listen<OnboardingState>(onboardingProvider, (OnboardingState? previous, OnboardingState current) async {
    if (current.currentStep == OnboardingStep.complete) {
      final bool hasPin = await ref.read(pinStorageProvider).hasPinSet();
      if (!hasPin) {
        ref.read(onboardingProvider.notifier).goToStep(OnboardingStep.pinSetup);
        return;
      }
      
      Future<void>.delayed(const Duration(seconds: 2), () {
        if (context.mounted) {
          context.go('/dashboard');
        }
      });
    }
  });

    return Scaffold(
      body: Column(
        children: <Widget>[
          // Progress indicator (except for welcome and complete screens)
          if (state.currentStep != OnboardingStep.welcome &&
              state.currentStep != OnboardingStep.complete)
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spacingMd, vertical: DesignTokens.spacingSm),
                child: ProgressIndicatorWidget(progress: state.progress, totalSteps: state.totalSteps),
              ),
            ),
          
          // Main content
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _buildCurrentScreen(state.currentStep),
            ).animate().fadeIn(duration: 300.ms),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentScreen(OnboardingStep step) {
    switch (step) {
      case OnboardingStep.welcome:
        return const WelcomeScreen();
      case OnboardingStep.pinSetup:
        return const PinSetupScreen();
      case OnboardingStep.pinConfirm:
        return const PinConfirmScreen();
      case OnboardingStep.biometricSetup:
        return const BiometricSetupScreen();
      case OnboardingStep.themeCustomization:
        return const ThemeCustomizationScreen();
      case OnboardingStep.complete:
        return const OnboardingCompleteScreen();
    }
  }
}

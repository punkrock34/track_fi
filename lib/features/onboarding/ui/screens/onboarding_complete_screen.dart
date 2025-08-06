import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/design_tokens/design_tokens.dart';
import '../../models/onboarding_state.dart';
import '../../providers/onboarding_provider.dart';

class OnboardingCompleteScreen extends ConsumerStatefulWidget {
  const OnboardingCompleteScreen({super.key});

  @override
  ConsumerState<OnboardingCompleteScreen> createState() => _OnboardingCompleteScreenState();
}

class _OnboardingCompleteScreenState extends ConsumerState<OnboardingCompleteScreen> {
  bool _isCompletingOnboarding = false;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final OnboardingNotifier onboardingNotifier = ref.read(onboardingProvider.notifier);
    final OnboardingState onboardingState = ref.watch(onboardingProvider);

    ref.listen<OnboardingState>(onboardingProvider, (
      OnboardingState? previous,
      OnboardingState current,
    ) {
      if (current.currentStep == OnboardingStep.complete && _isCompletingOnboarding) {
        Future<void>.delayed(const Duration(milliseconds: 500), () {
          if (context.mounted) {
            context.goNamed('dashboard');
          }
        });
      }
    });

    final bool isLoading = _isCompletingOnboarding || onboardingState.isLoading;

    return Scaffold(
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
          child: Column(
            children: <Widget>[
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(DesignTokens.spacingMd),
                  child: Column(
                    children: <Widget>[
                      const Gap(DesignTokens.spacingXl),
                      
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                          shape: BoxShape.circle,
                          border: Border.all(color: theme.colorScheme.primary.withOpacity(0.2), width: 2),
                        ),
                        child: Icon(
                          Icons.check_circle_rounded,
                          color: theme.colorScheme.primary,
                          size: 60,
                        ),
                      ).animate().scale(duration: 800.ms, curve: Curves.easeOutBack),

                      const Gap(DesignTokens.spacing2xl),

                      Text(
                        'Welcome to TrackFi!',
                        style: theme.textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: theme.colorScheme.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ).animate().slideY(begin: 0.3, delay: 400.ms).fadeIn(delay: 400.ms),

                      const Gap(DesignTokens.spacingSm),

                      Text(
                        'Your account is set up and ready to go. Start tracking your finances securely.',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ).animate().slideY(begin: 0.3, delay: 600.ms).fadeIn(delay: 600.ms),

                      const Gap(DesignTokens.spacing2xl),

                      Container(
                        padding: const EdgeInsets.all(DesignTokens.spacingMd),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
                          border: Border.all(color: theme.colorScheme.outline.withOpacity(0.3)),
                        ),
                        child: Column(
                          children: <Widget>[
                            Text(
                              "You're all set with:",
                              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            const Gap(DesignTokens.spacingSm),
                            _buildFeatureSummary(Icons.lock_rounded, 'Secure PIN Protection'),
                            const Gap(DesignTokens.spacingXs),
                            _buildFeatureSummary(Icons.fingerprint, 'Biometric Authentication'),
                            const Gap(DesignTokens.spacingXs),
                            _buildFeatureSummary(Icons.palette_rounded, 'Personalized Theme'),
                          ],
                        ),
                      ).animate().slideY(begin: 0.5, delay: 800.ms).fadeIn(delay: 800.ms),
                    ],
                  ),
                ),
              ),
              
              // Fixed button at bottom
              Padding(
                padding: const EdgeInsets.all(DesignTokens.spacingMd),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () async {
                            setState(() {
                              _isCompletingOnboarding = true;
                            });

                            try {
                              final bool success = await onboardingNotifier.completeOnboarding();
                              if (!success) {
                                setState(() {
                                  _isCompletingOnboarding = false;
                                });
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Failed to complete onboarding. Please try again.',
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            } catch (e) {
                              setState(() {
                                _isCompletingOnboarding = false;
                              });
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('An error occurred. Please try again.'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      elevation: 8,
                      shadowColor: Colors.black.withOpacity(0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                      ),
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: isLoading
                          ? SizedBox(
                              key: const ValueKey<String>('loading'),
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  theme.colorScheme.onPrimary,
                                ),
                              ),
                            )
                          : Text(
                              key: const ValueKey<String>('text'),
                              'Enter TrackFi',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: theme.colorScheme.onPrimary,
                              ),
                            ),
                    ),
                  ),
                ).animate().slideY(begin: 0.5, delay: 1200.ms).fadeIn(delay: 1200.ms),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureSummary(IconData icon, String text) {
    final ThemeData theme = Theme.of(context);

    return Row(
      children: <Widget>[
        Icon(icon, color: theme.colorScheme.primary, size: 20),
        const Gap(DesignTokens.spacingXs),
        Text(
          text,
          style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.8), fontSize: 14),
        ),
      ],
    );
  }
}

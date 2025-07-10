// lib/features/onboarding/ui/screens/onboarding_complete_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../../core/theme/design_tokens/design_tokens.dart';
import '../../providers/onboarding_provider.dart';

class OnboardingCompleteScreen extends ConsumerStatefulWidget {
  const OnboardingCompleteScreen({super.key});

  @override
  ConsumerState<OnboardingCompleteScreen> createState() => _OnboardingCompleteScreenState();
}

class _OnboardingCompleteScreenState extends ConsumerState<OnboardingCompleteScreen> {
  @override
  void initState() {
    super.initState();
    // Complete onboarding after screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(onboardingProvider.notifier).completeOnboarding();
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: <Color>[
              theme.colorScheme.primary,
              theme.colorScheme.secondary,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(DesignTokens.spacingMd),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // Success Animation
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: Colors.white,
                    size: 60,
                  ),
                ).animate().scale(
                  duration: 800.ms,
                  curve: Curves.easeOutBack,
                ),
                
                Gap(size.height * 0.05),
                
                Text(
                  'Welcome to TrackFi!',
                  style: theme.textTheme.headlineLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                  textAlign: TextAlign.center,
                ).animate().slideY(begin: 0.3, delay: 400.ms).fadeIn(delay: 400.ms),
                
                const Gap(DesignTokens.spacingSm),
                
                Text(
                  'Your account is set up and ready to go. Start tracking your finances securely.',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ).animate().slideY(begin: 0.3, delay: 600.ms).fadeIn(delay: 600.ms),
                
                Gap(size.height * 0.08),
                
                // Feature Summary
                Container(
                  padding: const EdgeInsets.all(DesignTokens.spacingMd),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    children: <Widget>[
                      Text(
                        "You're all set with:",
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
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
                
                Gap(size.height * 0.05),
                
                Text(
                  'Redirecting to your dashboard...',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.8),
                  ),
                ).animate().slideY(begin: 0.3, delay: 1000.ms).fadeIn(delay: 1000.ms),
                
                const Gap(DesignTokens.spacingSm),
                
                SizedBox(
                  width: 30,
                  height: 30,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.white.withOpacity(0.8),
                    ),
                    strokeWidth: 3,
                  ),
                ).animate().scale(delay: 1200.ms, curve: Curves.easeInOut),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureSummary(IconData icon, String text) {
    return Row(
      children: <Widget>[
        Icon(icon, color: Colors.white, size: 20),
        const Gap(DesignTokens.spacingXs),
        Text(
          text,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

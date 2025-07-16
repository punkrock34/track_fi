import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/session/session_provider.dart';
import '../../../core/theme/design_tokens/design_tokens.dart';
import '../../../shared/widgets/input/pin_input_widget.dart';
import '../../auth/models/auth_state.dart';
import '../../auth/providers/auth_provider.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  @override
  Widget build(BuildContext context) {
    final AuthenticationState authState = ref.watch(authenticationProvider);
    final AuthenticationNotifier authNotifier = ref.read(authenticationProvider.notifier);
    final ThemeData theme = Theme.of(context);

    ref.listen<AuthenticationState>(authenticationProvider, (
      AuthenticationState? previous,
      AuthenticationState current,
    ) {
      if (current.currentStep == AuthenticationStep.success) {
        ref.read(sessionProvider.notifier).setAuthenticated(true);
        Future<void>.delayed(const Duration(milliseconds: 500), () {
          if (context.mounted) {
            context.go('/dashboard');
          }
        });
      }
    });

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
          child: SingleChildScrollView(
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                
                return Column(
                  children: <Widget>[
                    const Gap(DesignTokens.spacing3xl),
                    
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spacingMd),
                      child: Column(
                        children: <Widget>[
                          // App branding
                          Container(
                            padding: const EdgeInsets.all(DesignTokens.spacingMd),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                  color: theme.colorScheme.primary.withOpacity(0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.account_balance_wallet_rounded,
                              size: 48,
                              color: theme.colorScheme.onPrimary,
                            ),
                          ).animate().scale(delay: 200.ms, curve: Curves.easeOutBack),
                          
                          const Gap(DesignTokens.spacingMd),
                          
                          Text(
                            'Welcome Back',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: theme.colorScheme.onBackground,
                              fontWeight: FontWeight.w800,
                            ),
                          ).animate().slideY(begin: 0.3, delay: 400.ms).fadeIn(delay: 400.ms),
                          
                          const Gap(DesignTokens.spacingXs),
                          
                          Text(
                            authState.showBiometricButton
                                ? 'Enter your PIN or use ${authState.biometricTypeName}'
                                : 'Enter your PIN to access your account',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onBackground.withOpacity(0.7),
                            ),
                            textAlign: TextAlign.center,
                          ).animate().slideY(begin: 0.3, delay: 600.ms).fadeIn(delay: 600.ms),
                          
                          // Biometric progress indicator
                          if (authState.isBiometricInProgress) ...<Widget>[
                            const Gap(DesignTokens.spacingSm),
                            Container(
                              padding: const EdgeInsets.all(DesignTokens.spacingSm),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primaryContainer.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: theme.colorScheme.primary,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                  const Gap(DesignTokens.spacingSm),
                                  Text(
                                    'Authenticating...',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          // Attempt counter
                          if (authState.attemptCount > 0 && !authState.isLocked) ...<Widget>[
                            const Gap(DesignTokens.spacingXs),
                            Text(
                              '${authState.remainingAttempts} attempts remaining',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.error,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],

                          // Lockout display
                          if (authState.isLocked) ...<Widget>[
                            const Gap(DesignTokens.spacingSm),
                            Container(
                              padding: const EdgeInsets.all(DesignTokens.spacingSm),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.errorContainer.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                                border: Border.all(
                                  color: theme.colorScheme.error.withOpacity(0.3),
                                ),
                              ),
                              child: Column(
                                children: <Widget>[
                                  Icon(
                                    Icons.lock_clock_rounded,
                                    color: theme.colorScheme.error,
                                    size: 24,
                                  ),
                                  const Gap(DesignTokens.spacingXs),
                                  Text(
                                    'Account Temporarily Locked',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.error,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const Gap(DesignTokens.spacingXs),
                                  Text(
                                    'Too many failed attempts. Please wait before trying again.',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.error.withOpacity(0.8),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  if (authState.remainingLockoutTime != null) ...<Widget>[
                                    const Gap(DesignTokens.spacingXs),
                                    Text(
                                      'Time remaining: ${_formatDuration(authState.remainingLockoutTime!)}',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.error,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const Gap(DesignTokens.spacingLg),

                    // Main content based on step
                    if (!authState.isLocked && authState.currentStep == AuthenticationStep.initial)
                      SizedBox(
                        child: Column(
                          children: <Widget>[
                            CircularProgressIndicator(
                              color: theme.colorScheme.primary,
                            ),
                            const Gap(DesignTokens.spacingSm),
                            Text(
                              'Setting up authentication...',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ).animate().fadeIn(),
                      )
                    else if (!authState.isLocked &&
                              (authState.currentStep == AuthenticationStep.pin ||
                              authState.currentStep == AuthenticationStep.biometric)
                            )
                      SizedBox(
                        child: PinInputWidget(
                          pin: authState.pin,
                          onChanged: authNotifier.updatePin,
                          mode: PinInputMode.auth,
                          showBiometric: authState.showBiometricButton,
                          biometricIcon: authState.biometricIcon,
                          onBiometricPressed: authState.showBiometricButton ? authNotifier.retryBiometric : null,
                          autoSubmit: true,
                          onAutoSubmit: authNotifier.authenticateWithPin,
                          expectedPinLength: authState.expectedPinLength,
                          animationDelay: 800.ms,
                        ),
                      )
                    else if (authState.currentStep == AuthenticationStep.success)
                      SizedBox(
                        child: Column(
                          children: <Widget>[
                            Container(
                              padding: const EdgeInsets.all(DesignTokens.spacingLg),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.check_circle_rounded,
                                size: 64,
                                color: theme.colorScheme.primary,
                              ),
                            ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
                            
                            const Gap(DesignTokens.spacingLg),
                            
                            Text(
                              'Welcome back!',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: theme.colorScheme.primary,
                              ),
                            ).animate().slideY(begin: 0.3, delay: 200.ms).fadeIn(delay: 200.ms),
                            
                            const Gap(DesignTokens.spacingSm),
                            
                            Text(
                              'Taking you to your dashboard...',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(0.7),
                              ),
                            ).animate().slideY(begin: 0.3, delay: 400.ms).fadeIn(delay: 400.ms),
                          ],
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final int minutes = duration.inMinutes;
    final int seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

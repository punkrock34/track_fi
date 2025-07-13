import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/session/session_provider.dart';
import '../../../core/theme/design_tokens/design_tokens.dart';
import '../../../features/onboarding/ui/widgets/pin_input_widget.dart';
import '../models/auth_state.dart';
import '../providers/auth_provider.dart';

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
    final Size size = MediaQuery.of(context).size;

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
            padding: const EdgeInsets.all(DesignTokens.spacingMd),
            child: Column(
              children: <Widget>[
                Gap(size.height * 0.08),
                
                // App branding
                _buildBrandingSection(theme),
                
                Gap(size.height * 0.06),
                
                // Main content based on authentication step
                if (authState.currentStep == AuthenticationStep.initial)
                  _buildLoadingSection(theme),
                
                if (authState.currentStep == AuthenticationStep.biometric)
                  _buildBiometricSection(theme, authNotifier),
                
                if (authState.currentStep == AuthenticationStep.pin)
                  _buildPinSection(theme, authState, authNotifier),
                
                if (authState.currentStep == AuthenticationStep.success)
                  _buildSuccessSection(theme),
                
                // Error display
                if (authState.errorMessage != null) ...<Widget>[
                  const Gap(DesignTokens.spacingMd),
                  _buildErrorSection(theme, authState.errorMessage!),
                ],
                
                // Lockout display
                if (authState.isLocked) ...<Widget>[
                  const Gap(DesignTokens.spacingMd),
                  _buildLockoutSection(theme, authState),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBrandingSection(ThemeData theme) {
    return Column(
      children: <Widget>[
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
        )
            .animate()
            .scale(delay: 200.ms, curve: Curves.easeOutBack),
        
        const Gap(DesignTokens.spacingMd),
        
        Text(
          'Welcome Back',
          style: theme.textTheme.headlineMedium?.copyWith(
            color: theme.colorScheme.onBackground,
            fontWeight: FontWeight.w800,
          ),
        )
            .animate()
            .slideY(begin: 0.3, delay: 400.ms)
            .fadeIn(delay: 400.ms),
        
        const Gap(DesignTokens.spacingXs),
        
        Text(
          'Please authenticate to continue',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onBackground.withOpacity(0.7),
          ),
        )
            .animate()
            .slideY(begin: 0.3, delay: 600.ms)
            .fadeIn(delay: 600.ms),
      ],
    );
  }

  Widget _buildLoadingSection(ThemeData theme) {
    return Column(
      children: <Widget>[
        CircularProgressIndicator(
          color: theme.colorScheme.primary,
        ),
        const Gap(DesignTokens.spacingMd),
        Text(
          'Setting up authentication...',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    ).animate().fadeIn();
  }

  Widget _buildBiometricSection(ThemeData theme, AuthenticationNotifier notifier) {
    return Column(
      children: <Widget>[
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
            Icons.fingerprint,
            size: 64,
            color: theme.colorScheme.primary,
          ),
        )
            .animate(onPlay: (AnimationController controller) => controller.repeat(reverse: true))
            .scale(
              begin: const Offset(0.9, 0.9),
              end: const Offset(1.1, 1.1),
              duration: 2000.ms,
            ),
        
        const Gap(DesignTokens.spacingLg),
        
        Text(
          'Touch to unlock',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ).animate().slideY(begin: 0.3, delay: 200.ms).fadeIn(delay: 200.ms),
        
        const Gap(DesignTokens.spacingSm),
        
        Text(
          'Use your fingerprint or face to access TrackFi',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        ).animate().slideY(begin: 0.3, delay: 400.ms).fadeIn(delay: 400.ms),
        
        const Gap(DesignTokens.spacingXl),
        
        TextButton.icon(
          onPressed: notifier.fallbackToPin,
          icon: const Icon(Icons.dialpad_rounded),
          label: const Text('Use PIN instead'),
        ).animate().slideY(begin: 0.3, delay: 600.ms).fadeIn(delay: 600.ms),
      ],
    );
  }

  Widget _buildPinSection(ThemeData theme, AuthenticationState state, AuthenticationNotifier notifier) {
    return Column(
      children: <Widget>[
        Icon(
          Icons.lock_outline_rounded,
          size: 64,
          color: theme.colorScheme.primary,
        ).animate().scale(delay: 200.ms, curve: Curves.easeOutBack),
        
        const Gap(DesignTokens.spacingLg),
        
        Text(
          'Enter Your PIN',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ).animate().slideY(begin: 0.3, delay: 400.ms).fadeIn(delay: 400.ms),
        
        const Gap(DesignTokens.spacingSm),
        
        Text(
          'Enter your PIN to access your account',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        ).animate().slideY(begin: 0.3, delay: 600.ms).fadeIn(delay: 600.ms),
        
        const Gap(DesignTokens.spacing2xl),
        
        PinInputWidget(
          pin: state.pin,
          onChanged: notifier.updatePin,
          errorText: state.errorMessage,
        ).animate().slideY(begin: 0.5, delay: 800.ms).fadeIn(delay: 800.ms),
        
        if (state.isPinComplete && !state.isLoading) ...<Widget>[
          const Gap(DesignTokens.spacingXl),
          SizedBox(
            width: 200,
            child: ElevatedButton(
              onPressed: state.canAttemptAuth ? notifier.authenticateWithPin : null,
              child: const Text('Unlock'),
            ),
          ).animate().slideY(begin: 0.3, delay: 100.ms).fadeIn(delay: 100.ms),
        ],
        
        if (state.isLoading) ...<Widget>[
          const Gap(DesignTokens.spacingXl),
          const CircularProgressIndicator(),
        ],
        
        // Attempt counter
        if (state.attemptCount > 0 && !state.isLocked) ...<Widget>[
          const Gap(DesignTokens.spacingMd),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: DesignTokens.spacingSm,
              vertical: DesignTokens.spacingXs,
            ),
            decoration: BoxDecoration(
              color: theme.colorScheme.errorContainer.withOpacity(0.1),
              borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
            ),
            child: Text(
              '${state.remainingAttempts} attempts remaining',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSuccessSection(ThemeData theme) {
    return Column(
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
    );
  }

  Widget _buildErrorSection(ThemeData theme, String error) {
    return Container(
      padding: const EdgeInsets.all(DesignTokens.spacingSm),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withOpacity(0.1),
        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
        border: Border.all(
          color: theme.colorScheme.error.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            Icons.error_outline,
            color: theme.colorScheme.error,
            size: 20,
          ),
          const Gap(DesignTokens.spacingXs),
          Expanded(
            child: Text(
              error,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    ).animate().shake(hz: 4, curve: Curves.easeInOut).fadeIn();
  }

  Widget _buildLockoutSection(ThemeData theme, AuthenticationState state) {
    return Container(
      padding: const EdgeInsets.all(DesignTokens.spacingMd),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withOpacity(0.2),
        borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
        border: Border.all(
          color: theme.colorScheme.error.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: <Widget>[
          Icon(
            Icons.lock_clock_rounded,
            color: theme.colorScheme.error,
            size: 32,
          ),
          const Gap(DesignTokens.spacingSm),
          Text(
            'Account Temporarily Locked',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.error,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Gap(DesignTokens.spacingXs),
          Text(
            'Too many failed attempts. Please wait before trying again.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
          if (state.remainingLockoutTime != null) ...<Widget>[
            const Gap(DesignTokens.spacingXs),
            Text(
              'Time remaining: ${_formatDuration(state.remainingLockoutTime!)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final int minutes = duration.inMinutes;
    final int seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

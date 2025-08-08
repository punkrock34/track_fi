import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../../core/theme/design_tokens/design_tokens.dart';
import '../../../../shared/widgets/input/pin/pin_input_widget.dart';
import '../../models/onboarding_state.dart';
import '../../providers/onboarding_provider.dart';

class PinConfirmScreen extends ConsumerStatefulWidget {
  const PinConfirmScreen({super.key});

  @override
  ConsumerState<PinConfirmScreen> createState() => _PinConfirmScreenState();
}

class _PinConfirmScreenState extends ConsumerState<PinConfirmScreen> {
  bool _hasAttemptedSubmit = false;
  String? _validationError;

  @override
  Widget build(BuildContext context) {
    final OnboardingState state = ref.watch(onboardingProvider);
    final OnboardingNotifier notifier = ref.read(onboardingProvider.notifier);
    final ThemeData theme = Theme.of(context);
    
    final bool isComplete = (state.confirmPin?.length ?? 0) >= 4;
    
    final bool shouldShowValidation = _hasAttemptedSubmit && isComplete;
    final String? displayError = shouldShowValidation ? _validationError : state.errorMessage;

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
                          Icons.verified_outlined,
                          size: 48,
                          color: theme.colorScheme.primary,
                        ).animate().scale(delay: 200.ms, curve: Curves.easeOutBack),
                        
                        Text(
                          'Confirm Your PIN',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.center,
                        ).animate().slideY(begin: 0.3, delay: 400.ms).fadeIn(delay: 400.ms),
                        
                        Text(
                          'Enter your PIN again to confirm',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                          textAlign: TextAlign.center,
                        ).animate().slideY(begin: 0.3, delay: 600.ms).fadeIn(delay: 600.ms),
                      ],
                    ),
                  ),
          
                  const Gap(DesignTokens.spacingSm),
                  
                  SizedBox(
                    child: PinInputWidget(
                      pin: state.confirmPin ?? '',
                      onChanged: (String pin) {
                        notifier.updateConfirmPin(pin);

                        if (_hasAttemptedSubmit) {
                          setState(() {
                            _hasAttemptedSubmit = false;
                            _validationError = null;
                          });
                        }
                      },
                      mode: PinInputMode.confirm,
                      maxLength: state.pin?.length ?? 6,
                      showRealTimeValidation: false,
                      animationDelay: 800.ms,
                    ),
                  ),

                  // Error display
                  if (displayError != null) ...<Widget>[
                    const Gap(DesignTokens.spacingSm),
                    Container(
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
                              displayError,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.error,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ).animate().shake(hz: 4, curve: Curves.easeInOut).fadeIn(),
                  ],
          
                  const Gap(DesignTokens.spacingMd),
                  
                  // Actions
                  Padding(
                    padding: const EdgeInsets.all(DesignTokens.spacingMd),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: OutlinedButton(
                             onPressed: () {
                              notifier.updatePin('');
                              notifier.updateConfirmPin('');
                              notifier.previousStep();
                            },
                            child: const Text('Back'),
                          ),
                        ),
                        const Gap(DesignTokens.spacingSm),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: isComplete ? () => _handleSubmit() : null,
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
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    final OnboardingState state = ref.read(onboardingProvider);
    final OnboardingNotifier notifier = ref.read(onboardingProvider.notifier);
    
    setState(() {
      _hasAttemptedSubmit = true;
    });

    if (!state.pinsMatch) {
      setState(() {
        _validationError = 'PINs do not match. Please try again.';
      });
      return;
    }

    if (!state.isPinValid) {
      setState(() {
        _validationError = 'PIN must be 4-6 digits';
      });
      return;
    }

    setState(() {
      _validationError = null;
    });

    final bool success = await notifier.validateAndSavePin();
    if (success) {
      notifier.nextStep();
    }
  }
}

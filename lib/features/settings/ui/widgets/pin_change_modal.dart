import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../../core/contracts/services/auth/biometric/i_biometric_service.dart';
import '../../../../core/contracts/services/secure_storage/i_biometric_storage_service.dart';
import '../../../../core/contracts/services/secure_storage/i_pin_storage_service.dart';
import '../../../../core/models/auth/biometric/biometric_auth_result.dart';
import '../../../../core/providers/auth/biometric/biometric_service_provider.dart';
import '../../../../core/providers/secure_storage/biometric_storage_provider.dart';
import '../../../../core/providers/secure_storage/pin_storage_provider.dart';
import '../../../../core/theme/design_tokens/design_tokens.dart';
import '../../../../shared/widgets/input/pin/compact_pin_input_widget.dart';
import '../../../../shared/widgets/input/pin/pin_input_widget.dart';

enum PinChangeStep {
  currentAuth,
  newPin,
  confirmPin,
  success,
}

class PinChangeModal extends ConsumerStatefulWidget {
  const PinChangeModal({super.key});

  @override
  ConsumerState<PinChangeModal> createState() => _PinChangeModalState();
}

class _PinChangeModalState extends ConsumerState<PinChangeModal> {
  PinChangeStep _currentStep = PinChangeStep.currentAuth;
  String _currentPin = '';
  String _newPin = '';
  String _confirmPin = '';
  bool _isLoading = false;
  String? _errorMessage;
  bool _canUseBiometric = false;

  @override
  void initState() {
    super.initState();
    _checkBiometricAvailability();
  }

  Future<void> _checkBiometricAvailability() async {
    final IBiometricStorageService biometricStorage = ref.read(biometricStorageProvider);
    final IBiometricService biometricService = ref.read(biometricServiceProvider);
    
    final bool enabled = await biometricStorage.isBiometricEnabled();
    final bool available = await biometricService.isAvailable();
    
    setState(() {
      _canUseBiometric = enabled && available;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Size screenSize = MediaQuery.of(context).size;
    
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
      ),
      insetPadding: const EdgeInsets.all(DesignTokens.spacingMd),
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(
          maxWidth: 400,
          maxHeight: screenSize.height * 0.8, // Responsive height
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // Header
            Container(
              padding: const EdgeInsets.all(DesignTokens.spacingMd),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(DesignTokens.radiusLg),
                  topRight: Radius.circular(DesignTokens.radiusLg),
                ),
              ),
              child: _buildHeader(theme),
            ),
            
            // Content
            Flexible(
              child: Container(
                padding: const EdgeInsets.all(DesignTokens.spacingMd),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    if (_errorMessage != null) ...<Widget>[
                      _buildErrorMessage(theme),
                      const Gap(DesignTokens.spacingSm),
                    ],
                    
                    Flexible(
                      child: _buildCurrentStep(theme),
                    ),
                  ],
                ),
              ),
            ),
            
            // Actions
            Container(
              padding: const EdgeInsets.all(DesignTokens.spacingMd),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(DesignTokens.radiusLg),
                  bottomRight: Radius.circular(DesignTokens.radiusLg),
                ),
              ),
              child: _buildActions(theme),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    String title;
    IconData icon;
    
    switch (_currentStep) {
      case PinChangeStep.currentAuth:
        title = 'Verify Current PIN';
        icon = Icons.lock_outline_rounded;
      case PinChangeStep.newPin:
        title = 'Enter New PIN';
        icon = Icons.pin_rounded;
      case PinChangeStep.confirmPin:
        title = 'Confirm New PIN';
        icon = Icons.verified_outlined;
      case PinChangeStep.success:
        title = 'PIN Changed Successfully';
        icon = Icons.check_circle_outline_rounded;
    }

    return Row(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withOpacity(0.3),
            borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
          ),
          child: Icon(
            icon,
            color: theme.colorScheme.primary,
            size: 20,
          ),
        ),
        const Gap(DesignTokens.spacingSm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              if (_currentStep != PinChangeStep.success)
                Text(
                  _getStepDescription(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close_rounded),
          iconSize: 20,
          style: IconButton.styleFrom(
            foregroundColor: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  String _getStepDescription() {
    switch (_currentStep) {
      case PinChangeStep.currentAuth:
        return _canUseBiometric 
            ? 'Enter PIN or use biometric'
            : 'Enter your current PIN';
      case PinChangeStep.newPin:
        return 'Choose a new 4-6 digit PIN';
      case PinChangeStep.confirmPin:
        return 'Enter your new PIN again';
      case PinChangeStep.success:
        return '';
    }
  }

  Widget _buildCurrentStep(ThemeData theme) {
    if (_currentStep == PinChangeStep.success) {
      return _buildSuccessStep(theme);
    }

    String currentPin;
    ValueChanged<String>? onChanged;
    bool showBiometric = false;
    VoidCallback? onBiometricPressed;

    switch (_currentStep) {
      case PinChangeStep.currentAuth:
        currentPin = _currentPin;
        onChanged = (String pin) => setState(() => _currentPin = pin);
        showBiometric = _canUseBiometric;
        onBiometricPressed = _handleBiometricAuth;
      case PinChangeStep.newPin:
        currentPin = _newPin;
        onChanged = (String pin) => setState(() => _newPin = pin);
      case PinChangeStep.confirmPin:
        currentPin = _confirmPin;
        onChanged = (String pin) => setState(() => _confirmPin = pin);
      case PinChangeStep.success:
        return const SizedBox.shrink();
    }

    return Container(
      constraints: const BoxConstraints(maxHeight: 350), // Constrain PIN input height
      child: SingleChildScrollView(
        child: CompactPinInput(
          pin: currentPin,
          onChanged: onChanged,
          mode: _currentStep == PinChangeStep.confirmPin
              ? PinInputMode.confirm
              : PinInputMode.setup,
          maxLength: _currentStep == PinChangeStep.confirmPin
              ? _newPin.length
              : 6,
          showBiometric: showBiometric,
          onBiometricPressed: onBiometricPressed,
        ),
      ),
    );
  }

  Widget _buildSuccessStep(ThemeData theme) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 300),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(DesignTokens.spacingMd),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle_rounded,
              size: 48,
              color: theme.colorScheme.primary,
            ),
          ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
          
          const Gap(DesignTokens.spacingMd),
          
          Text(
            'PIN Changed Successfully!',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.primary,
            ),
            textAlign: TextAlign.center,
          ).animate().slideY(begin: 0.3, delay: 200.ms).fadeIn(delay: 200.ms),
          
          const Gap(DesignTokens.spacingSm),
          
          Text(
            'Your new PIN has been saved securely.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ).animate().slideY(begin: 0.3, delay: 400.ms).fadeIn(delay: 400.ms),
        ],
      ),
    );
  }

  Widget _buildErrorMessage(ThemeData theme) {
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
            size: 16,
          ),
          const Gap(DesignTokens.spacingXs),
          Expanded(
            child: Text(
              _errorMessage!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    ).animate().shake(hz: 4, curve: Curves.easeInOut).fadeIn();
  }

  Widget _buildActions(ThemeData theme) {
    if (_currentStep == PinChangeStep.success) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Done'),
        ),
      );
    }

    return Row(
      children: <Widget>[
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: _canProceed() && !_isLoading ? _handleNext : null,
            child: _isLoading
                ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(_getNextButtonText()),
          ),
        ),
      ],
    );
  }

  bool _canProceed() {
    switch (_currentStep) {
      case PinChangeStep.currentAuth:
        return _currentPin.length >= 4;
      case PinChangeStep.newPin:
        return _newPin.length >= 4 && _newPin.length <= 6;
      case PinChangeStep.confirmPin:
        return _confirmPin.length == _newPin.length;
      case PinChangeStep.success:
        return true;
    }
  }

  String _getNextButtonText() {
    switch (_currentStep) {
      case PinChangeStep.currentAuth:
        return 'Verify';
      case PinChangeStep.newPin:
        return 'Continue';
      case PinChangeStep.confirmPin:
        return 'Change PIN';
      case PinChangeStep.success:
        return 'Done';
    }
  }

  Future<void> _handleNext() async {
    switch (_currentStep) {
      case PinChangeStep.currentAuth:
        await _handleCurrentPinSubmit();
      case PinChangeStep.newPin:
        await _handleNewPinSubmit();
      case PinChangeStep.confirmPin:
        await _handleConfirmPinSubmit();
      case PinChangeStep.success:
        break;
    }
  }

  Future<void> _handleCurrentPinSubmit() async {
    if (_currentPin.length < 4) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final IPinStorageService pinStorage = ref.read(pinStorageProvider);
      final bool isValid = await pinStorage.verifyPin(_currentPin);

      if (isValid) {
        setState(() {
          _currentStep = PinChangeStep.newPin;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Current PIN is incorrect';
          _currentPin = '';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to verify PIN';
        _isLoading = false;
      });
    }
  }

  Future<void> _handleBiometricAuth() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final IBiometricService biometricService = ref.read(biometricServiceProvider);
      final BiometricAuthResult result = await biometricService.authenticate(
        reason: 'Verify your identity to change PIN',
      );

      if (result.isSuccess) {
        setState(() {
          _currentStep = PinChangeStep.newPin;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Biometric authentication failed';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Authentication failed';
        _isLoading = false;
      });
    }
  }

  Future<void> _handleNewPinSubmit() async {
    if (_newPin.length < 4 || _newPin.length > 6) {
      return;
    }

    setState(() {
      _currentStep = PinChangeStep.confirmPin;
      _errorMessage = null;
    });
  }

  Future<void> _handleConfirmPinSubmit() async {
    if (_confirmPin != _newPin) {
      setState(() {
        _errorMessage = 'PINs do not match';
        _confirmPin = '';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final IPinStorageService pinStorage = ref.read(pinStorageProvider);
      await pinStorage.storePin(_newPin);

      setState(() {
        _currentStep = PinChangeStep.success;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to save new PIN';
        _isLoading = false;
      });
    }
  }
}

Future<bool?> showPinChangeModal(BuildContext context) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) => const PinChangeModal(),
  );
}

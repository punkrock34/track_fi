import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/contracts/services/secure_storage/i_biometric_storage_service.dart';
import '../../../core/contracts/services/secure_storage/i_onboarding_storage_service.dart';
import '../../../core/contracts/services/secure_storage/i_pin_storage_service.dart';
import '../../../core/logging/log.dart';
import '../../../core/providers/secure_storage/biometric_storage_provider.dart';
import '../../../core/providers/secure_storage/onboarding_storage_provider.dart';
import '../../../core/providers/secure_storage/pin_storage_provider.dart';
import '../../../core/services/security/biometric_service.dart';
import '../models/onboarding_state.dart';

class OnboardingNotifier extends StateNotifier<OnboardingState> {
  OnboardingNotifier(this._ref) : super(const OnboardingState());

  final Ref _ref;

  IPinStorageService get _pinStorage => _ref.read(pinStorageProvider);
  IBiometricStorageService get _biometricStorage => _ref.read(biometricStorageProvider);
  IOnboardingStorageService get _onboardingStorage => _ref.read(onboardingStorageProvider);

  void nextStep() {
    final int index = OnboardingStep.values.indexOf(state.currentStep);
    if (index < OnboardingStep.values.length - 1) {
      state = state.copyWith(currentStep: OnboardingStep.values[index + 1]);
    }
  }

  void previousStep() {
    final int index = OnboardingStep.values.indexOf(state.currentStep);
    if (index > 0) {
      state = state.copyWith(currentStep: OnboardingStep.values[index - 1]);
    }
  }

  void goToStep(OnboardingStep step) {
    state = state.copyWith(currentStep: step);
  }

  void updatePin(String pin) {
    state = state.copyWith(pin: pin);
  }

  void updateConfirmPin(String confirmPin) {
    state = state.copyWith(confirmPin: confirmPin);
  }

  void setBiometric(bool enabled) {
    state = state.copyWith(biometricEnabled: enabled);
  }

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  void setError(String error) {
    state = state.copyWith(error: error, isLoading: false);
  }

  Future<bool> validateAndSavePin() async {
    if (!state.isPinValid) {
      setError('PIN must be 4-6 digits');
      return false;
    }

    if (!state.pinsMatch) {
      setError('PINs do not match');
      return false;
    }

    try {
      setLoading(true);
      await _pinStorage.storePin(state.pin!);
      setLoading(false);
      return true;
    } catch (e, st) {
      await log(
        message: 'Failed to save PIN',
        error: e,
        stackTrace: st,
      );
      setError('Failed to save PIN. Please try again.');
      return false;
    }
  }

  Future<bool> setupBiometric() async {
    try {
      setLoading(true);

      if (!state.biometricEnabled) {
        await _biometricStorage.setBiometricEnabled(false);
        setLoading(false);
        return true;
      }

      final bool isAvailable = await BiometricService.isAvailable();
      if (!isAvailable) {
        setError('Biometric authentication is not available on this device');
        return false;
      }

      final bool authenticated = await BiometricService.authenticate(
        reason: 'Set up biometric authentication for TrackFi',
      );

      if (authenticated) {
        await _biometricStorage.setBiometricEnabled(true);
        setLoading(false);
        return true;
      } else {
        setError('Biometric setup failed. You can set it up later in settings.');
        return false;
      }
    } catch (e, st) {
      await log(
        message: 'Failed to setup biometric auth',
        error: e,
        stackTrace: st,
      );
      setError('Failed to setup biometric authentication');
      return false;
    }
  }

  Future<bool> completeOnboarding() async {
    try {
      setLoading(true);
      await _onboardingStorage.setOnboardingComplete(true);
      setLoading(false);
      return true;
    } catch (e, st) {
      await log(
        message: 'Failed to complete onboarding',
        error: e,
        stackTrace: st,
      );
      setError('Failed to complete onboarding');
      return false;
    }
  }

  void reset() {
    state = const OnboardingState();
  }
}

final StateNotifierProvider<OnboardingNotifier, OnboardingState> onboardingProvider = StateNotifierProvider<OnboardingNotifier, OnboardingState>(
  (StateNotifierProviderRef<OnboardingNotifier, OnboardingState> ref) => OnboardingNotifier(ref),
);

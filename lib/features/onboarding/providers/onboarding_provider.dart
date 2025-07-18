import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/contracts/services/auth/biometric/i_biometric_service.dart';
import '../../../core/contracts/services/secure_storage/i_biometric_storage_service.dart';
import '../../../core/contracts/services/secure_storage/i_onboarding_storage_service.dart';
import '../../../core/contracts/services/secure_storage/i_pin_storage_service.dart';
import '../../../core/logging/log.dart';
import '../../../core/models/auth/biometric/biometric_auth_result.dart';
import '../../../core/providers/auth/biometric/biometric_service_provider.dart';
import '../../../core/providers/secure_storage/biometric_storage_provider.dart';
import '../../../core/providers/secure_storage/onboarding_storage_provider.dart';
import '../../../core/providers/secure_storage/pin_storage_provider.dart';
import '../models/onboarding_state.dart';

class OnboardingNotifier extends StateNotifier<OnboardingState> {
  OnboardingNotifier(this._ref) : super(const OnboardingState());

  final Ref _ref;

  IPinStorageService get _pinStorage => _ref.read(pinStorageProvider);
  IBiometricStorageService get _biometricStorage => _ref.watch(biometricStorageProvider);
  IBiometricService get _biometricService => _ref.watch(biometricServiceProvider);
  IOnboardingStorageService get _onboardingStorage => _ref.read(onboardingStorageProvider);

  void nextStep() {
    final int index = OnboardingStep.values.indexOf(state.currentStep);
    if (index >= OnboardingStep.values.length - 1) {
      return;
    }

    state = state.copyWith(
      currentStep: OnboardingStep.values[index + 1],
    );
  }

  void previousStep() {
    final int index = OnboardingStep.values.indexOf(state.currentStep);
    if (index <= 0) {
      return;
    }

    state = state.copyWith(
      currentStep: OnboardingStep.values[index - 1],
    );
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

  Future<bool> validateAndSavePin() async {
    if (!state.isPinValid) {
      state = state.error('PIN must be 4-6 digits');
      return false;
    }

    if (!state.pinsMatch) {
      state = state.error('PINs do not match');
      return false;
    }

    try {
      state = state.loading();
      await _pinStorage.storePin(state.pin!);
      state = state.notLoading();
      return true;
    } catch (e, st) {
      await log(
        message: 'Failed to save PIN',
        error: e,
        stackTrace: st,
      );
      state = state.error('Failed to save PIN. Please try again.');
      return false;
    }
  }

  Future<bool> setupBiometric() async {
    try {
      state = state.loading();

      if (!state.biometricEnabled) {
        await _biometricStorage.setBiometricEnabled(false);
        state = state.notLoading();
        return true;
      }

      final bool isAvailable = await _biometricService.isAvailable();
      if (!isAvailable) {
        await _biometricStorage.setBiometricEnabled(false);
        state = state.notLoading();
        return true;
      }

      final BiometricAuthResult result = await _biometricService.authenticate(
        reason: 'Set up biometric authentication for TrackFi',
      );

      if (result.isSuccess) {
        await _biometricStorage.setBiometricEnabled(true);
        state = state.notLoading();
        return true;
      }

      await _biometricStorage.setBiometricEnabled(false);
      state = state.notLoading();
      return true;

    } catch (e, st) {
      await log(
        message: 'Failed to setup biometric auth',
        error: e,
        stackTrace: st,
      );
      
      try {
        await _biometricStorage.setBiometricEnabled(false);
      } catch (_) {
        // Ignore errors setting biometric preference
      }
      
      state = state.notLoading();
      return true;
    }
  }

  Future<bool> completeOnboarding() async {
    final bool hasPin = await _pinStorage.hasPinSet();
    if (!hasPin) {
      state = state.error('Cannot complete onboarding without setting a PIN.');
      return false;
    }

    try {
      state = state.loading();
      await _onboardingStorage.setOnboardingComplete(true);
      state = state.notLoading();
      return true;
    } catch (e, st) {
      await log(
        message: 'Failed to complete onboarding',
        error: e,
        stackTrace: st,
      );
      state = state.error('Failed to complete onboarding');
      return false;
    }
  }

  void reset() {
    state = const OnboardingState();
  }
}

final StateNotifierProvider<OnboardingNotifier, OnboardingState> onboardingProvider =
    StateNotifierProvider<OnboardingNotifier, OnboardingState>(
  (StateNotifierProviderRef<OnboardingNotifier, OnboardingState> ref) => OnboardingNotifier(ref),
);

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/contracts/services/secure_storage/i_biometric_storage_service.dart';
import '../../../core/contracts/services/secure_storage/i_pin_storage_service.dart';
import '../../../core/logging/log.dart';
import '../../../core/providers/secure_storage/biometric_storage_provider.dart';
import '../../../core/providers/secure_storage/pin_storage_provider.dart';
import '../../../core/services/security/biometric_service.dart';
import '../models/auth_state.dart';

class AuthenticationNotifier extends StateNotifier<AuthenticationState> {
  AuthenticationNotifier(this._ref) : super(const AuthenticationState()) {
    init();
  }

  final Ref _ref;
  Timer? _lockoutTimer;

  IPinStorageService get _pinStorage => _ref.watch(pinStorageProvider);
  IBiometricStorageService get _biometricStorage => _ref.watch(biometricStorageProvider);

  Future<void> init() async {
    await perform(() async {
      final bool hasPin = await _pinStorage.hasPinSet();
      if (!hasPin) {
        return;
      }

      final int? expectedPinLength = await _pinStorage.getPinLength();
      
      final bool biometricEnabled = await _biometricStorage.isBiometricEnabled();
      final bool biometricAvailable = await BiometricService.isAvailable();

      if (biometricEnabled && biometricAvailable) {
        state = state.biometricStep();
        await _authenticateWithBiometric();
        return;
      }

      state = state.pinStep().copyWith(
        expectedPinLength: expectedPinLength,
      );
    }, failMessage: 'Failed to initialize authentication.');
  }

  Future<void> _authenticateWithBiometric() async {
    await perform(() async {
      final BiometricAuthResult authenticated = await BiometricService.authenticate(
        reason: 'Authenticate to access TrackFi',
      );

      if (authenticated.isSuccess) {
        state = state.success();
        return;
      }

      state = state.pinStep();
    }, failMessage: 'Biometric authentication unavailable. Please enter your PIN.');
  }

  void updatePin(String pin) {
    if (state.isLocked) {
      return;
    }

    state = state.copyWith(pin: pin);
  }

  Future<void> authenticateWithPin() async {
    if (!state.canAttemptAuth || !state.isPinComplete) {
      return;
    }

    await perform(() async {
      final bool isValid = await _pinStorage.verifyPin(state.pin);
      if (isValid) {
        state = state.success();
        return;
      }

      _handleFailedPin();
    }, failMessage: 'PIN authentication failed.');
  }

  void _handleFailedPin() {
    final int newAttempt = state.attemptCount + 1;

    if (newAttempt >= state.maxAttempts) {
      final DateTime lockoutEnd = DateTime.now().add(const Duration(minutes: 5));
      state = state.locked(lockoutEnd);
      _scheduleUnlock(lockoutEnd);
      return;
    }

    state = state.copyWith(
      attemptCount: newAttempt,
      pin: '',
      isLoading: false,
    );
  }

  void _scheduleUnlock(DateTime unlockTime) {
    _lockoutTimer?.cancel();

    final Duration duration = unlockTime.difference(DateTime.now());
    _lockoutTimer = Timer(duration, () {
      if (mounted) {
        state = state.copyWith(
          isLocked: false,
          attemptCount: 0,
        );
      }
    });
  }

  void retryBiometric() {
    if (state.currentStep != AuthenticationStep.pin) {
      return;
    }

    _authenticateWithBiometric();
  }

  void fallbackToPin() {
    state = state.pinStep();
  }

  void reset() {
    state = const AuthenticationState();
    init();
  }

  @override
  void dispose() {
    _lockoutTimer?.cancel();
    super.dispose();
  }

  Future<void> perform(Future<void> Function() action, {String? failMessage}) async {
    try {
      state = state.loading();
      await action();
    } catch (e, st) {
      await log(
        message: failMessage ?? 'Unexpected error',
        error: e,
        stackTrace: st,
      );
    }
  }
}

final StateNotifierProvider<AuthenticationNotifier, AuthenticationState> authenticationProvider =
    StateNotifierProvider<AuthenticationNotifier, AuthenticationState>(
  (StateNotifierProviderRef<AuthenticationNotifier, AuthenticationState> ref) => AuthenticationNotifier(ref),
);

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';

import '../../../core/contracts/services/secure_storage/i_auth_attempt_storage_service.dart';
import '../../../core/contracts/services/secure_storage/i_biometric_storage_service.dart';
import '../../../core/contracts/services/secure_storage/i_pin_storage_service.dart';
import '../../../core/logging/log.dart';
import '../../../core/providers/secure_storage/auth_attempt_storage_provider.dart';
import '../../../core/providers/secure_storage/biometric_storage_provider.dart';
import '../../../core/providers/secure_storage/pin_storage_provider.dart';
import '../../../core/services/security/biometric_service.dart';
import '../models/auth_state.dart';
import '../models/biometric_setup.dart';

class AuthenticationNotifier extends StateNotifier<AuthenticationState> {
  AuthenticationNotifier(this._ref) : super(const AuthenticationState()) {
    init();
  }

  final Ref _ref;
  Timer? _lockoutTimer;
  Timer? _countdownTimer;

  IPinStorageService get _pinStorage => _ref.watch(pinStorageProvider);
  IBiometricStorageService get _biometricStorage => _ref.watch(biometricStorageProvider);
  IAuthAttemptStorageService get _authAttemptStorage => _ref.watch(authAttemptStorageProvider);

  Future<void> init() async {
    await perform(() async {
      final bool hasPin = await _pinStorage.hasPinSet();
      if (!hasPin) {
        return;
      }

      if (await _handleExistingLockout()) {
        return;
      }

      await _setupAuthenticationFlow();
    }, failMessage: 'Failed to initialize authentication.');
  }

  Future<bool> _handleExistingLockout() async {
    final bool isLockedOut = await _authAttemptStorage.isCurrentlyLockedOut();
    if (!isLockedOut) {
      return false;
    }

    final DateTime? lockoutEnd = await _authAttemptStorage.getLockoutEndTime();
    final int failedAttempts = await _authAttemptStorage.getFailedAttempts();
    
    if (lockoutEnd != null) {
      state = state.locked(lockoutEnd).copyWith(attemptCount: failedAttempts);
      _scheduleUnlock(lockoutEnd);
      _setupCountdownTimer(lockoutEnd);
      return true;
    }
    
    return false;
  }

  Future<void> _setupAuthenticationFlow() async {
    final int? expectedPinLength = await _pinStorage.getPinLength();
    final int failedAttempts = await _authAttemptStorage.getFailedAttempts();
    
    final BiometricSetup biometricSetup = await _getBiometricSetup();
    
    if (biometricSetup.shouldUseBiometric) {
      await _setupBiometricAuth(expectedPinLength, failedAttempts, biometricSetup);
    } else {
      _setupPinAuth(expectedPinLength, failedAttempts, biometricSetup);
    }
  }

  Future<BiometricSetup> _getBiometricSetup() async {
    final bool biometricEnabled = await _biometricStorage.isBiometricEnabled();
    final bool specificBiometricAvailable = await BiometricService.isSpecificBiometricAvailable();
    final List<BiometricType> availableBiometrics = await BiometricService.getAvailableBiometrics();
    
    return BiometricSetup(
      enabled: biometricEnabled,
      available: specificBiometricAvailable,
      types: availableBiometrics,
      shouldUseBiometric: biometricEnabled && specificBiometricAvailable,
    );
  }

  Future<void> _setupBiometricAuth(
    int? expectedPinLength,
    int failedAttempts,
    BiometricSetup biometricSetup,
  ) async {
    state = state.biometricStep().copyWith(
      expectedPinLength: expectedPinLength,
      biometricAvailable: true,
      availableBiometrics: biometricSetup.types,
      attemptCount: failedAttempts,
    );
    await _authenticateWithBiometric();
  }

  void _setupPinAuth(
    int? expectedPinLength,
    int failedAttempts,
    BiometricSetup biometricSetup,
  ) {
    state = state.pinStep().copyWith(
      expectedPinLength: expectedPinLength,
      biometricAvailable: biometricSetup.isBiometricAvailable,
      availableBiometrics: biometricSetup.types,
      attemptCount: failedAttempts,
    );
  }

  Future<void> _authenticateWithBiometric() async {
    state = state.copyWith(isBiometricInProgress: true);
    
    await perform(() async {
      final BiometricAuthResult authenticated = await BiometricService.authenticateWithSpecificType(
        reason: 'Authenticate to access TrackFi',
      );

      if (authenticated.isSuccess) {
        await _authAttemptStorage.clearAllAttemptData();
        state = state.success();
        return;
      }

      state = state.pinStep().copyWith(
        expectedPinLength: state.expectedPinLength,
        biometricAvailable: state.biometricAvailable,
        availableBiometrics: state.availableBiometrics,
        isBiometricInProgress: false,
      );
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
        await _authAttemptStorage.clearAllAttemptData();
        state = state.success();
        return;
      }

      await _handleFailedPin();
    }, failMessage: 'PIN authentication failed.');
  }

  Future<void> _handleFailedPin() async {
    await _authAttemptStorage.incrementFailedAttempts();
    final int newAttempt = await _authAttemptStorage.getFailedAttempts();

    if (newAttempt >= state.maxAttempts) {
      final DateTime lockoutEnd = DateTime.now().add(const Duration(minutes: 5));
      
      await _authAttemptStorage.setLockoutEndTime(lockoutEnd);
      
      state = state.locked(lockoutEnd).copyWith(attemptCount: newAttempt);
      _scheduleUnlock(lockoutEnd);
      _setupCountdownTimer(lockoutEnd);
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
    _lockoutTimer = Timer(duration, () async {
      if (mounted) {
        await _authAttemptStorage.clearAllAttemptData();
        state = state.copyWith(isLocked: false, attemptCount: 0);
        await init();
      }
    });
  }

  void _setupCountdownTimer(DateTime unlockTime) {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      final Duration remaining = unlockTime.difference(DateTime.now());
      
      if (remaining.isNegative || remaining.inSeconds <= 0) {
        timer.cancel();
        return;
      }

      state = state.copyWith(lockoutEndTime: unlockTime);
    });
  }

  void retryBiometric() {
    if (state.isLocked || state.isBiometricInProgress) {
      return;
    }

    if (state.currentStep != AuthenticationStep.pin &&
        state.currentStep != AuthenticationStep.biometric) {
      return;
    }

    _authenticateWithBiometric();
  }

  void fallbackToPin() {
    state = state.pinStep().copyWith(
      expectedPinLength: state.expectedPinLength,
      biometricAvailable: state.biometricAvailable,
      availableBiometrics: state.availableBiometrics,
      isBiometricInProgress: false,
    );
  }

  void reset() {
    state = const AuthenticationState();
    init();
  }

  @override
  void dispose() {
    _lockoutTimer?.cancel();
    _countdownTimer?.cancel();
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

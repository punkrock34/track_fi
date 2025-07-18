import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';

import '../../../core/contracts/services/auth/biometric/i_biometric_service.dart';
import '../../../core/contracts/services/auth/i_auth_service.dart';
import '../../../core/contracts/services/secure_storage/i_auth_attempt_storage_service.dart';
import '../../../core/contracts/services/secure_storage/i_biometric_storage_service.dart';
import '../../../core/contracts/services/secure_storage/i_pin_storage_service.dart';
import '../../../core/logging/log.dart';
import '../../../core/models/auth/biometric/biometric_auth_result.dart';
import '../../../features/auth/models/auth_state.dart';
import '../../../features/auth/models/biometric_setup.dart';

class AuthService extends StateNotifier<AuthenticationState> implements IAuthService {
  AuthService({
    required this.pinStorage,
    required this.biometricStorage,
    required this.authAttemptStorage,
    required this.biometricService,
  }) : super(const AuthenticationState());

  final IPinStorageService pinStorage;
  final IBiometricStorageService biometricStorage;
  final IAuthAttemptStorageService authAttemptStorage;
  final IBiometricService biometricService;

  Timer? _lockoutTimer;
  Timer? _countdownTimer;

  @override
  set state(AuthenticationState state) {
    super.state = state;
  }

  @override
  AuthenticationState get state => super.state;

  @override
  Future<void> init() async {
    await perform(() async {
      final bool hasPin = await pinStorage.hasPinSet();
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
    final bool isLockedOut = await authAttemptStorage.isCurrentlyLockedOut();
    if (!isLockedOut) {
      return false;
    }

    final DateTime? lockoutEnd = await authAttemptStorage.getLockoutEndTime();
    final int failedAttempts = await authAttemptStorage.getFailedAttempts();

    if (lockoutEnd != null) {
      state = state.locked(lockoutEnd).copyWith(attemptCount: failedAttempts);
      _scheduleUnlock(lockoutEnd);
      _setupCountdownTimer(lockoutEnd);
      return true;
    }

    return false;
  }

  Future<void> _setupAuthenticationFlow() async {
    final int? expectedPinLength = await pinStorage.getPinLength();
    final int failedAttempts = await authAttemptStorage.getFailedAttempts();
    final BiometricSetup biometricSetup = await _getBiometricSetup();

    if (biometricSetup.shouldUseBiometric) {
      await _setupBiometricAuth(expectedPinLength, failedAttempts, biometricSetup);
    } else {
      _setupPinAuth(expectedPinLength, failedAttempts, biometricSetup);
    }
  }

  Future<BiometricSetup> _getBiometricSetup() async {
    final bool enabled = await biometricStorage.isBiometricEnabled();
    final bool available = await biometricService.isSpecificBiometricAvailable();
    final List<BiometricType> types = await biometricService.getAvailableBiometrics();

    return BiometricSetup(
      enabled: enabled,
      available: available,
      types: types,
      shouldUseBiometric: enabled && available,
    );
  }

  Future<void> _setupBiometricAuth(
    int? expectedPinLength,
    int failedAttempts,
    BiometricSetup setup,
  ) async {
    state = state.biometricStep().copyWith(
      expectedPinLength: expectedPinLength,
      biometricAvailable: true,
      availableBiometrics: setup.types,
      attemptCount: failedAttempts,
    );

    await _authenticateWithBiometric();
  }

  void _setupPinAuth(
    int? expectedPinLength,
    int failedAttempts,
    BiometricSetup setup,
  ) {
    state = state.pinStep().copyWith(
      expectedPinLength: expectedPinLength,
      biometricAvailable: setup.isBiometricAvailable,
      availableBiometrics: setup.types,
      attemptCount: failedAttempts,
    );
  }

  Future<void> _authenticateWithBiometric() async {
    state = state.copyWith(isBiometricInProgress: true);

    await perform(() async {
      final BiometricAuthResult result = await biometricService.authenticateWithSpecificType(
        reason: 'Authenticate to access TrackFi',
      );

      if (result.isSuccess) {
        await authAttemptStorage.clearAllAttemptData();
        state = state.success();
        return;
      }

      state = state.pinStep().copyWith(
        expectedPinLength: state.expectedPinLength,
        biometricAvailable: state.biometricAvailable,
        availableBiometrics: state.availableBiometrics,
        isBiometricInProgress: false,
      );
    }, failMessage: 'Biometric authentication failed.');
  }

  @override
  void updatePin(String pin) {
    if (state.isLocked) {
      return;
    }
    state = state.copyWith(pin: pin);
  }

  @override
  Future<void> authenticateWithPin() async {
    if (!state.canAttemptAuth || !state.isPinComplete) {
      return;
    }

    await perform(() async {
      final bool isValid = await pinStorage.verifyPin(state.pin);
      if (isValid) {
        await authAttemptStorage.clearAllAttemptData();
        state = state.success();
        return;
      }

      await _handleFailedPin();
    }, failMessage: 'PIN authentication failed.');
  }

  Future<void> _handleFailedPin() async {
    await authAttemptStorage.incrementFailedAttempts();
    final int newAttempt = await authAttemptStorage.getFailedAttempts();

    if (newAttempt >= state.maxAttempts) {
      final DateTime lockoutEnd = DateTime.now().add(const Duration(minutes: 5));
      await authAttemptStorage.setLockoutEndTime(lockoutEnd);
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
    _lockoutTimer = Timer(unlockTime.difference(DateTime.now()), () async {
      await authAttemptStorage.clearAllAttemptData();
      state = state.copyWith(isLocked: false, attemptCount: 0);
      await init();
    });
  }

  void _setupCountdownTimer(DateTime unlockTime) {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      final Duration remaining = unlockTime.difference(DateTime.now());
      if (remaining.isNegative || remaining.inSeconds <= 0) {
        timer.cancel();
        return;
      }

      state = state.copyWith(lockoutEndTime: unlockTime);
    });
  }

  @override
  void retryBiometric() {
    if (state.isLocked || state.isBiometricInProgress) {
      return;
    }

    if (state.currentStep == AuthenticationStep.pin ||
        state.currentStep == AuthenticationStep.biometric) {
      _authenticateWithBiometric();
    }
  }

  @override
  void fallbackToPin() {
    state = state.pinStep().copyWith(
      expectedPinLength: state.expectedPinLength,
      biometricAvailable: state.biometricAvailable,
      availableBiometrics: state.availableBiometrics,
      isBiometricInProgress: false,
    );
  }

  @override
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

import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

enum AuthenticationStep {
  initial,
  biometric,
  pin,
  success,
}

class AuthenticationState {
  const AuthenticationState({
    this.currentStep = AuthenticationStep.initial,
    this.pin = '',
    this.isLoading = false,
    this.expectedPinLength,
    this.attemptCount = 0,
    this.maxAttempts = 5,
    this.isLocked = false,
    this.lockoutEndTime,
    this.biometricAvailable = false,
    this.isBiometricInProgress = false,
    this.availableBiometrics = const <BiometricType>[],
  });

  final AuthenticationStep currentStep;
  final String pin;
  final bool isLoading;
  final int? expectedPinLength;
  final int attemptCount;
  final int maxAttempts;
  final bool isLocked;
  final DateTime? lockoutEndTime;
  final bool biometricAvailable;
  final bool isBiometricInProgress;
  final List<BiometricType> availableBiometrics;

  AuthenticationState copyWith({
    AuthenticationStep? currentStep,
    String? pin,
    bool? isLoading,
    int? expectedPinLength,
    int? attemptCount,
    int? maxAttempts,
    bool? isLocked,
    DateTime? lockoutEndTime,
    bool? biometricAvailable,
    bool? isBiometricInProgress,
    List<BiometricType>? availableBiometrics,
  }) {
    return AuthenticationState(
      currentStep: currentStep ?? this.currentStep,
      pin: pin ?? this.pin,
      isLoading: isLoading ?? this.isLoading,
      expectedPinLength: expectedPinLength ?? this.expectedPinLength,
      attemptCount: attemptCount ?? this.attemptCount,
      maxAttempts: maxAttempts ?? this.maxAttempts,
      isLocked: isLocked ?? this.isLocked,
      lockoutEndTime: lockoutEndTime ?? this.lockoutEndTime,
      biometricAvailable: biometricAvailable ?? this.biometricAvailable,
      isBiometricInProgress: isBiometricInProgress ?? this.isBiometricInProgress,
      availableBiometrics: availableBiometrics ?? this.availableBiometrics,
    );
  }

  bool get canAttemptAuth => !isLocked && attemptCount < maxAttempts;
  bool get isPinComplete => pin.length >= 4 && pin.length <= 6;
  bool get showBiometricButton => biometricAvailable && !isBiometricInProgress;
  
  int get remainingAttempts => maxAttempts - attemptCount;
  
  Duration? get remainingLockoutTime {
    if (!isLocked || lockoutEndTime == null) {
      return null;
    }
    
    final Duration remaining = lockoutEndTime!.difference(DateTime.now());
    return remaining.isNegative ? null : remaining;
  }

  IconData get biometricIcon {
    if (availableBiometrics.contains(BiometricType.face)) {
      return Icons.face;
    } else if (availableBiometrics.contains(BiometricType.fingerprint)) {
      return Icons.fingerprint;
    } else if (availableBiometrics.contains(BiometricType.iris)) {
      return Icons.visibility;
    }
    return Icons.fingerprint;
  }

  String get biometricTypeName {
    if (availableBiometrics.contains(BiometricType.face)) {
      return 'Face ID';
    } else if (availableBiometrics.contains(BiometricType.fingerprint)) {
      return 'Fingerprint';
    } else if (availableBiometrics.contains(BiometricType.iris)) {
      return 'Iris';
    }
    return 'Biometric';
  }
}

extension AuthStateTransitions on AuthenticationState {
  AuthenticationState success() => copyWith(
        currentStep: AuthenticationStep.success,
        isLoading: false,
        pin: '',
        attemptCount: 0,
        isBiometricInProgress: false,
      );

  AuthenticationState locked(DateTime until) => copyWith(
        isLoading: false,
        isLocked: true,
        lockoutEndTime: until,
        pin: '',
        isBiometricInProgress: false,
      );

  AuthenticationState loading() => copyWith(
        isLoading: true,
        isBiometricInProgress: false,
      );

  AuthenticationState pinStep() => copyWith(
        currentStep: AuthenticationStep.pin,
        isLoading: false,
        isBiometricInProgress: false,
        expectedPinLength: expectedPinLength
      );

  AuthenticationState biometricStep() => copyWith(
        currentStep: AuthenticationStep.biometric,
        isLoading: false,
      );
}

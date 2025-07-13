import '../../../shared/state/status/has_status.dart';

enum AuthenticationStep {
  initial,
  biometric,
  pin,
  success,
}

class AuthenticationState implements HasStatus {
  const AuthenticationState({
    this.currentStep = AuthenticationStep.initial,
    this.pin = '',
    this.isLoading = false,
    this.errorMessage,
    this.attemptCount = 0,
    this.maxAttempts = 5,
    this.isLocked = false,
    this.lockoutEndTime,
  });

  final AuthenticationStep currentStep;
  final String pin;
  @override
  final bool isLoading;
  @override
  final String? errorMessage;
  final int attemptCount;
  final int maxAttempts;
  final bool isLocked;
  final DateTime? lockoutEndTime;

  @override
  AuthenticationState copyWith({
    AuthenticationStep? currentStep,
    String? pin,
    bool? isLoading,
    String? errorMessage,
    int? attemptCount,
    int? maxAttempts,
    bool? isLocked,
    DateTime? lockoutEndTime,
  }) {
    return AuthenticationState(
      currentStep: currentStep ?? this.currentStep,
      pin: pin ?? this.pin,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      attemptCount: attemptCount ?? this.attemptCount,
      maxAttempts: maxAttempts ?? this.maxAttempts,
      isLocked: isLocked ?? this.isLocked,
      lockoutEndTime: lockoutEndTime ?? this.lockoutEndTime,
    );
  }

  bool get canAttemptAuth => !isLocked && attemptCount < maxAttempts;
  bool get isPinComplete => pin.length >= 4 && pin.length <= 6;
  
  int get remainingAttempts => maxAttempts - attemptCount;
  
  Duration? get remainingLockoutTime {
    if (!isLocked || lockoutEndTime == null) {
      return null;
    }
    
    final Duration remaining = lockoutEndTime!.difference(DateTime.now());
    return remaining.isNegative ? null : remaining;
  }
}

extension AuthStateTransitions on AuthenticationState {
  AuthenticationState success() => copyWith(
        currentStep: AuthenticationStep.success,
        isLoading: false,
        pin: '',
        attemptCount: 0,
      );

  AuthenticationState locked(DateTime until) => copyWith(
        isLoading: false,
        isLocked: true,
        lockoutEndTime: until,
        pin: '',
        errorMessage: 'Too many failed attempts. Account locked until ${until.hour}:${until.minute}.',
      );

  AuthenticationState pinStep() => copyWith(
        currentStep: AuthenticationStep.pin,
        isLoading: false,
      );

  AuthenticationState biometricStep() => copyWith(
        currentStep: AuthenticationStep.biometric,
        isLoading: false,
      );
}

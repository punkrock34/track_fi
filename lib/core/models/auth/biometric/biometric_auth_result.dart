import 'biometric_result.dart';

class BiometricAuthResult {
  const BiometricAuthResult({
    required this.result,
    this.error,
    this.shouldFallbackToPin = false,
  });

  final BiometricResult result;
  final String? error;
  final bool shouldFallbackToPin;

  bool get isSuccess => result == BiometricResult.success;
  bool get isUserCancel => result == BiometricResult.userCancel;
  bool get shouldShowError => !isSuccess && !isUserCancel && !shouldFallbackToPin;
}

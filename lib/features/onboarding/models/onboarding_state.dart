import '../../../shared/state/status/has_status.dart';

enum OnboardingStep {
  welcome,
  pinSetup,
  pinConfirm,
  biometricSetup,
  themeCustomization,
  complete,
}

class OnboardingState implements HasStatus {
  const OnboardingState({
    this.currentStep = OnboardingStep.welcome,
    this.pin,
    this.confirmPin,
    this.biometricEnabled = false,
    this.isLoading = false,
    this.errorMessage,
  });

  final OnboardingStep currentStep;
  final String? pin;
  final String? confirmPin;
  final bool biometricEnabled;
  @override
  final bool isLoading;
  @override
  final String? errorMessage;

  @override
  OnboardingState copyWith({
    OnboardingStep? currentStep,
    String? pin,
    String? confirmPin,
    bool? biometricEnabled,
    bool? isLoading,
    String? errorMessage,
  }) {
    return OnboardingState(
      currentStep: currentStep ?? this.currentStep,
      pin: pin ?? this.pin,
      confirmPin: confirmPin ?? this.confirmPin,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  bool get isPinValid =>
      (pin?.length ?? 0) >= 4 && (pin?.length ?? 0) <= 6;

  bool get pinsMatch => pin == confirmPin;

  int get progress {
    switch (currentStep) {
      case OnboardingStep.welcome:
        return 0;
      case OnboardingStep.pinSetup:
        return 1;
      case OnboardingStep.pinConfirm:
        return 2;
      case OnboardingStep.biometricSetup:
        return 3;
      case OnboardingStep.themeCustomization:
        return 4;
      case OnboardingStep.complete:
        return 5;
    }
  }

  int get totalSteps => OnboardingStep.values.length - 2; // Exclude welcome and complete steps since they don't count towards progress
}

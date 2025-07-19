enum OnboardingStep {
  welcome,
  pinSetup,
  pinConfirm,
  biometricSetup,
  themeCustomization,
  complete,
}

class OnboardingState {
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
  final bool isLoading;
  final String? errorMessage;

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

  bool get isPinValid => pin != null && pin!.length >= 4 && pin!.length <= 6;
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

  int get totalSteps {
    return OnboardingStep.values.length - 2; // Exclude welcome and complete steps
  }
}

extension OnboardingStateTransitions on OnboardingState {
  OnboardingState error(String message) {
    return copyWith(
      errorMessage: message,
      isLoading: false,
    );
  }

  OnboardingState loading() {
    return copyWith(
      isLoading: true,
    );
  }

  OnboardingState notLoading() {
    return copyWith(
      isLoading: false,
    );
  }

  OnboardingState success() {
    return copyWith(
      currentStep: OnboardingStep.complete,
      isLoading: false,
    );
  }
}
  

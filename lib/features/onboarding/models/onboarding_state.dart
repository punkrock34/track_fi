enum OnboardingStep {
  welcome,
  pinSetup,
  pinConfirm,
  biometricSetup,
  themeCustomization,
  complete,
}

enum DataSourceOption {
  bankApi,
  pdfUpload,
  skipForNow,
}

class OnboardingState {

  const OnboardingState({
    this.currentStep = OnboardingStep.welcome,
    this.pin,
    this.confirmPin,
    this.biometricEnabled = false,
    this.dataSourceChoice,
    this.isDarkMode = false,
    this.primaryColorHex,
    this.isLoading = false,
    this.error,
  });
  final OnboardingStep currentStep;
  final String? pin;
  final String? confirmPin;
  final bool biometricEnabled;
  final DataSourceOption? dataSourceChoice;
  final bool isDarkMode;
  final String? primaryColorHex;
  final bool isLoading;
  final String? error;

  OnboardingState copyWith({
    OnboardingStep? currentStep,
    String? pin,
    String? confirmPin,
    bool? biometricEnabled,
    DataSourceOption? dataSourceChoice,
    bool? isDarkMode,
    String? primaryColorHex,
    bool? isLoading,
    String? error,
  }) {
    return OnboardingState(
      currentStep: currentStep ?? this.currentStep,
      pin: pin ?? this.pin,
      confirmPin: confirmPin ?? this.confirmPin,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      dataSourceChoice: dataSourceChoice ?? this.dataSourceChoice,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      primaryColorHex: primaryColorHex ?? this.primaryColorHex,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
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
    return OnboardingStep.values.length;
  }

}

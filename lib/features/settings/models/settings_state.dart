class SettingsState {
  const SettingsState({
    this.biometricEnabled = false,
    this.isLoading = false,
  });

  final bool biometricEnabled;
  final bool isLoading;

  SettingsState copyWith({
    bool? biometricEnabled,
    bool? isLoading,
  }) {
    return SettingsState(
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

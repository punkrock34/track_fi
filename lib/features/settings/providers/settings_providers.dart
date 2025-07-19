import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/contracts/services/auth/biometric/i_biometric_service.dart';
import '../../../core/contracts/services/secure_storage/i_biometric_storage_service.dart';
import '../../../core/logging/log.dart';
import '../../../core/models/auth/biometric/biometric_auth_result.dart';
import '../../../core/providers/auth/biometric/biometric_service_provider.dart';
import '../../../core/providers/secure_storage/biometric_storage_provider.dart';
import '../models/settings_state.dart';

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier(this._ref) : super(const SettingsState()) {
    _loadSettings();
  }

  final Ref _ref;

  IBiometricStorageService get _biometricStorage => _ref.read(biometricStorageProvider);
  IBiometricService get _biometricService => _ref.read(biometricServiceProvider);

  Future<void> _loadSettings() async {
    try {
      final bool biometricEnabled = await _biometricStorage.isBiometricEnabled();
      state = state.copyWith(biometricEnabled: biometricEnabled);
    } catch (e, stackTrace) {
      await log(
        message: 'Failed to load settings',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<bool> setBiometricEnabled(bool enabled) async {
    if (state.isLoading) {
      return false;
    }

    state = state.copyWith(isLoading: true);

    try {
      if (enabled) {
        final bool isAvailable = await _biometricService.isAvailable();
        if (!isAvailable) {
          state = state.copyWith(isLoading: false);
          return false;
        }

        final BiometricAuthResult result = await _biometricService.authenticate(
          reason: 'Enable biometric authentication for TrackFi',
        );

        if (!result.isSuccess) {
          state = state.copyWith(isLoading: false);
          return false;
        }
      }

      // Save preference
      await _biometricStorage.setBiometricEnabled(enabled);
      state = state.copyWith(
        biometricEnabled: enabled,
        isLoading: false,
      );
      
      return true;
    } catch (e, stackTrace) {
      await log(
        message: 'Failed to set biometric enabled',
        error: e,
        stackTrace: stackTrace,
      );
      
      state = state.copyWith(isLoading: false);
      return false;
    }
  }

  void clearCache() {

  }

  void refresh() {
    _loadSettings();
  }
}

final StateNotifierProvider<SettingsNotifier, SettingsState> settingsProvider =
    StateNotifierProvider<SettingsNotifier, SettingsState>(
  (StateNotifierProviderRef<SettingsNotifier, SettingsState> ref) => SettingsNotifier(ref),
);

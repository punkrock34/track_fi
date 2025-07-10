import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_darwin/local_auth_darwin.dart';

import '../../logging/log.dart';

class BiometricService {
  static final LocalAuthentication _localAuth = LocalAuthentication();

  static Future<bool> isAvailable() async {
    try {
      final bool available = await _localAuth.canCheckBiometrics;
      final bool supported = await _localAuth.isDeviceSupported();
      return available && supported;
    } on PlatformException catch (e, stackTrace) {
      await log(
        message: 'Biometric check failed',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  static Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      final List<BiometricType> biometrics = await _localAuth.getAvailableBiometrics();
      return biometrics;
    } on PlatformException catch (e, stackTrace) {
      await log(
        message: 'Biometric list failed',
        error: e,
        stackTrace: stackTrace,
      );
      return <BiometricType>[];
    }
  }

  static Future<bool> authenticate({
    String reason = 'Please authenticate to continue',
    bool biometricOnly = false,
  }) async {
    try {
      return await _localAuth.authenticate(
        localizedReason: reason,
        authMessages: const <AuthMessages>[
          IOSAuthMessages(
            cancelButton: 'Cancel',
            goToSettingsButton: 'Settings',
            goToSettingsDescription: 'Set up your biometric authentication in Settings.',
            lockOut: 'Biometric is locked. Try later.',
          ),
          AndroidAuthMessages(
            cancelButton: 'Cancel',
            goToSettingsButton: 'Settings',
            goToSettingsDescription: 'Set up your biometric authentication in Settings.',
            biometricHint: 'Touch sensor',
            biometricNotRecognized: 'Not recognized. Try again.',
            biometricRequiredTitle: 'Biometric required',
            biometricSuccess: 'Authenticated!',
            deviceCredentialsRequiredTitle: 'Device credential required',
            deviceCredentialsSetupDescription: 'Device credential setup needed.',
            signInTitle: 'Authentication required',
          ),
        ],
        options: AuthenticationOptions(
          biometricOnly: biometricOnly,
          stickyAuth: true,
        ),
      );
    } on PlatformException catch (e, stackTrace) {
      await log(
        message: 'Biometric check failed',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  static String getBiometricTypeString(List<BiometricType> types) {
    if (types.contains(BiometricType.face)) {
      return 'Face ID';
    } else if (types.contains(BiometricType.fingerprint)) {
      return 'Fingerprint';
    } else if (types.contains(BiometricType.iris)) {
      return 'Iris';
    }
    return 'Biometric';
  }
}

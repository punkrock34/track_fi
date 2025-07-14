import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_darwin/local_auth_darwin.dart';

import '../../logging/log.dart';

enum BiometricResult {
  success,
  failed,
  userCancel,
  notAvailable,
  notEnrolled,
  lockedOut,
  temporaryLockout,
  permanentLockout,
  unknown,
}

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

class BiometricService {
  static final LocalAuthentication _localAuth = LocalAuthentication();

  static Future<bool> isAvailable() async {
    try {
      final bool canCheckBiometrics = await _localAuth.canCheckBiometrics;
      final bool isDeviceSupported = await _localAuth.isDeviceSupported();
      
      if (!canCheckBiometrics || !isDeviceSupported) {
        return false;
      }
      
      final List<BiometricType> availableBiometrics = await _localAuth.getAvailableBiometrics();
      return availableBiometrics.isNotEmpty;
      
    } on PlatformException catch (e, stackTrace) {
      await log(
        message: 'Biometric availability check failed: ${e.code} - ${e.message}',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    } catch (e, stackTrace) {
      await log(
        message: 'Unexpected error checking biometric availability',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  static Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } on PlatformException catch (e, stackTrace) {
      await log(
        message: 'Failed to get available biometrics: ${e.code} - ${e.message}',
        error: e,
        stackTrace: stackTrace,
      );
      return <BiometricType>[];
    } catch (e, stackTrace) {
      await log(
        message: 'Unexpected error getting available biometrics',
        error: e,
        stackTrace: stackTrace,
      );
      return <BiometricType>[];
    }
  }

  static Future<BiometricAuthResult> authenticate({
    String reason = 'Please authenticate to continue',
    bool biometricOnly = false,
    bool allowFallbackToPin = true,
  }) async {
    try {
      final bool available = await isAvailable();
      if (!available) {
        await log(message: 'Biometrics not available for authentication');
        return const BiometricAuthResult(
          result: BiometricResult.notAvailable,
          shouldFallbackToPin: true,
        );
      }

      final bool authenticated = await _localAuth.authenticate(
        localizedReason: reason,
        authMessages: <AuthMessages>[
          const IOSAuthMessages(
            cancelButton: 'Use PIN',
            goToSettingsButton: 'Settings',
            goToSettingsDescription: 'Set up your biometric authentication in Settings.',
            lockOut: 'Biometric authentication is temporarily locked. Please use your PIN.',
          ),
          const AndroidAuthMessages(
            cancelButton: 'Use PIN',
            goToSettingsButton: 'Settings',
            goToSettingsDescription: 'Please set up biometric authentication in your device settings.',
            biometricHint: 'Touch the fingerprint sensor',
            biometricNotRecognized: 'Biometric not recognized. Please try again.',
            biometricRequiredTitle: 'Biometric authentication required',
            biometricSuccess: 'Biometric authentication succeeded!',
            deviceCredentialsRequiredTitle: 'Device credentials required',
            deviceCredentialsSetupDescription: 'Please set up device credentials in Settings.',
            signInTitle: 'Authenticate to access TrackFi',
          ),
        ],
        options: AuthenticationOptions(
          biometricOnly: biometricOnly,
          stickyAuth: true,
        ),
      );

      if (authenticated) {
        return const BiometricAuthResult(result: BiometricResult.success);
      }

      return BiometricAuthResult(
        result: BiometricResult.userCancel,
        shouldFallbackToPin: allowFallbackToPin,
      );
      
    } on PlatformException catch (e, stackTrace) {
      await log(
        message: 'Biometric authentication failed: ${e.code} - ${e.message}',
        error: e,
        stackTrace: stackTrace,
      );

      return _handlePlatformException(e, allowFallbackToPin);
    } catch (e, stackTrace) {
      await log(
        message: 'Unexpected error during biometric authentication',
        error: e,
        stackTrace: stackTrace,
      );
      
      return BiometricAuthResult(
        result: BiometricResult.unknown,
        error: 'Unexpected error occurred. Please try again.',
        shouldFallbackToPin: allowFallbackToPin,
      );
    }
  }

  static BiometricAuthResult _handlePlatformException(
    PlatformException e,
    bool allowFallbackToPin,
  ) {
    switch (e.code) {
      case 'UserCancel':
      case 'SystemCancel':
        return BiometricAuthResult(
          result: BiometricResult.userCancel,
          shouldFallbackToPin: allowFallbackToPin,
        );
        
      case 'NotAvailable':
        return BiometricAuthResult(
          result: BiometricResult.notAvailable,
          error: 'Biometric authentication is not available on this device.',
          shouldFallbackToPin: allowFallbackToPin,
        );
        
      case 'NotEnrolled':
        return BiometricAuthResult(
          result: BiometricResult.notEnrolled,
          error: 'No biometric credentials are enrolled. Please set them up in Settings.',
          shouldFallbackToPin: allowFallbackToPin,
        );
        
      case 'LockedOut':
        return const BiometricAuthResult(
          result: BiometricResult.temporaryLockout,
          error: 'Biometric authentication is temporarily locked. Please use your PIN.',
          shouldFallbackToPin: true, // Force fallback for lockouts
        );
        
      case 'PermanentlyLockedOut':
        return const BiometricAuthResult(
          result: BiometricResult.permanentLockout,
          error: 'Biometric authentication is permanently locked. Please use your PIN.',
          shouldFallbackToPin: true, // Force fallback for permanent lockouts
        );
        
      case 'BiometricNotRecognized':
      case 'AuthenticationFailed':
        return BiometricAuthResult(
          result: BiometricResult.failed,
          error: 'Biometric not recognized. Please try again or use your PIN.',
          shouldFallbackToPin: allowFallbackToPin,
        );
        
      case 'no_fragment_activity':
        return BiometricAuthResult(
          result: BiometricResult.unknown,
          error: 'App configuration issue. Please restart the app.',
          shouldFallbackToPin: allowFallbackToPin,
        );
        
      default:
        return BiometricAuthResult(
          result: BiometricResult.unknown,
          error: 'Biometric authentication failed. Please try your PIN.',
          shouldFallbackToPin: allowFallbackToPin,
        );
    }
  }

  static String getBiometricTypeString(List<BiometricType> types) {
    if (types.contains(BiometricType.face)) {
      return 'Face ID';
    } else if (types.contains(BiometricType.fingerprint)) {
      return 'Fingerprint';
    } else if (types.contains(BiometricType.iris)) {
      return 'Iris';
    } else if (types.contains(BiometricType.strong)) {
      return 'Biometric';
    } else if (types.contains(BiometricType.weak)) {
      return 'Biometric';
    }
    return 'Biometric';
  }

  /// Get the appropriate icon for the available biometric types
  static IconData getBiometricIcon(List<BiometricType> types) {
    if (types.contains(BiometricType.face)) {
      return Icons.face;
    } else if (types.contains(BiometricType.fingerprint)) {
      return Icons.fingerprint;
    } else if (types.contains(BiometricType.iris)) {
      return Icons.visibility;
    }
    return Icons.fingerprint;
  }
}

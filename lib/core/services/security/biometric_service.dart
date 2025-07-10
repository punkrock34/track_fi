import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_darwin/local_auth_darwin.dart';

import '../../logging/log.dart';

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

  static Future<bool> authenticate({
    String reason = 'Please authenticate to continue',
    bool biometricOnly = false,
  }) async {
    try {
      final bool available = await isAvailable();
      if (!available) {
        await log(message: 'Biometrics not available for authentication');
        return false;
      }

      return await _localAuth.authenticate(
        localizedReason: reason,
        authMessages: const <AuthMessages>[
          IOSAuthMessages(
            cancelButton: 'Cancel',
            goToSettingsButton: 'Settings',
            goToSettingsDescription: 'Set up your biometric authentication in Settings.',
            lockOut: 'Biometric authentication is temporarily locked. Please try again later.',
          ),
          AndroidAuthMessages(
            cancelButton: 'Cancel',
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
    } on PlatformException catch (e, stackTrace) {
      // Handle specific error codes
      String userMessage;
      switch (e.code) {
        case 'no_fragment_activity':
          userMessage = 'Biometric authentication setup issue. Please restart the app.';
        case 'NotAvailable':
          userMessage = 'Biometric authentication is not available on this device.';
        case 'NotEnrolled':
          userMessage = 'No biometric credentials are enrolled. Please set them up in Settings.';
        case 'LockedOut':
          userMessage = 'Biometric authentication is temporarily locked. Please try again later.';
        case 'PermanentlyLockedOut':
          userMessage = 'Biometric authentication is permanently locked. Please use device credentials.';
        case 'UserCancel':
          userMessage = 'Authentication was cancelled by user.';
        default:
          userMessage = 'Biometric authentication failed. Please try again.';
      }
      
      await log(
        message: 'Biometric authentication failed: ${e.code} - $userMessage',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    } catch (e, stackTrace) {
      await log(
        message: 'Unexpected error during biometric authentication',
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
    } else if (types.contains(BiometricType.strong)) {
      return 'Biometric';
    } else if (types.contains(BiometricType.weak)) {
      return 'Biometric';
    }
    return 'Biometric';
  }
  
  static String getErrorMessage(PlatformException e) {
    switch (e.code) {
      case 'no_fragment_activity':
        return 'App configuration issue. Please restart the app and try again.';
      case 'NotAvailable':
        return 'Biometric authentication is not available on this device.';
      case 'NotEnrolled':
        return 'No fingerprint or face ID is set up. Please configure biometric security in your device settings.';
      case 'LockedOut':
        return 'Too many failed attempts. Biometric authentication is temporarily disabled.';
      case 'PermanentlyLockedOut':
        return 'Biometric authentication is disabled. Please use your device passcode.';
      case 'UserCancel':
        return 'Authentication was cancelled.';
      default:
        return 'Biometric authentication failed. Please try again or use your PIN.';
    }
  }
}

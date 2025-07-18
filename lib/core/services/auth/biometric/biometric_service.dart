import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_darwin/local_auth_darwin.dart';

import '../../../contracts/services/auth/biometric/i_biometric_service.dart';
import '../../../logging/log.dart';
import '../../../models/auth/biometric/biometric_auth_result.dart';
import '../../../models/auth/biometric/biometric_result.dart';

class BiometricService implements IBiometricService {
  final LocalAuthentication _localAuth = LocalAuthentication();

  @override
  Future<bool> isAvailable() async {
    try {
      final bool canCheckBiometrics = await _localAuth.canCheckBiometrics;
      final bool isDeviceSupported = await _localAuth.isDeviceSupported();
      final List<BiometricType> available = await _localAuth.getAvailableBiometrics();

      return canCheckBiometrics && isDeviceSupported && available.isNotEmpty;
    } catch (e, stackTrace) {
      await log(
        message: 'Biometric availability check failed',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  @override
  Future<bool> isSpecificBiometricAvailable({
    bool allowFingerprint = true,
    bool allowFaceID = true,
    bool allowIris = false,
  }) async {
    try {
      final List<BiometricType> available = await _localAuth.getAvailableBiometrics();

      return available.any((BiometricType type) {
        return (type == BiometricType.fingerprint && allowFingerprint) ||
               (type == BiometricType.face && allowFaceID) ||
               (type == BiometricType.iris && allowIris) ||
               (type == BiometricType.strong && (allowFingerprint || allowFaceID)) ||
               (type == BiometricType.weak && (allowFingerprint || allowFaceID));
      });
    } catch (e, stackTrace) {
      await log(
        message: 'Specific biometric check failed',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  @override
  Future<BiometricType?> getPrimaryBiometricType() async {
    try {
      final List<BiometricType> types = await getAvailableBiometrics();
      if (types.contains(BiometricType.fingerprint)) {
        return BiometricType.fingerprint;
      }
      if (types.contains(BiometricType.face)) {
        return BiometricType.face;
      }
      if (types.contains(BiometricType.iris)) {
        return BiometricType.iris;
      }
      if (types.contains(BiometricType.strong)) {
        return BiometricType.strong;
      }
      if (types.contains(BiometricType.weak)) {
        return BiometricType.weak;
      }
      return null;
    } catch (e, stackTrace) {
      await log(message: 'Primary biometric type error', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  @override
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e, stackTrace) {
      await log(message: 'Get biometrics failed', error: e, stackTrace: stackTrace);
      return <BiometricType>[];
    }
  }

  @override
  Future<BiometricAuthResult> authenticate({
    String reason = 'Please authenticate to continue',
    bool biometricOnly = true,
    bool allowFallbackToPin = true,
  }) async {
    final bool available = await isAvailable();
    if (!available) {
      return const BiometricAuthResult(
        result: BiometricResult.notAvailable,
        shouldFallbackToPin: true,
      );
    }

    try {
      final bool authenticated = await _localAuth.authenticate(
        localizedReason: reason,
        authMessages: _buildMessages(),
        options: AuthenticationOptions(
          biometricOnly: biometricOnly,
          stickyAuth: true,
        ),
      );

      return authenticated
          ? const BiometricAuthResult(result: BiometricResult.success)
          : BiometricAuthResult(
              result: BiometricResult.userCancel,
              shouldFallbackToPin: allowFallbackToPin,
            );
    } on PlatformException catch (e, stackTrace) {
      await log(message: 'Auth error', error: e, stackTrace: stackTrace);
      return _handlePlatformException(e, allowFallbackToPin);
    } catch (e, stackTrace) {
      await log(message: 'Unexpected biometric error', error: e, stackTrace: stackTrace);
      return BiometricAuthResult(
        result: BiometricResult.unknown,
        error: 'Unexpected error occurred.',
        shouldFallbackToPin: allowFallbackToPin,
      );
    }
  }

  @override
  Future<BiometricAuthResult> authenticateWithSpecificType({
    String reason = 'Please authenticate to continue',
    bool allowFingerprint = true,
    bool allowFaceID = true,
    bool allowIris = false,
    bool allowFallbackToPin = true,
  }) async {
    final bool ok = await isSpecificBiometricAvailable(
      allowFingerprint: allowFingerprint,
      allowFaceID: allowFaceID,
      allowIris: allowIris,
    );

    if (!ok) {
      return const BiometricAuthResult(
        result: BiometricResult.notAvailable,
        shouldFallbackToPin: true,
      );
    }

    try {
      final bool authenticated = await _localAuth.authenticate(
        localizedReason: reason,
        authMessages: _buildMessages(
          fingerprint: allowFingerprint,
          face: allowFaceID,
        ),
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      return authenticated
          ? const BiometricAuthResult(result: BiometricResult.success)
          : BiometricAuthResult(
              result: BiometricResult.userCancel,
              shouldFallbackToPin: allowFallbackToPin,
            );
    } on PlatformException catch (e, stackTrace) {
      await log(message: 'Auth error (specific)', error: e, stackTrace: stackTrace);
      return _handlePlatformException(e, allowFallbackToPin);
    } catch (e, stackTrace) {
      await log(message: 'Unexpected biometric error', error: e, stackTrace: stackTrace);
      return BiometricAuthResult(
        result: BiometricResult.unknown,
        error: 'Unexpected error occurred.',
        shouldFallbackToPin: allowFallbackToPin,
      );
    }
  }

  @override
  String getBiometricTypeString(List<BiometricType> types) {
    if (types.contains(BiometricType.face)) {
      return 'Face ID';
    }
    if (types.contains(BiometricType.fingerprint)) {
      return 'Fingerprint';
    }
    if (types.contains(BiometricType.iris)) {
      return 'Iris';
    }
    return 'Biometric';
  }

  @override
  IconData getBiometricIcon(List<BiometricType> types) {
    if (types.contains(BiometricType.face)) {
      return Icons.face;
    }
    if (types.contains(BiometricType.fingerprint)) {
      return Icons.fingerprint;
    }
    if (types.contains(BiometricType.iris)) {
      return Icons.visibility;
    }
    return Icons.fingerprint;
  }

  List<AuthMessages> _buildMessages({bool fingerprint = true, bool face = true}) {
    return <AuthMessages>[
      const IOSAuthMessages(
        cancelButton: 'Use PIN',
        goToSettingsButton: 'Settings',
        goToSettingsDescription: 'Set up biometrics in Settings',
        lockOut: 'Biometric is temporarily locked. Use PIN.',
      ),
      AndroidAuthMessages(
        cancelButton: 'Use PIN',
        goToSettingsButton: 'Settings',
        goToSettingsDescription: 'Please configure biometrics in your device settings.',
        biometricHint: fingerprint
            ? 'Touch the fingerprint sensor'
            : face
                ? 'Look at the camera'
                : 'Use biometric',
        biometricNotRecognized: 'Not recognized. Try again.',
        biometricSuccess: 'Authentication succeeded!',
        biometricRequiredTitle: 'Authentication required',
        deviceCredentialsRequiredTitle: 'Device PIN required',
        deviceCredentialsSetupDescription: 'Setup device PIN in Settings.',
        signInTitle: 'Access TrackFi',
      ),
    ];
  }

  BiometricAuthResult _handlePlatformException(
    PlatformException e,
    bool allowFallbackToPin,
  ) {
    switch (e.code) {
      case 'UserCancel':
      case 'SystemCancel':
        return BiometricAuthResult(result: BiometricResult.userCancel, shouldFallbackToPin: allowFallbackToPin);
      case 'NotAvailable':
        return BiometricAuthResult(result: BiometricResult.notAvailable, shouldFallbackToPin: allowFallbackToPin);
      case 'NotEnrolled':
        return BiometricAuthResult(result: BiometricResult.notEnrolled, shouldFallbackToPin: allowFallbackToPin);
      case 'LockedOut':
        return const BiometricAuthResult(result: BiometricResult.temporaryLockout, shouldFallbackToPin: true);
      case 'PermanentlyLockedOut':
        return const BiometricAuthResult(result: BiometricResult.permanentLockout, shouldFallbackToPin: true);
      case 'AuthenticationFailed':
      case 'BiometricNotRecognized':
        return BiometricAuthResult(result: BiometricResult.failed, shouldFallbackToPin: allowFallbackToPin);
      default:
        return BiometricAuthResult(result: BiometricResult.unknown, shouldFallbackToPin: allowFallbackToPin);
    }
  }
}

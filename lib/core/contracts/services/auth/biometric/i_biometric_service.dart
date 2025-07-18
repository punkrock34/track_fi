import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

import '../../../../models/auth/biometric/biometric_auth_result.dart';

abstract class IBiometricService {
  Future<bool> isAvailable();
  Future<bool> isSpecificBiometricAvailable({
    bool allowFingerprint,
    bool allowFaceID,
    bool allowIris,
  });
  Future<BiometricType?> getPrimaryBiometricType();
  Future<List<BiometricType>> getAvailableBiometrics();
  Future<BiometricAuthResult> authenticate({
    String reason,
    bool biometricOnly,
    bool allowFallbackToPin,
  });
  Future<BiometricAuthResult> authenticateWithSpecificType({
    String reason,
    bool allowFingerprint,
    bool allowFaceID,
    bool allowIris,
    bool allowFallbackToPin,
  });

  String getBiometricTypeString(List<BiometricType> types);
  IconData getBiometricIcon(List<BiometricType> types);
}

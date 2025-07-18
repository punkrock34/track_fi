import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../contracts/services/auth/biometric/i_biometric_service.dart';
import '../../../services/auth/biometric/biometric_service.dart';

final Provider<IBiometricService> biometricServiceProvider = Provider<IBiometricService>((ProviderRef<IBiometricService> ref) {
  return BiometricService();
});

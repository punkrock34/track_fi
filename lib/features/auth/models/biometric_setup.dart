import 'package:local_auth/local_auth.dart';

class BiometricSetup {
  const BiometricSetup({
    required this.enabled,
    required this.available,
    required this.types,
    required this.shouldUseBiometric,
  });
  
  final bool enabled;
  final bool available;
  final List<BiometricType> types;
  final bool shouldUseBiometric;

  bool get isBiometricAvailable => available && enabled;
}

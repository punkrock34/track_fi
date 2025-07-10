import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../contracts/services/secure_storage/i_biometric_storage_service.dart';
import '../../contracts/services/secure_storage/i_secure_storage_service.dart';
import '../../services/secure_storage/biometric_storage_service.dart';
import 'secure_storage_provider.dart';

final Provider<IBiometricStorageService> biometricStorageProvider = Provider<IBiometricStorageService>((ProviderRef<IBiometricStorageService> ref) {
  final ISecureStorageService storage = ref.read(secureStorageProvider);
  return BiometricStorageService(storage);
});

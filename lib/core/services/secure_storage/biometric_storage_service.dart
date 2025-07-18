import '../../contracts/services/secure_storage/i_biometric_storage_service.dart';
import '../../contracts/services/secure_storage/i_secure_storage_service.dart';

class BiometricStorageService implements IBiometricStorageService {
  BiometricStorageService(this._storage);

  final ISecureStorageService _storage;
  static const String _biometricEnabledKey = 'biometric_enabled';

  @override
  Future<void> setBiometricEnabled(bool enabled) =>
      _storage.write(_biometricEnabledKey, enabled.toString());

  @override
  Future<bool> isBiometricEnabled() async {
    final String? value = await _storage.read(_biometricEnabledKey);
    return value == 'true';
  }
}

abstract class IBiometricStorageService {
  Future<void> setBiometricEnabled(bool enabled);
  Future<bool> isBiometricEnabled();
}

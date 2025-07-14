abstract class IPinStorageService {
  Future<int?> getPinLength();
  Future<void> storePin(String pin);
  Future<bool> verifyPin(String pin);
  Future<bool> hasPinSet();
  Future<void> clearPin();
}

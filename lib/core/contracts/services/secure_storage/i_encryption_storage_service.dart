abstract class IEncryptionStorageService {
  Future<String> encrypt(String plaintext);
  Future<String> decrypt(String encrypted);
}

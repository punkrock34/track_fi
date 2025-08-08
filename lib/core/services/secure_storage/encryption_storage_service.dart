import 'dart:convert';
import 'dart:math';
import 'package:encrypt/encrypt.dart';

import '../../contracts/services/secure_storage/i_encryption_storage_service.dart';
import '../../contracts/services/secure_storage/i_secure_storage_service.dart';

class EncryptionStorageService implements IEncryptionStorageService {
  EncryptionStorageService(this._secureStorage);

  static const String _keyName = 'trackfi_encryption_key';
  final ISecureStorageService _secureStorage;

  Future<Key> _getKey() async {
    String? base64Key = await _secureStorage.read(_keyName);
    if (base64Key == null) {
      final List<int> key = List<int>.generate(32, (_) => Random.secure().nextInt(256));
      base64Key = base64Encode(key);
      await _secureStorage.write(_keyName, base64Key);
    }
    return Key.fromBase64(base64Key);
  }

  @override
  Future<String> encrypt(String plaintext) async {
    final Key key = await _getKey();
    final IV iv = IV.fromSecureRandom(16);
    final Encrypter encrypter = Encrypter(AES(key, mode: AESMode.cbc));
    final Encrypted encrypted = encrypter.encrypt(plaintext, iv: iv);
    return '${iv.base64}:${encrypted.base64}';
  }

  @override
  Future<String> decrypt(String encryptedText) async {
    final Key key = await _getKey();
    final List<String> parts = encryptedText.split(':');
    if (parts.length != 2) {
      return encryptedText;
    }

    final IV iv = IV.fromBase64(parts[0]);
    final Encrypted encrypted = Encrypted.fromBase64(parts[1]);
    final Encrypter encrypter = Encrypter(AES(key, mode: AESMode.cbc));
    return encrypter.decrypt(encrypted, iv: iv);
  }
}

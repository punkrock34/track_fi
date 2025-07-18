import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../contracts/services/secure_storage/i_secure_storage_service.dart';

class SecureStorageService implements ISecureStorageService {
  static const AndroidOptions _androidOptions = AndroidOptions(encryptedSharedPreferences: true);
  static const IOSOptions _iosOptions = IOSOptions(
    accessibility: KeychainAccessibility.first_unlock_this_device,
  );

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: _androidOptions,
    iOptions: _iosOptions,
  );

  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  @override
  Future<String?> read(String key) =>
      _storage.read(key: key);

  @override
  Future<void> delete(String key) =>
      _storage.delete(key: key);

  @override
  Future<void> clearAll() =>
      _storage.deleteAll();
}

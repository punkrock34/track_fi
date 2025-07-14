import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';

import '../../config/app_config.dart';
import '../../contracts/services/secure_storage/i_pin_storage_service.dart';
import '../../contracts/services/secure_storage/i_secure_storage_service.dart';

class PinStorageService implements IPinStorageService {
  PinStorageService(this._secureStorage);

  static const String _pinKey = 'user_pin_hash';
  static const String _pinLengthKey = 'user_pin_length';
  final ISecureStorageService _secureStorage;

  @override
  Future<int?> getPinLength() async {
    final String? storedLength = await _secureStorage.read(_pinLengthKey);
    if (storedLength != null) {
      return int.tryParse(storedLength);
    }
    return null;
  }

  @override
  Future<void> storePin(String pin) async {
    final String salted = pin + AppConfig.trackfiSalt;
    final Uint8List bytes = utf8.encode(salted);
    final String hash = sha256.convert(bytes).toString();
    
    await _secureStorage.write(_pinKey, hash);
    await _secureStorage.write(_pinLengthKey, pin.length.toString());
  }

  @override
  Future<bool> verifyPin(String pin) async {
    final String? storedHash = await _secureStorage.read(_pinKey);
    if (storedHash == null) {
      return false;
    }
    final Uint8List bytes = utf8.encode(pin + AppConfig.trackfiSalt);
    final String hash = sha256.convert(bytes).toString();
    return storedHash == hash;
  }

  @override
  Future<bool> hasPinSet() async {
    final String? storedHash = await _secureStorage.read(_pinKey);
    return storedHash != null && storedHash.isNotEmpty;
  }

  @override
  Future<void> clearPin() async {
    await _secureStorage.delete(_pinKey);
    await _secureStorage.delete(_pinLengthKey);
  }
}

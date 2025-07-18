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
    return storedLength != null ? int.tryParse(storedLength) : null;
  }

  @override
  Future<void> storePin(String pin) async {
    final String hash = _hashPin(pin);
    await _secureStorage.write(_pinKey, hash);
    await _secureStorage.write(_pinLengthKey, pin.length.toString());
  }

  @override
  Future<bool> verifyPin(String pin) async {
    final String? storedHash = await _secureStorage.read(_pinKey);
    return storedHash != null && storedHash == _hashPin(pin);
  }

  @override
  Future<bool> hasPinSet() async {
    final String? storedHash = await _secureStorage.read(_pinKey);
    return storedHash?.isNotEmpty ?? false;
  }

  @override
  Future<void> clearPin() async {
    await _secureStorage.delete(_pinKey);
    await _secureStorage.delete(_pinLengthKey);
  }

  String _hashPin(String pin) {
    final String salted = pin + AppConfig.trackfiSalt;
    final Uint8List bytes = utf8.encode(salted);
    return sha256.convert(bytes).toString();
  }
}

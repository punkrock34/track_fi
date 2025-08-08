import 'dart:convert';

import '../../contracts/services/secure_storage/i_currency_storage_service.dart';
import '../../contracts/services/secure_storage/i_secure_storage_service.dart';

class CurrencyStorageService implements ICurrencyStorageService {
  CurrencyStorageService(this._storage);

  final ISecureStorageService _storage;
  
  static const String _baseCurrencyKey = 'user_base_currency';
  static const String _exchangeRatesPrefix = 'exchange_rates_';
  static const String _lastUpdatePrefix = 'rates_last_update_';
  static const String _defaultBaseCurrency = 'RON';

  @override
  Future<String> getBaseCurrency() async {
    try {
      final String? storedCurrency = await _storage.read(_baseCurrencyKey);
      final String currency = storedCurrency ?? _defaultBaseCurrency;

      return currency.toUpperCase();
    } catch (e) {
      return _defaultBaseCurrency;
    }
  }

  @override
  Future<void> setBaseCurrency(String currencyCode) async {
    try {
      await _storage.write(_baseCurrencyKey, currencyCode.toUpperCase());
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> setExchangeRates(String baseCurrency, Map<String, double> rates) async {
    try {
      final String key = _exchangeRatesPrefix + baseCurrency.toLowerCase();
      final String jsonString = json.encode(rates);
      await _storage.write(key, jsonString);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<String, double>?> getExchangeRates(String baseCurrency) async {
    try {
      final String key = _exchangeRatesPrefix + baseCurrency.toLowerCase();
      final String? jsonString = await _storage.read(key);
      
      if (jsonString == null || jsonString.isEmpty) {
        return null;
      }

      final dynamic decoded = json.decode(jsonString);
      if (decoded is! Map<String, dynamic>) {
        return null;
      }
      
      return decoded.map((String key, dynamic value) => MapEntry<String, double>(
        key,
        (value as num).toDouble(),
      ));
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> setLastRatesUpdate(String baseCurrency, DateTime timestamp) async {
    try {
      final String key = _lastUpdatePrefix + baseCurrency.toLowerCase();
      await _storage.write(key, timestamp.toIso8601String());
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<DateTime?> getLastRatesUpdate(String baseCurrency) async {
    try {
      final String key = _lastUpdatePrefix + baseCurrency.toLowerCase();
      final String? timestampString = await _storage.read(key);
      
      if (timestampString == null || timestampString.isEmpty) {
        return null;
      }

      return DateTime.parse(timestampString);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> clearAllRates() async {
    // This is a simplified implementation - in production you might want
    // to iterate through all keys and delete only currency-related ones
    await _storage.clearAll();
  }
}

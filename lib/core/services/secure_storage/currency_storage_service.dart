import 'dart:convert';
import '../../contracts/services/secure_storage/i_currency_storage_service.dart';
import '../../contracts/services/secure_storage/i_secure_storage_service.dart';

class CurrencyStorageService implements ICurrencyStorageService {
  CurrencyStorageService(this._storage);
  final ISecureStorageService _storage;

  static const String _baseCurrencyKey   = 'user_base_currency';
  static const String _exchangeRatesPref = 'exchange_rates_';
  static const String _lastUpdatePref    = 'rates_last_update_';
  static const String _defaultBaseCurrency = 'RON';

  String _ratesKey(String base) => '$_exchangeRatesPref${base.toLowerCase()}';
  String _lastKey (String base) => '$_lastUpdatePref${base.toLowerCase()}';

  @override
  Future<String> getBaseCurrency() async {
    try {
      final String? v = await _storage.read(_baseCurrencyKey);
      return (v ?? _defaultBaseCurrency).toUpperCase();
    } catch (_) {
      return _defaultBaseCurrency;
    }
  }

  @override
  Future<void> setBaseCurrency(String code) =>
      _storage.write(_baseCurrencyKey, code.toUpperCase());

  @override
  Future<void> setExchangeRates(String base, Map<String, double> rates) async {
    await _storage.write(_ratesKey(base), json.encode(rates));
  }

  @override
  Future<Map<String, double>?> getExchangeRates(String base) async {
    try {
      final String? jsonString = await _storage.read(_ratesKey(base));
      if (jsonString == null || jsonString.isEmpty) {
        return null;
      }

      final dynamic decoded = json.decode(jsonString);
      if (decoded is! Map<String, dynamic>) {
        return null;
      }

      return decoded.map(
        (String k, dynamic v) => MapEntry<String, double>(k, (v as num).toDouble()),
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> setLastRatesUpdate(String base, DateTime ts) =>
      _storage.write(_lastKey(base), ts.toIso8601String());

  @override
  Future<DateTime?> getLastRatesUpdate(String base) async {
    try {
      final String? s = await _storage.read(_lastKey(base));
      if (s == null || s.isEmpty) {
        return null;
      }
      return DateTime.parse(s);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> clearAllRates() async {
    final Map<String, String> all = await _storage.readAll();
    final Iterable<String> keysToDelete = all.keys.where(
      (String k) => k.startsWith(_exchangeRatesPref) || k.startsWith(_lastUpdatePref),
    );
    await Future.wait(keysToDelete.map(_storage.delete));
  }
}

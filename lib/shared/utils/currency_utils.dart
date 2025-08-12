import 'dart:convert';
import 'package:flutter/services.dart';
import '../../core/models/database/account.dart';

class CurrencyUtils {
  CurrencyUtils._();

  static Map<String, dynamic>? _currenciesData;

  static Future<Map<String, dynamic>> _getCurrenciesData() async {
    if (_currenciesData != null) {
      return _currenciesData!;
    }

    try {
      final String jsonString = await rootBundle.loadString('assets/currency/currencies.json');
      _currenciesData = json.decode(jsonString) as Map<String, dynamic>;
      return _currenciesData!;
    } catch (e) {
      _currenciesData = <String, dynamic>{};
      return _currenciesData!;
    }
  }

  /// Get currency symbol from currency code using currencies.json
  static Future<String> getCurrencySymbolFromJson(String currencyCode) async {
    final Map<String, dynamic> currencies = await _getCurrenciesData();
    final Map<String, dynamic>? currencyData = currencies[currencyCode.toUpperCase()] as Map<String, dynamic>?;
    
    if (currencyData != null) {
      return currencyData['symbolNative'] as String? ??
             currencyData['symbol'] as String? ??
             currencyCode;
    }
    
    // Fallback to hardcoded symbols for common currencies
    return getCurrencySymbol(currencyCode);
  }

  /// Get currency name from currency code using currencies.json
  static Future<String> getCurrencyName(String currencyCode) async {
    final Map<String, dynamic> currencies = await _getCurrenciesData();
    final Map<String, dynamic>? currencyData = currencies[currencyCode.toUpperCase()] as Map<String, dynamic>?;
    
    if (currencyData != null) {
      return currencyData['name'] as String? ?? currencyCode;
    }
    
    return currencyCode; // Fallback to code
  }

  /// Get all available currencies from currencies.json
  static Future<List<Map<String, String>>> getAllCurrencies() async {
    final Map<String, dynamic> currencies = await _getCurrenciesData();
    final List<Map<String, String>> result = <Map<String, String>>[];
    
    currencies.forEach((String code, dynamic data) {
      if (data is Map<String, dynamic>) {
        result.add(<String, String>{
          'code': code,
          'name': data['name'] as String? ?? code,
          'symbol': data['symbolNative'] as String? ?? data['symbol'] as String? ?? code,
        });
      }
    });
    
    // Sort by currency name
    result.sort((Map<String, String> a, Map<String, String> b) => 
        (a['name'] ?? '').compareTo(b['name'] ?? ''));
    
    return result;
  }

  static List<String> getPopularCurrencies() {
    return <String>[
      'USD', // US Dollar
      'EUR', // Euro
      'GBP', // British Pound
      'JPY', // Japanese Yen
      'CAD', // Canadian Dollar
      'AUD', // Australian Dollar
      'CHF', // Swiss Franc
      'CNY', // Chinese Yuan
      'SEK', // Swedish Krona
      'NOK', // Norwegian Krone
    ];
  }

  /// Get currency for a specific account
  static String? getCurrencyForAccount(String? accountId, List<Account>? accounts) {
    if (accounts == null || accountId == null) {
      return null;
    }
    
    final Account? account = accounts.cast<Account?>().firstWhere(
      (Account? a) => a?.id == accountId,
      orElse: () => null,
    );
    
    return account?.currency;
  }

  /// Format amount with currency symbol (async version using currencies.json)
  static Future<String> formatAmountWithSymbol(double amount, String currencyCode) async {
    final String symbol = await getCurrencySymbolFromJson(currencyCode);
    return '$symbol${amount.toStringAsFixed(2)}';
  }

  /// Format amount with currency symbol (sync version with fallbacks)
  static String formatAmount(double amount, {String currency = 'lei'}) {
    return '$currency${amount.toStringAsFixed(2)}';
  }

  /// Format large amounts with abbreviations (K, M)
  static Future<String> formatLargeAmountWithSymbol(double amount, String currencyCode) async {
    final String symbol = await getCurrencySymbolFromJson(currencyCode);
    
    if (amount.abs() >= 1000000) {
      return '$symbol${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount.abs() >= 1000) {
      return '$symbol${(amount / 1000).toStringAsFixed(1)}K';
    } else {
      return '$symbol${amount.toStringAsFixed(2)}';
    }
  }

  /// Format large amounts with abbreviations (sync version)
  static String formatLargeAmount(double amount, {String currency = 'lei'}) {
    if (amount.abs() >= 1000000) {
      return '$currency${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount.abs() >= 1000) {
      return '$currency${(amount / 1000).toStringAsFixed(1)}K';
    } else {
      return formatAmount(amount, currency: currency);
    }
  }

  /// Format amount for accounting display (with parentheses for negative)
  static String formatAccountingAmount(double amount, {String currency = 'lei'}) {
    if (amount < 0) {
      return '(${formatAmount(amount.abs(), currency: currency)})';
    }
    return formatAmount(amount, currency: currency);
  }

  /// Get currency symbol from currency code (fallback/sync version)
  static String getCurrencySymbol(String currencyCode) {
    switch (currencyCode.toUpperCase()) {
      case 'GBP':
        return '£';
      case 'USD':
        return r'$';
      case 'EUR':
        return '€';
      case 'JPY':
        return '¥';
      case 'CHF':
        return '₣';
      case 'CAD':
        return r'CA$';
      case 'AUD':
        return r'A$';
      case 'CNY':
        return '¥';
      case 'SEK':
        return 'kr';
      case 'NOK':
        return 'kr';
      case 'RON':
        return 'lei';
      default:
        return currencyCode;
    }
  }

  static Future<bool> isValidCurrency(String currencyCode) async {
    final Map<String, dynamic> currencies = await _getCurrenciesData();
    return currencies.containsKey(currencyCode.toUpperCase());
  }
}

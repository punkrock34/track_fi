import '../../core/models/database/account.dart';

class CurrencyUtils {
  CurrencyUtils._();

  static String getCurrencyForAccount(String? accountId, List<Account>? accounts) {
    if (accounts == null || accountId == null) {
      return 'GBP';
    }
    
    final Account? account = accounts.cast<Account?>().firstWhere(
      (Account? a) => a?.id == accountId,
      orElse: () => null,
    );
    
    return account?.currency ?? 'GBP';
  }


  /// Format amount with currency symbol
  static String formatAmount(double amount, {String currency = '£'}) {
    return '$currency${amount.toStringAsFixed(2)}';
  }

  /// Format large amounts with abbreviations (K, M)
  static String formatLargeAmount(double amount, {String currency = '£'}) {
    if (amount.abs() >= 1000000) {
      return '$currency${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount.abs() >= 1000) {
      return '$currency${(amount / 1000).toStringAsFixed(1)}K';
    } else {
      return formatAmount(amount, currency: currency);
    }
  }

  /// Format amount for accounting display (with parentheses for negative)
  static String formatAccountingAmount(double amount, {String currency = '£'}) {
    if (amount < 0) {
      return '(${formatAmount(amount.abs(), currency: currency)})';
    }
    return formatAmount(amount, currency: currency);
  }

  /// Get currency symbol from currency code
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
      default:
        return currencyCode;
    }
  }
}

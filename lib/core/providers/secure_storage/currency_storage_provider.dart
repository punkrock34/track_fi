import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../contracts/services/secure_storage/i_currency_storage_service.dart';
import '../../contracts/services/secure_storage/i_secure_storage_service.dart';
import '../../services/secure_storage/currency_storage_service.dart';
import 'secure_storage_provider.dart';

final Provider<ICurrencyStorageService> currencyStorageProvider = Provider<ICurrencyStorageService>((ProviderRef<ICurrencyStorageService> ref) {
  final ISecureStorageService storage = ref.read(secureStorageProvider);
  return CurrencyStorageService(storage);
});

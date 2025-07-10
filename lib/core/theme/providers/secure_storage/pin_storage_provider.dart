import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../contracts/services/secure_storage/i_pin_storage_service.dart';
import '../../../contracts/services/secure_storage/i_secure_storage_service.dart';
import '../../../services/secure_storage/pin_storage_service.dart';
import 'secure_storage_provider.dart';

final Provider<IPinStorageService> pinStorageProvider = Provider<IPinStorageService>((ProviderRef<IPinStorageService> ref) {
  final ISecureStorageService storage = ref.read(secureStorageProvider);
  return PinStorageService(storage);
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../contracts/services/secure_storage/i_secure_storage_service.dart';
import '../../../services/secure_storage/secure_storage_service.dart';

final Provider<ISecureStorageService> secureStorageProvider = Provider<ISecureStorageService>((ProviderRef<ISecureStorageService> ref) {
  return SecureStorageService();
});

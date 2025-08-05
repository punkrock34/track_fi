import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../contracts/services/secure_storage/i_encryption_storage_service.dart';
import '../../contracts/services/secure_storage/i_secure_storage_service.dart';
import '../../services/secure_storage/encryption_storage_service.dart';
import 'secure_storage_provider.dart';

final Provider<IEncryptionStorageService> encryptionStorageProvider = Provider<IEncryptionStorageService>((ProviderRef<IEncryptionStorageService> ref) {
  final ISecureStorageService storage = ref.read(secureStorageProvider);
  return EncryptionStorageService(storage);
});

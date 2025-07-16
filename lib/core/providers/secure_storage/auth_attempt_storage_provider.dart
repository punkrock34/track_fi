import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../contracts/services/secure_storage/i_auth_attempt_storage_service.dart';
import '../../contracts/services/secure_storage/i_secure_storage_service.dart';
import '../../services/secure_storage/auth_attempt_storage_service.dart';
import 'secure_storage_provider.dart';

final Provider<IAuthAttemptStorageService> authAttemptStorageProvider =
    Provider<IAuthAttemptStorageService>((ProviderRef<IAuthAttemptStorageService> ref) {
  final ISecureStorageService storage = ref.read(secureStorageProvider);
  return AuthAttemptStorageService(storage);
});

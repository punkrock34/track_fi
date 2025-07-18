import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../contracts/services/auth/jwt/i_jwt_auth_service.dart';
import '../../../contracts/services/secure_storage/i_secure_storage_service.dart';
import '../../../services/auth/jwt/jwt_auth_service.dart';
import '../../secure_storage/secure_storage_provider.dart';

final Provider<IJwtAuthService> jwtAuthServiceProvider = Provider<IJwtAuthService>((ProviderRef<IJwtAuthService> ref) {
  final ISecureStorageService secureStorage = ref.read(secureStorageProvider);
  return JwtAuthService(secureStorage);
});

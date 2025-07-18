import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../features/auth/models/auth_state.dart';
import '../../services/auth/auth_service.dart';
import '../auth/biometric/biometric_service_provider.dart';
import '../secure_storage/auth_attempt_storage_provider.dart';
import '../secure_storage/biometric_storage_provider.dart';
import '../secure_storage/pin_storage_provider.dart';

final StateNotifierProvider<AuthService, AuthenticationState> authServiceProvider =
    StateNotifierProvider<AuthService, AuthenticationState>(
  (StateNotifierProviderRef<AuthService, AuthenticationState> ref) => AuthService(
    pinStorage: ref.read(pinStorageProvider),
    biometricStorage: ref.read(biometricStorageProvider),
    authAttemptStorage: ref.read(authAttemptStorageProvider),
    biometricService: ref.read(biometricServiceProvider),
  ),
);

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../contracts/services/secure_storage/i_onboarding_storage_service.dart';
import '../../contracts/services/secure_storage/i_secure_storage_service.dart';
import '../../services/secure_storage/onboarding_storage_service.dart';
import 'secure_storage_provider.dart';

final Provider<IOnboardingStorageService> onboardingStorageProvider = Provider<IOnboardingStorageService>((ProviderRef<IOnboardingStorageService> ref) {
  final ISecureStorageService storage = ref.read(secureStorageProvider);
  return OnboardingStorageService(storage);
});

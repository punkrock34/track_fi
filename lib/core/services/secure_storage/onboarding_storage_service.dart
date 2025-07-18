import '../../contracts/services/secure_storage/i_onboarding_storage_service.dart';
import '../../contracts/services/secure_storage/i_secure_storage_service.dart';

class OnboardingStorageService implements IOnboardingStorageService {
  OnboardingStorageService(this._storage);

  final ISecureStorageService _storage;
  static const String _onboardingCompleteKey = 'onboarding_complete';

  @override
  Future<void> setOnboardingComplete(bool complete) =>
      _storage.write(_onboardingCompleteKey, complete.toString());

  @override
  Future<bool> isOnboardingComplete() async {
    final String? value = await _storage.read(_onboardingCompleteKey);
    return value == 'true';
  }
}

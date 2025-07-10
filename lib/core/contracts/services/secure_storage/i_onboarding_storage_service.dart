abstract class IOnboardingStorageService {
  Future<void> setOnboardingComplete(bool complete);
  Future<bool> isOnboardingComplete();
}

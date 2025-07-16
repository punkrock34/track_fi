abstract class IAuthAttemptStorageService {
  Future<void> setLockoutEndTime(DateTime lockoutEnd);
  Future<DateTime?> getLockoutEndTime();
  Future<void> clearLockoutEndTime();
  
  Future<void> setFailedAttempts(int attempts);
  Future<int> getFailedAttempts();
  Future<void> clearFailedAttempts();
  
  Future<void> incrementFailedAttempts();
  Future<bool> isCurrentlyLockedOut();
  Future<void> clearAllAttemptData();
}

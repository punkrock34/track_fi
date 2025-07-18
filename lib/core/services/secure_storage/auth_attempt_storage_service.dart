import '../../contracts/services/secure_storage/i_auth_attempt_storage_service.dart';
import '../../contracts/services/secure_storage/i_secure_storage_service.dart';

class AuthAttemptStorageService implements IAuthAttemptStorageService {
  AuthAttemptStorageService(this._storage);

  final ISecureStorageService _storage;

  static const String _lockoutEndTimeKey = 'auth_lockout_end_time';
  static const String _failedAttemptsKey = 'auth_failed_attempts';

  @override
  Future<void> setLockoutEndTime(DateTime lockoutEnd) =>
      _storage.write(_lockoutEndTimeKey, lockoutEnd.toIso8601String());

  @override
  Future<DateTime?> getLockoutEndTime() async {
    final String? raw = await _storage.read(_lockoutEndTimeKey);
    if (raw == null) {
      return null;
    }

    try {
      return DateTime.parse(raw);
    } catch (_) {
      await clearLockoutEndTime();
      return null;
    }
  }

  @override
  Future<void> clearLockoutEndTime() =>
      _storage.delete(_lockoutEndTimeKey);

  @override
  Future<void> setFailedAttempts(int attempts) =>
      _storage.write(_failedAttemptsKey, attempts.toString());

  @override
  Future<int> getFailedAttempts() async {
    final String? raw = await _storage.read(_failedAttemptsKey);
    return int.tryParse(raw ?? '0') ?? 0;
  }

  @override
  Future<void> clearFailedAttempts() =>
      _storage.delete(_failedAttemptsKey);

  @override
  Future<void> incrementFailedAttempts() async {
    final int current = await getFailedAttempts();
    await setFailedAttempts(current + 1);
  }

  @override
  Future<bool> isCurrentlyLockedOut() async {
    final DateTime? lockoutEnd = await getLockoutEndTime();
    if (lockoutEnd == null) {
      return false;
    }

    final bool locked = DateTime.now().isBefore(lockoutEnd);
    if (!locked) {
      await clearLockoutEndTime();
    }
    return locked;
  }

  @override
  Future<void> clearAllAttemptData() =>
      Future.wait(<Future<void>>[clearLockoutEndTime(), clearFailedAttempts()]);
}

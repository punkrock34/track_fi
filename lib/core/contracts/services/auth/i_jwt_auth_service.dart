abstract class IJwtAuthService {
  Future<bool> isAuthenticated();
  Future<String?> getValidAccessToken();
  Future<bool> loginWithPin(String pin);
  Future<bool> registerDevice(String pin);
  Future<void> logout();
  Future<String?> getCurrentUserId();
  Future<void> clearTokens();
}

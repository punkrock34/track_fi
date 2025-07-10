abstract class IThemeStorageService {
  Future<void> storeThemePreferences(Map<String, dynamic> preferences);
  Future<Map<String, dynamic>?> getThemePreferences();
}

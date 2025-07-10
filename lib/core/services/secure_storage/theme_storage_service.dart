import 'dart:convert';

import '../../contracts/services/secure_storage/i_secure_storage_service.dart';
import '../../contracts/services/secure_storage/i_theme_storage_service.dart';

class ThemeStorageService implements IThemeStorageService {
  ThemeStorageService(this._storage);

  final ISecureStorageService _storage;
  static const String _themePreferencesKey = 'theme_preferences';

  @override
  Future<void> storeThemePreferences(Map<String, dynamic> preferences) async {
    final String jsonString = jsonEncode(preferences);
    await _storage.write(_themePreferencesKey, jsonString);
  }

  @override
  Future<Map<String, dynamic>?> getThemePreferences() async {
    final String? jsonString = await _storage.read(_themePreferencesKey);
    if (jsonString == null) {
      return null;
    }
    return jsonDecode(jsonString) as Map<String, dynamic>;
  }
}

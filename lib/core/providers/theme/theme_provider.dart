import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../contracts/services/secure_storage/i_secure_storage_service.dart';
import '../../logging/log.dart';
import '../../theme/app_theme.dart';
import '../secure_storage/secure_storage_provider.dart';

class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier(this._secureStorage) : super(ThemeMode.system) {
    _loadThemeMode();
  }

  final ISecureStorageService _secureStorage;
  static const String _themeKey = 'theme_preferences';

  Future<void> _loadThemeMode() async {
    try {
      final String? savedTheme = await _secureStorage.read(_themeKey);
      if (savedTheme != null) {
        state = ThemeMode.values.firstWhere(
          (ThemeMode mode) => mode.toString() == savedTheme,
          orElse: () => ThemeMode.system,
        );
      }
    } catch (e) {
      state = ThemeMode.system;
    }
  }

  Future<void> _saveThemeMode(ThemeMode mode) async {
    try {
      await _secureStorage.write( _themeKey, mode.toString());
    } catch (e, stackTrace) {
      await log(
        message: 'Failed to save theme mode',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (state != mode) {
      await HapticFeedback.lightImpact();
      
      state = mode;
      await _saveThemeMode(mode);
    }
  }

  Future<void> toggleTheme() async {
    switch (state) {
      case ThemeMode.light:
        await setThemeMode(ThemeMode.dark);
      case ThemeMode.dark:
        await setThemeMode(ThemeMode.light);
      case ThemeMode.system:
        final Brightness brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
        await setThemeMode(brightness == Brightness.dark ? ThemeMode.light : ThemeMode.dark);
    }
  }

  bool isDark(BuildContext context) {
    switch (state) {
      case ThemeMode.light:
        return false;
      case ThemeMode.dark:
        return true;
      case ThemeMode.system:
        return MediaQuery.of(context).platformBrightness == Brightness.dark;
    }
  }
}

final StateNotifierProvider<ThemeNotifier, ThemeMode> themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>(
  (StateNotifierProviderRef<ThemeNotifier, ThemeMode> ref) {
    final ISecureStorageService storage = ref.read(secureStorageProvider);
    return ThemeNotifier(storage);
  }
);

final Provider<bool> isDarkModeProvider = Provider<bool>((ProviderRef<bool> ref) {
  final ThemeMode themeMode = ref.watch(themeProvider);
  final Brightness platformBrightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
  
  switch (themeMode) {
    case ThemeMode.light:
      return false;
    case ThemeMode.dark:
      return true;
    case ThemeMode.system:
      return platformBrightness == Brightness.dark;
  }
});

final Provider<ThemeData> currentThemeProvider = Provider<ThemeData>((ProviderRef<ThemeData> ref) {
  final bool isDark = ref.watch(isDarkModeProvider);
  return isDark ? AppTheme.dark : AppTheme.light;
});

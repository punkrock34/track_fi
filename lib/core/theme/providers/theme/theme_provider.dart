import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../logging/log.dart';
import '../../app_theme.dart';

class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.system) {
    _loadThemeMode();
  }

  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static const String _themeKey = 'app_theme_mode';

  Future<void> _loadThemeMode() async {
    try {
      final String? savedTheme = await _storage.read(key: _themeKey);
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
      await _storage.write(key: _themeKey, value: mode.toString());
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
  (StateNotifierProviderRef<ThemeNotifier, ThemeMode> ref) => ThemeNotifier(),
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

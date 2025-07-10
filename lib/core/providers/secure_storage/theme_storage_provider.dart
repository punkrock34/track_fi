import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../contracts/services/secure_storage/i_secure_storage_service.dart';
import '../../contracts/services/secure_storage/i_theme_storage_service.dart';
import '../../services/secure_storage/theme_storage_service.dart';
import 'secure_storage_provider.dart';

final Provider<IThemeStorageService> themeStorageProvider = Provider<IThemeStorageService>((ProviderRef<IThemeStorageService> ref) {
  final ISecureStorageService storage = ref.read(secureStorageProvider);
  return ThemeStorageService(storage);
});

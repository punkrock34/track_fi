import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../contracts/services/database/i_database_service.dart';
import '../../../contracts/services/database/storage/i_category_storage_service.dart';
import '../../../services/database/storage/category_storage_service.dart';
import '../database_service_provider.dart';

final Provider<ICategoryStorageService> categoryStorageProvider = Provider<ICategoryStorageService>((ProviderRef<ICategoryStorageService> ref) {
  final IDatabaseService db = ref.read(databaseServiceProvider);
  return CategoryStorageService(db);
});

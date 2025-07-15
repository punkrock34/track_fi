import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../contracts/services/database/i_database_service.dart';
import '../../../contracts/services/database/storage/i_sync_status_storage_service.dart';
import '../../../services/database/storage/sync_status_storage_service.dart';
import '../database_service_provider.dart';

final Provider<ISyncStatusStorageService> syncStatusStorageProvider = Provider<ISyncStatusStorageService>((ProviderRef<ISyncStatusStorageService> ref) {
  final IDatabaseService db = ref.read(databaseServiceProvider);
  return SyncStatusStorageService(db);
});

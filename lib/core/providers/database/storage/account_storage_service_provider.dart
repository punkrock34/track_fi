import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../contracts/services/database/i_database_service.dart';
import '../../../contracts/services/database/storage/i_account_storage_service.dart';
import '../../../services/database/storage/account_storage_service.dart';
import '../database_service_provider.dart';

final Provider<IAccountStorageService> accountStorageProvider = Provider<IAccountStorageService>((ProviderRef<IAccountStorageService> ref) {
  final IDatabaseService db = ref.read(databaseServiceProvider);
  return AccountStorageService(db);
});

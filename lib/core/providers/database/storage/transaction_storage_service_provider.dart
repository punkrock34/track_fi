import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../contracts/services/database/i_database_service.dart';
import '../../../contracts/services/database/storage/i_transaction_storage_service.dart';
import '../../../services/database/storage/transaction_storage_service.dart';
import '../database_service_provider.dart';

final Provider<ITransactionStorageService> transactionStorageProvider = Provider<ITransactionStorageService>((ProviderRef<ITransactionStorageService> ref) {
  final IDatabaseService db = ref.read(databaseServiceProvider);
  return TransactionStorageService(db);
});

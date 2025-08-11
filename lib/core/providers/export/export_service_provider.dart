import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../contracts/services/export/i_export_service.dart';
import '../../services/export/export_service.dart';
import '../database/storage/account_storage_service_provider.dart';
import '../database/storage/category_storage_service_provider.dart';
import '../database/storage/transaction_storage_service_provider.dart';

final Provider<IExportService> exportServiceProvider = Provider<IExportService>(
  (ProviderRef<IExportService> ref) => ExportService(
    accountStorage: ref.read(accountStorageProvider),
    transactionStorage: ref.read(transactionStorageProvider),
    categoryStorage: ref.read(categoryStorageProvider),
  ),
);

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../contracts/services/secure_storage/i_data_source_storage_service.dart';
import '../../../contracts/services/secure_storage/i_secure_storage_service.dart';
import '../../../services/secure_storage/data_source_storage_service.dart';
import 'secure_storage_provider.dart';

final Provider<IDataSourceStorageService> dataSourceStorageProvider = Provider<IDataSourceStorageService>((ProviderRef<IDataSourceStorageService> ref) {
  final ISecureStorageService storage = ref.read(secureStorageProvider);
  return DataSourceStorageService(storage);
});

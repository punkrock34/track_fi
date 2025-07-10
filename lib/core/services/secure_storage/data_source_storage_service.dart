import '../../contracts/services/secure_storage/i_data_source_storage_service.dart';
import '../../contracts/services/secure_storage/i_secure_storage_service.dart';

class DataSourceStorageService implements IDataSourceStorageService {
  DataSourceStorageService(this._storage);

  final ISecureStorageService _storage;
  static const String _dataSourceKey = 'data_source_choice';

  @override
  Future<void> storeDataSourceChoice(String choice) async {
    await _storage.write(_dataSourceKey, choice);
  }

  @override
  Future<String?> getDataSourceChoice() async {
    return _storage.read(_dataSourceKey);
  }
}

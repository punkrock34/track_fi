abstract class IDataSourceStorageService {
  Future<void> storeDataSourceChoice(String choice);
  Future<String?> getDataSourceChoice();
}

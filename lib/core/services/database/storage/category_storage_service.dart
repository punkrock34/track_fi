import '../../../contracts/services/database/i_database_service.dart';
import '../../../contracts/services/database/storage/i_category_storage_service.dart';

class CategoryStorageService implements ICategoryStorageService {

  CategoryStorageService(this.db);
  final IDatabaseService db;

  @override
  Future<List<Map<String, dynamic>>> getAll() async {
    return db.query('categories');
  }
}

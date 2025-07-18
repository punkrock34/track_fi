import '../../../contracts/services/database/i_database_service.dart';
import '../../../contracts/services/database/storage/i_category_storage_service.dart';

class CategoryStorageService implements ICategoryStorageService {
  CategoryStorageService(this._db);

  final IDatabaseService _db;

  static const String _table = 'categories';

  @override
  Future<List<Map<String, dynamic>>> getAll() =>
      _db.query(_table);
}

import '../../../contracts/services/database/i_database_service.dart';
import '../../../contracts/services/database/storage/i_category_storage_service.dart';
import '../../../models/database/category.dart';

class CategoryStorageService implements ICategoryStorageService {
  CategoryStorageService(this._db);

  final IDatabaseService _db;
  static const String _table = 'categories';

  @override
  Future<List<Category>> getAll() async {
    final List<Map<String, dynamic>> rows = await _db.query(_table);
    return rows.map(Category.fromDb).toList();
  }

  @override
  Future<List<Category>> getByType(String type) async {
    final List<Map<String, dynamic>> rows = await _db.query(
      _table,
      where: 'type = ?',
      whereArgs: <Object?>[type],
    );
    return rows.map(Category.fromDb).toList();
  }

  @override
  Future<void> insert(Category category) async {
    await _db.insert(_table, category.toDb());
  }

  @override
  Future<void> delete(String id) async {
    await _db.delete(_table, where: 'id = ?', whereArgs: <Object?>[id]);
  }
}

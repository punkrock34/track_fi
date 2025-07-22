import '../../../../models/database/category.dart';

abstract class ICategoryStorageService {
  Future<List<Category>> getAll();
  Future<List<Category>> getByType(String type); // income, expense, transfer
  Future<void> insert(Category category);
  Future<void> delete(String id);
}

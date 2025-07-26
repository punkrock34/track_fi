import 'package:sqflite/sqflite.dart';
import '../../../resources/database/defaults/default_categories.dart';
import 'migration.dart';

class MigrationV3 implements Migration {
  const MigrationV3();

  @override
  int get version => 3;

  @override
  Future<void> upgrade(Database db) async {
    await db.delete('categories');
    await DefaultCategories.insert(db);
  }

  @override
  Future<void> downgrade(Database db) {
    throw UnimplementedError();
  }
}

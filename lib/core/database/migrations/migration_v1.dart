import 'package:sqflite/sqflite.dart';

import '../../../resources/database/defaults/default_categories.dart';
import '../../../resources/database/schemas/v1/accounts.dart';
import '../../../resources/database/schemas/v1/categories.dart';
import '../../../resources/database/schemas/v1/sync_status.dart';
import '../../../resources/database/schemas/v1/transactions.dart';
import 'migration.dart';

class MigrationV1 implements Migration {
  const MigrationV1();

  @override
  int get version => 1;

  @override
  Future<void> upgrade(Database db) async {
    await db.execute(AccountsSchemaV1.createTable);
    await db.execute(CategoriesSchemaV1.createTable);
    await db.execute(TransactionsSchemaV1.createTable);
    await db.execute(SyncStatusSchemaV1.createTable);
    await db.execute(TransactionsSchemaV1.createAccountDateIndex);
    await db.execute(TransactionsSchemaV1.createDateIndex);
    await db.execute(AccountsSchemaV1.createActiveIndex);
    await DefaultCategories.insert(db);
  }

  @override
  Future<void> downgrade(Database db) async {
    await db.execute('DROP TABLE IF EXISTS sync_status');
    await db.execute('DROP TABLE IF EXISTS transactions');
    await db.execute('DROP TABLE IF EXISTS categories');
    await db.execute('DROP TABLE IF EXISTS accounts');
  }
}

import 'package:sqflite/sqflite.dart';
import 'migration.dart';

class MigrationV2 implements Migration {
  const MigrationV2();

  @override
  int get version => 2;

  @override
  Future<void> upgrade(Database db) async {
    await db.execute('''
      ALTER TABLE accounts
      ADD COLUMN source TEXT NOT NULL DEFAULT 'manual'
    ''');

    await db.execute('''
      UPDATE accounts
      SET source = 'manual'
      WHERE source IS NULL OR source = ''
    ''');
  }

  @override
  Future<void> downgrade(Database db) async {
    // SQLite doesn't support DROP COLUMN directly.
    // Normally, you'd recreate the table without the column and copy data back.
    // Keeping this empty as a placeholder for now.
    throw UnimplementedError('Downgrade for MigrationV2 is not implemented.');
  }
}

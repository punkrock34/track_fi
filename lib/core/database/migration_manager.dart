import 'package:sqflite/sqflite.dart';
import 'migrations/migration.dart';
import 'migrations/migration_v1.dart';
import 'migrations/migration_v2.dart';
import 'migrations/migration_v3.dart';

class MigrationManager {
  static final List<Migration> _migrations = <Migration>[
    const MigrationV1(),
    const MigrationV2(),
    const MigrationV3(),
  ];

  static Future<void> onCreate(Database db, int version) async {
    for (final Migration m in _migrations) {
      if (m.version <= version) {
        await m.upgrade(db);
      }
    }
  }

  static Future<void> onUpgrade(Database db, int oldVersion, int newVersion) async {
    for (final Migration m in _migrations) {
      if (m.version > oldVersion && m.version <= newVersion) {
        await m.upgrade(db);
      }
    }
  }

  static Future<void> onDowngrade(Database db, int oldVersion, int newVersion) async {
    for (final Migration m in _migrations.reversed) {
      if (m.version <= oldVersion && m.version > newVersion) {
        await m.downgrade(db);
      }
    }
  }

  static int get latestVersion => _migrations.last.version;
}

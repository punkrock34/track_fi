import 'package:sqflite/sqflite.dart';

abstract class Migration {
  int get version;
  Future<void> upgrade(Database db);
  Future<void> downgrade(Database db);
}

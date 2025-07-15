abstract class IDatabaseService {
  Future<void> init();
  Future<void> close();
  Future<void> deleteDatabase();

  Future<List<Map<String, dynamic>>> rawQuery(String sql, [List<Object?>? args]);

  Future<int> insert(String table, Map<String, dynamic> data);
  Future<int> update(String table, Map<String, dynamic> data, {String? where, List<Object?>? whereArgs});
  Future<int> delete(String table, {String? where, List<Object?>? whereArgs});
  Future<List<Map<String, dynamic>>> query(String table, {String? where, List<Object?>? whereArgs, String? orderBy, int? limit});
}

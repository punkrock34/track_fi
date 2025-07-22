class CategoriesSchemaV1 {
  static const String tableName = 'categories';

  static const String createTable = '''
    CREATE TABLE $tableName (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      icon TEXT,
      color TEXT,
      type TEXT NOT NULL CHECK (type IN ('income', 'expense', 'transfer')),
      is_default INTEGER NOT NULL DEFAULT 0,
      created_at TEXT NOT NULL
    )
  ''';
}

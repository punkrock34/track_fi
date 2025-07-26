class AccountsSchemaV1 {
  static const String tableName = 'accounts';

  static const String createTable = '''
    CREATE TABLE $tableName (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      type TEXT NOT NULL,
      balance REAL NOT NULL DEFAULT 0.0,
      currency TEXT NOT NULL DEFAULT 'GBP',
      bank_name TEXT,
      account_number TEXT,
      sort_code TEXT,
      is_active INTEGER NOT NULL DEFAULT 1,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL,
      last_synced_at TEXT
    )
  ''';

  static const String createActiveIndex = '''
    CREATE INDEX idx_accounts_active ON $tableName(is_active)
  ''';
}

class TransactionsSchemaV1 {
  static const String tableName = 'transactions';

  static const String createTable = '''
    CREATE TABLE $tableName (
      id TEXT PRIMARY KEY,
      account_id TEXT NOT NULL,
      category_id TEXT,
      amount REAL NOT NULL,
      description TEXT NOT NULL,
      reference TEXT,
      transaction_date TEXT NOT NULL,
      balance_after REAL,
      type TEXT NOT NULL CHECK (type IN ('debit', 'credit')),
      status TEXT NOT NULL DEFAULT 'completed',
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL,
      synced_at TEXT,
      FOREIGN KEY (account_id) REFERENCES accounts (id) ON DELETE CASCADE,
      FOREIGN KEY (category_id) REFERENCES categories (id)
    )
  ''';

  static const String createAccountDateIndex = '''
    CREATE INDEX idx_transactions_account_date ON $tableName(account_id, transaction_date)
  ''';

  static const String createDateIndex = '''
    CREATE INDEX idx_transactions_date ON $tableName(transaction_date)
  ''';
}

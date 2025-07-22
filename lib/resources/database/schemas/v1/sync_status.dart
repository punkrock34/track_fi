class SyncStatusSchemaV1 {
  static const String tableName = 'sync_status';

  static const String createTable = '''
    CREATE TABLE $tableName (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      last_sync_attempt TEXT NOT NULL,
      last_successful_sync TEXT,
      sync_status TEXT NOT NULL CHECK (sync_status IN ('success', 'failed', 'in_progress')),
      error_message TEXT,
      records_synced INTEGER DEFAULT 0
    )
  ''';
}

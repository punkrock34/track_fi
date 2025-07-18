import '../../../contracts/services/database/i_database_service.dart';
import '../../../contracts/services/database/storage/i_sync_status_storage_service.dart';

class SyncStatusStorageService implements ISyncStatusStorageService {
  SyncStatusStorageService(this._db);

  final IDatabaseService _db;

  static const String _table = 'sync_status';

  @override
  Future<void> updateStatus(
    String status, {
    String? errorMessage,
    int? recordsSynced,
  }) {
    final String now = DateTime.now().toIso8601String();

    return _db.insert(_table, <String, dynamic>{
      'last_sync_attempt': now,
      'last_successful_sync': status == 'success' ? now : null,
      'sync_status': status,
      'error_message': errorMessage,
      'records_synced': recordsSynced ?? 0,
    });
  }

  @override
  Future<Map<String, dynamic>?> getLatest() async {
    final List<Map<String, dynamic>> result = await _db.query(
      _table,
      orderBy: 'id DESC',
      limit: 1,
    );

    return result.isEmpty ? null : result.first;
  }
}

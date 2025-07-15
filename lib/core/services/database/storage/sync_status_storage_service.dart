import '../../../contracts/services/database/i_database_service.dart';
import '../../../contracts/services/database/storage/i_sync_status_storage_service.dart';

class SyncStatusStorageService implements ISyncStatusStorageService {

  SyncStatusStorageService(this.db);
  final IDatabaseService db;

  @override
  Future<void> updateStatus(
    String status, {
    String? errorMessage,
    int? recordsSynced,
  }) async {
    await db.insert('sync_status', <String, Object?>{
      'last_sync_attempt': DateTime.now().toIso8601String(),
      'last_successful_sync':
          status == 'success' ? DateTime.now().toIso8601String() : null,
      'sync_status': status,
      'error_message': errorMessage,
      'records_synced': recordsSynced ?? 0,
    });
  }

  @override
  Future<Map<String, dynamic>?> getLatest() async {
    final List<Map<String, dynamic>> result = await db.query(
      'sync_status',
      orderBy: 'id DESC',
      limit: 1,
    );

    return result.isEmpty ? null : result.first;
  }
}

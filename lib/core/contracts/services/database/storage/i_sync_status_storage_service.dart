abstract class ISyncStatusStorageService {
  Future<void> updateStatus(
    String status, {
    String? errorMessage,
    int? recordsSynced,
  });

  Future<Map<String, dynamic>?> getLatest();
}

import 'package:flutter/material.dart' hide DateUtils;

import '../../features/dashboard/models/sync_state.dart';
import 'date_utils.dart';

class SyncUtils {
  SyncUtils._();

  /// Get sync state from sync status data
  static SyncState getSyncState(Map<String, dynamic>? syncStatus) {
    if (syncStatus == null) {
      return const SyncState(
        label: 'Never synced',
        icon: Icons.sync_disabled,
        color: Colors.grey,
      );
    }

    final String status = syncStatus['sync_status'] as String? ?? 'unknown';
    final DateTime? lastSync = syncStatus['last_successful_sync'] != null
        ? DateTime.tryParse(syncStatus['last_successful_sync'] as String)
        : null;

    switch (status) {
      case 'success':
        final String timeAgo = lastSync != null ? DateUtils.getTimeAgoForSync(lastSync) : 'unknown';
        return SyncState(
          label: 'Synced $timeAgo',
          icon: Icons.check_circle,
          color: Colors.green,
        );
      case 'failed':
        return const SyncState(
          label: 'Sync failed',
          icon: Icons.error,
          color: Colors.red,
        );
      case 'in_progress':
        return const SyncState(
          label: 'Syncing...',
          icon: Icons.sync,
          color: Colors.blue,
        );
      default:
        return const SyncState(
          label: 'Unknown',
          icon: Icons.help,
          color: Colors.grey,
        );
    }
  }
}

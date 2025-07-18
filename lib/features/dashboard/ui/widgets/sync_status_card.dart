import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../core/theme/design_tokens/design_tokens.dart';
import '../../models/sync_state.dart';

class SyncStatusCard extends StatelessWidget {
  const SyncStatusCard({
    super.key,
    this.syncStatus,
    this.lastRefresh,
  });

  final Map<String, dynamic>? syncStatus;
  final DateTime? lastRefresh;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final SyncState state = _getSyncState();
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.spacingXs,
        vertical: DesignTokens.spacing2xs,
      ),
      decoration: BoxDecoration(
        color: state.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
        border: Border.all(
          color: state.color.withOpacity(0.3),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            state.icon,
            size: 14,
            color: state.color,
          ),
          const Gap(DesignTokens.spacing2xs),
          Text(
            state.label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: state.color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  SyncState _getSyncState() {
    if (syncStatus == null) {
      return const SyncState(
        label: 'Never synced',
        icon: Icons.sync_disabled,
        color: Colors.grey,
      );
    }

    final String status = syncStatus!['sync_status'] as String? ?? 'unknown';
    final DateTime? lastSync = syncStatus!['last_successful_sync'] != null
        ? DateTime.tryParse(syncStatus!['last_successful_sync'] as String)
        : null;

    switch (status) {
      case 'success':
        final String timeAgo = lastSync != null ? _getTimeAgo(lastSync) : 'unknown';
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

  String _getTimeAgo(DateTime dateTime) {
    final Duration difference = DateTime.now().difference(dateTime);
    
    if (difference.inMinutes < 1) {
      return 'now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../core/theme/design_tokens/design_tokens.dart';
import '../../../../shared/utils/sync_utils.dart';
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
    final SyncState state = SyncUtils.getSyncState(syncStatus);
    
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
}

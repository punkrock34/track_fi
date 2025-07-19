import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../core/theme/design_tokens/design_tokens.dart';
import '../../utils/ui_utils.dart';

class DetailRow extends StatelessWidget {
  const DetailRow({
    super.key,
    required this.label,
    required this.value,
    this.showDivider = true,
    this.isMonetary = false,
    this.isCopyable = false,
    this.isMonospace = false,
    this.valueColor,
    this.onTap,
    this.icon,
  });

  final String label;
  final String value;
  final bool showDivider;
  final bool isMonetary;
  final bool isCopyable;
  final bool isMonospace;
  final Color? valueColor;
  final VoidCallback? onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    
    return Column(
      children: <Widget>[
        InkWell(
          onTap: onTap ?? (isCopyable ? () => _copyValue(context) : null),
          borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                Flexible(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      if (icon != null) ...<Widget>[
                        Icon(
                          icon,
                          size: 16,
                          color: theme.colorScheme.primary,
                        ),
                        const Gap(DesignTokens.spacing2xs),
                      ],
                      Flexible(
                        child: Text(
                          value,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: isMonetary ? FontWeight.w600 : FontWeight.w500,
                            color: valueColor ?? theme.colorScheme.onSurface,
                            fontFamily: isMonospace ? 'monospace' : null,
                            fontFeatures: isMonetary ? const <FontFeature>[FontFeature.tabularFigures()] : null,
                          ),
                          textAlign: TextAlign.end,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isCopyable || onTap != null) ...<Widget>[
                        const Gap(DesignTokens.spacing2xs),
                        Icon(
                          isCopyable ? Icons.copy_rounded : Icons.chevron_right_rounded,
                          size: 16,
                          color: theme.colorScheme.onSurface.withOpacity(0.4),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (showDivider) ...<Widget>[
          const Gap(DesignTokens.spacingSm),
          const Divider(height: 1),
          const Gap(DesignTokens.spacingSm),
        ],
      ],
    );
  }

  void _copyValue(BuildContext context) {
    UiUtils.copyToClipboard(context, value);
  }
}

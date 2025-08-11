import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../core/theme/design_tokens/design_tokens.dart';

class SettingsGroup extends StatelessWidget {
  const SettingsGroup({
    super.key,
    required this.title,
    required this.children,
    this.isDangerZone = false,
  });

  final String title;
  final List<Widget> children;
  final bool isDangerZone;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spacingXs),
          child: Text(
            title.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              color: isDangerZone 
                  ? theme.colorScheme.error.withOpacity(0.8)
                  : theme.colorScheme.primary.withOpacity(0.8),
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
        ),
        const Gap(DesignTokens.spacingSm),
        Card(
          margin: EdgeInsets.zero,
          elevation: 2,
          shadowColor: isDangerZone
              ? theme.colorScheme.error.withOpacity(0.1)
              : theme.colorScheme.shadow.withOpacity(0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
            side: isDangerZone
                ? BorderSide(
                    color: theme.colorScheme.error.withOpacity(0.3),
                  )
                : BorderSide.none,
          ),
          color: isDangerZone
              ? theme.colorScheme.errorContainer.withOpacity(0.05)
              : null,
          child: Column(
            children: children.asMap().entries.map((MapEntry<int, Widget> entry) {
              final int index = entry.key;
              final Widget child = entry.value;
              
              return Column(
                children: <Widget>[
                  child,
                  if (index < children.length - 1)
                    Divider(
                      height: 1,
                      indent: DesignTokens.spacingXl,
                      endIndent: DesignTokens.spacingSm,
                      color: isDangerZone
                          ? theme.colorScheme.error.withOpacity(0.2)
                          : theme.colorScheme.outline.withOpacity(0.2),
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

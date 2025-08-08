import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../core/theme/design_tokens/design_tokens.dart';

class SettingsGroup extends StatelessWidget {
  const SettingsGroup({
    super.key,
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

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
              color: theme.colorScheme.primary.withOpacity(0.8),
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
        ),
        const Gap(DesignTokens.spacingSm),
        Card(
          margin: EdgeInsets.zero,
          elevation: 2,
          shadowColor: theme.colorScheme.shadow.withOpacity(0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
          ),
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
                      color: theme.colorScheme.outline.withOpacity(0.2),
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

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
              color: theme.colorScheme.onSurface.withOpacity(0.6),
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
        const Gap(DesignTokens.spacingXs),
        Card(
          margin: EdgeInsets.zero,
          child: Column(
            children: children.asMap().entries.map((MapEntry<int, Widget> entry) {
              final int index = entry.key;
              final Widget child = entry.value;
              
              return Column(
                children: <Widget>[
                  child,
                  if (index < children.length - 1)
                    const Divider(
                      height: 1,
                      indent: DesignTokens.spacingLg,
                      endIndent: DesignTokens.spacingSm,
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

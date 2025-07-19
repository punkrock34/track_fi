import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../core/theme/design_tokens/design_tokens.dart';

class LoadingState extends StatelessWidget {
  const LoadingState({
    super.key,
    this.message = 'Loading...',
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          CircularProgressIndicator(
            color: theme.colorScheme.primary,
          ),
          const Gap(DesignTokens.spacingMd),
          Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}

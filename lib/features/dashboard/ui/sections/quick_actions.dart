import 'package:flutter/material.dart';
import 'package:trackfi/app/theme/theme_extensions.dart';

class QuickActions extends StatelessWidget {
  const QuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Actions',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildAction(context, Icons.add, 'Add Account', theme.colorScheme.primary),
            _buildAction(context, Icons.sync, 'Sync Data', theme.colorScheme.secondary),
            _buildAction(context, Icons.insights, 'Analytics',
                theme.colorScheme.primary.withAlpha((0.7 * 255).round())),
          ],
        ),
      ],
    );
  }

  Widget _buildAction(BuildContext context, IconData icon, String label, Color color) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withAlpha((0.15 * 255).round()),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(label,
            style: TextStyle(fontSize: 12, color: theme.textSubtle)),
      ],
    );
  }
}

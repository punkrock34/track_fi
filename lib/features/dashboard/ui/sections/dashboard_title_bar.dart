import 'package:flutter/material.dart';

class DashboardTitleBar extends StatelessWidget {
  const DashboardTitleBar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Text(
          'TrackFi',
          style: theme.textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        CircleAvatar(
          radius: 18,
          backgroundColor: Colors.white.withAlpha((0.2 * 255).round()),
          child: IconButton(
            icon: const Icon(Icons.person, color: Colors.white, size: 20),
            onPressed: () {},
          ),
        ),
      ],
    );
  }
}

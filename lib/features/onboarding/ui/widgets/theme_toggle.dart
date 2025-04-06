import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trackfi/core/services/theme_controller.dart';

class ThemeToggle extends StatelessWidget {
  const ThemeToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = context.watch<ThemeController>();
    final isDark = themeController.mode == ThemeMode.dark ||
        (themeController.mode == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Dark Mode',
            style: TextStyle(
              color: Colors.white.withAlpha((0.8 * 255).round()),
            ),
          ),
          Switch(
            value: isDark,
            onChanged: (_) => themeController.toggle(),
            activeColor: Colors.white,
            inactiveTrackColor: Colors.white.withAlpha((0.3 * 255).round()),
          ),
        ],
      ),
    );
  }
}

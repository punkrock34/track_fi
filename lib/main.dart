import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trackfi/app/trackfi_app.dart';
import 'package:trackfi/core/services/theme_controller.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeController(),
      child: const TrackFiRoot(),
    ),
  );
}

class TrackFiRoot extends StatelessWidget {
  const TrackFiRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeController>(
      builder: (_, controller, __) {
        return TrackFiApp(themeMode: controller.mode);
      },
    );
  }
}

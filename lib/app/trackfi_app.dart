import 'package:flutter/material.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

final class TrackFiApp extends StatelessWidget {
  final ThemeMode themeMode;

  const TrackFiApp({super.key, required this.themeMode});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'TrackFi',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: AppRouter.config,
      debugShowCheckedModeBanner: false,
    );
  }
}

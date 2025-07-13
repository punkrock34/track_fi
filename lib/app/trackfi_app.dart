import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/providers/session/session_provider.dart';
import '../core/providers/theme/theme_provider.dart';
import '../core/router/app_router.dart';
import '../core/theme/app_theme.dart';

class TrackFiApp extends ConsumerWidget {
  const TrackFiApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GoRouter router = ref.watch(appRouterProvider);
    final ThemeMode themeMode = ref.watch(themeProvider);
    final bool isDark = ref.watch(isDarkModeProvider);

    SystemChrome.setSystemUIOverlayStyle(
      isDark
          ? AppTheme.darkSystemUiOverlayStyle
          : AppTheme.lightSystemUiOverlayStyle,
    );

    return GestureDetector(
      onTap: () => ref.read(sessionProvider.notifier).updateActivity(),
      onPanDown: (_) => ref.read(sessionProvider.notifier).updateActivity(),
      child: MaterialApp.router(
        title: 'TrackFi',
        debugShowCheckedModeBanner: false,
        
        // Theme configuration
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: themeMode,
        
        // Router configuration
        routerConfig: router,
        
        // Builder for additional configurations
        builder: (BuildContext context, Widget? child) {
          return child ?? const SizedBox.shrink();
        },
      ),
    );
  }
}

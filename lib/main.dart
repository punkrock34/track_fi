import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'app/trackfi_app.dart';
import 'core/config/app_config.dart';
import 'core/logging/log.dart';

Future<void> main() async {
  SentryWidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  try {
    await dotenv.load(fileName: 'lib/core/config/.env.ini');
  } catch (e, stackTrace) {
    log(
      message: 'Failed to load environment variables',
      error: e,
      stackTrace: stackTrace,
    );
  }

  await SentryFlutter.init(
    (SentryFlutterOptions options) {
      options.dsn = AppConfig.sentryDsn;
      options.environment = AppConfig.isProduction ? 'production' : 'development';
      options.tracesSampleRate = kDebugMode ? 0.1 : 1.0;
      options.sendDefaultPii = false;
      options.debug = kDebugMode;
      
      if (kDebugMode) {
        options.enableAutoSessionTracking = false;
        options.enableWatchdogTerminationTracking = false;
      }
    },
    appRunner: () => runApp(
      const ProviderScope(
        child: TrackFiApp(),
      ),
    ),
  );
}

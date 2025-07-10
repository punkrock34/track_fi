import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'app/trackfi_app.dart';
import 'core/config/app_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await dotenv.load(fileName: 'lib/core/config/.env.ini');

  await SentryFlutter.init(
    (SentryFlutterOptions options) {
      options.dsn = AppConfig.sentryDsn;
      options.environment = AppConfig.isProduction ? 'production' : 'development';
      options.tracesSampleRate = 1.0;
      options.sendDefaultPii = true;
    },
    appRunner: () => runApp(
      ProviderScope(
        child: SentryWidget(
          child: const TrackFiApp(),
        ),
      ),
    ),
  );
}

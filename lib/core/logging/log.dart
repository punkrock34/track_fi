import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../config/app_config.dart';

Future<void> log({
  Object? message,
  Object? error,
  StackTrace? stackTrace,
}) async {
  if (!AppConfig.isProduction) {
    final StringBuffer output = StringBuffer();

    if (message != null) {
      output.writeln('[LOG] $message');
    }
    if (error != null) {
      output.writeln('[ERROR] $error');
    }
    if (stackTrace != null) {
      output.writeln('[STACKTRACE]\n$stackTrace');
    }

    if (output.isNotEmpty) {
      debugPrint(output.toString());
    }
  }

  if (error != null) {
    await Sentry.captureException(error, stackTrace: stackTrace);
  }
}

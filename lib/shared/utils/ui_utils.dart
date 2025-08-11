import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class UiUtils {
  UiUtils._();

  static bool _loadingVisible = false;

  static void showComingSoon(BuildContext context, String feature) {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);

    messenger.hideCurrentSnackBar();

    messenger.showSnackBar(
      SnackBar(
        content: Text('$feature coming soon!'),
        action: SnackBarAction(
          label: 'OK',
          onPressed: () => messenger.hideCurrentSnackBar(),
        ),
      ),
    );
  }

  static void showSuccess(BuildContext context, String message) {
    if (!context.mounted) {
      return;
    }

    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);

    messenger.hideCurrentSnackBar();

    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: <Widget>[
            const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  static void showError(BuildContext context, String message) {
    if (!context.mounted) {
      return;
    }

    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);

    messenger.hideCurrentSnackBar();

    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: <Widget>[
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static void copyToClipboard(BuildContext context, String text, {String? confirmationMessage}) {
    Clipboard.setData(ClipboardData(text: text));

    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);

    messenger.hideCurrentSnackBar();

    messenger.showSnackBar(
      SnackBar(
        content: Text(confirmationMessage ?? 'Copied to clipboard'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  static Future<bool?> showConfirmationDialog(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool isDestructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context, rootNavigator: true).pop(false),
              child: Text(cancelText),
            ),
            TextButton(
              onPressed: () => Navigator.of(context, rootNavigator: true).pop(true),
              style: isDestructive
                  ? TextButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.error,
                    )
                  : null,
              child: Text(confirmText),
            ),
          ],
        );
      },
    );
  }

  static void showLoadingDialog(
    BuildContext context, {
    String message = 'Loading...',
    bool barrierDismissible = false,
  }) {
    if (!context.mounted) {
      return;
    }

    if (_loadingVisible) {
      return;
    }

    _loadingVisible = true;

    showDialog<void>(
      context: context,
      barrierDismissible: barrierDismissible,
      routeSettings: const RouteSettings(name: '__loading_dialog__'),
      builder: (BuildContext dialogContext) => PopScope(
        canPop: barrierDismissible,
        child: AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              CircularProgressIndicator(color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 20),
              Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    ).then((_) {
      _loadingVisible = false;
    });
  }

  static void hideDialog(BuildContext context) {
    if (!context.mounted) {
      return;
    }

    if (!_loadingVisible) {
      return;
    }

    try {
      Navigator.of(context, rootNavigator: true).pop();
    } catch (_) {}

    _loadingVisible = false;
  }

  static Future<T?> showLoadingDialogWithFuture<T>(
    BuildContext context,
    Future<T> future, {
    String message = 'Loading...',
    String? successMessage,
    String? errorMessage,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    if (!context.mounted) {
      return null;
    }

    showLoadingDialog(context, message: message);

    try {
      final T result = await future.timeout(timeout);

      if (context.mounted) {
        hideDialog(context);

        if (successMessage != null) {
          showSuccess(context, successMessage);
        }
      }

      return result;
    } on TimeoutException {
      if (context.mounted) {
        hideDialog(context);
        showError(context, 'Operation timed out. Please try again.');
      }

      return null;
    } catch (_) {
      if (context.mounted) {
        hideDialog(context);
        showError(context, errorMessage ?? 'An error occurred. Please try again.');
      }

      return null;
    }
  }

  static void showTimedLoadingDialog(
    BuildContext context, {
    String message = 'Loading...',
    Duration maxDuration = const Duration(seconds: 30),
  }) {
    if (!context.mounted) {
      return;
    }

    showLoadingDialog(context, message: message);

    Future<void>.delayed(maxDuration, () {
      if (context.mounted) {
        try {
          hideDialog(context);
          showError(context, 'Operation is taking longer than expected. Please try again.');
        } catch (_) {}
      }
    });
  }

  static String formatAccountType(String type) {
    return type
        .split('_')
        .map((String word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

  static String getThemeDescription(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return 'Light mode';
      case ThemeMode.dark:
        return 'Dark mode';
      case ThemeMode.system:
        return 'System default';
    }
  }

  static void showDetailedError(
    BuildContext context,
    String title,
    String message, {
    String? details,
    VoidCallback? onRetry,
  }) {
    if (!context.mounted) {
      return;
    }

    showDialog<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Row(
          children: <Widget>[
            Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error, size: 24),
            const SizedBox(width: 8),
            Expanded(child: Text(title)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(message),
            if (details != null) ...<Widget>[
              const SizedBox(height: 16),
              Text(
                'Details:',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  details,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(fontFamily: 'monospace'),
                ),
              ),
            ],
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
            child: const Text('Close'),
          ),
          if (onRetry != null)
            ElevatedButton(
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop();
                onRetry();
              },
              child: const Text('Retry'),
            ),
        ],
      ),
    );
  }

  static bool isDialogShowing(BuildContext context) {
    return _loadingVisible;
  }

  static void safeDismissDialog(BuildContext context) {
    if (!context.mounted) {
      return;
    }

    try {
      Navigator.of(context, rootNavigator: true).maybePop();
    } catch (_) {}

    _loadingVisible = false;
  }
}

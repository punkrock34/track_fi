import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class UiUtils {
  UiUtils._();

  /// Show a "coming soon" snackbar
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

  /// Show a success snackbar
  static void showSuccess(BuildContext context, String message) {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Show an error snackbar
  static void showError(BuildContext context, String message) {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Copy text to clipboard and show confirmation
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

  /// Show a generic confirmation dialog
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
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(cancelText),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
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

  /// Show a loading dialog
  static void showLoadingDialog(
    BuildContext context, {
    String message = 'Loading...',
    bool barrierDismissible = false,
  }) {
    showDialog<void>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (BuildContext context) => PopScope(
        canPop: barrierDismissible,
        child: AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Hide the currently showing dialog
  static void hideDialog(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  /// Show loading dialog with automatic error handling
  static Future<T?> showLoadingDialogWithFuture<T>(
    BuildContext context,
    Future<T> future, {
    String message = 'Loading...',
    String? successMessage,
    String? errorMessage,
  }) async {
    showLoadingDialog(context, message: message);

    try {
      final T result = await future;
      
      if (context.mounted) {
        hideDialog(context);
        if (successMessage != null) {
          showSuccess(context, successMessage);
        }
      }
      
      return result;
    } catch (e) {
      if (context.mounted) {
        hideDialog(context);
        showError(context, errorMessage ?? 'An error occurred. Please try again.');
      }
      return null;
    }
  }

  /// Format account type for display
  static String formatAccountType(String type) {
    return type.split('_').map((String word) =>
        word[0].toUpperCase() + word.substring(1).toLowerCase()).join(' ');
  }

  /// Get theme mode description
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
}

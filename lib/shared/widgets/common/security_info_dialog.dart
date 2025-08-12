import 'package:flutter/material.dart';

class SecurityInfoDialog {
  SecurityInfoDialog._();

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Security Features'),
          content: const SingleChildScrollView(
            child: Text(
              'Local Data Storage\n'
              'All your financial data is stored locally on your device using encrypted SQLite databases. '
              'No data is transmitted to external servers or cloud services.\n\n'
              
              'Database Encryption\n'
              'Your transaction and account data is protected using SQLite encryption with '
              'configurable encryption keys stored in secure storage.\n\n'
              
              'PIN Security\n'
              'Your PIN is never stored in plain text. It is hashed using SHA-256 with '
              'a cryptographic salt, making it computationally infeasible to reverse.\n\n'
              
              'Biometric Integration\n'
              "When enabled, biometric authentication uses your device's secure hardware "
              'and never stores biometric data within the app.\n\n'
              
              'Secure Key Storage\n'
              'Sensitive configuration data is stored using platform-specific secure storage: '
              'iOS Keychain and Android EncryptedSharedPreferences.\n\n'
              
              'Authentication Controls\n'
              'The app implements progressive lockout after failed PIN attempts and '
              'automatic session timeout after 5 minutes of inactivity.\n\n'
              
              'Development Security\n'
              'The app follows secure coding practices including input validation, '
              'proper error handling, and separation of concerns through clean architecture.',
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Got it'),
            ),
          ],
        );
      },
    );
  }
}

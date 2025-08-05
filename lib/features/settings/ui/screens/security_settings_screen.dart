import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../../core/theme/design_tokens/design_tokens.dart';
import '../../models/settings_state.dart';
import '../../providers/settings_providers.dart';
import '../widgets/pin_change_modal.dart';
import '../widgets/settings_group.dart';
import '../widgets/settings_item.dart';

class SecuritySettingsScreen extends ConsumerWidget {
  const SecuritySettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final SettingsState settingsState = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Security Settings'),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(DesignTokens.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // PIN Settings
            SettingsGroup(
              title: 'PIN Authentication',
              children: <Widget>[
                SettingsItem(
                  title: 'Change PIN',
                  subtitle: 'Update your security PIN',
                  icon: Icons.pin_rounded,
                  onTap: () => _showPinChangeModal(context),
                  showTrailing: true,
                ).animate().slideX(begin: 0.3, delay: 100.ms).fadeIn(),
              ],
            ),

            const Gap(DesignTokens.spacingLg),

            // Biometric Settings
            SettingsGroup(
              title: 'Biometric Authentication',
              children: <Widget>[
                SettingsItem(
                  title: 'Enable Biometric Login',
                  subtitle: settingsState.biometricEnabled
                      ? 'Enabled - Use fingerprint/face to login'
                      : 'Disabled - Only PIN authentication',
                  icon: Icons.fingerprint_rounded,
                  trailing: Switch(
                    value: settingsState.biometricEnabled,
                    onChanged: settingsState.isLoading
                        ? null
                        : (bool value) => _toggleBiometric(context, ref, value),
                  ),
                ).animate().slideX(begin: 0.3, delay: 150.ms).fadeIn(),
              ],
            ),

            const Gap(DesignTokens.spacingLg),

            // Advanced Security
            SettingsGroup(
              title: 'Advanced',
              children: <Widget>[
                SettingsItem(
                  title: 'Security Information',
                  subtitle: 'Learn about app security features',
                  icon: Icons.info_outline_rounded,
                  onTap: () => _showSecurityInfoDialog(context),
                  showTrailing: true,
                ).animate().slideX(begin: 0.3, delay: 200.ms).fadeIn(),
              ],
            ),

            const Gap(DesignTokens.spacingXl),

            // Warning Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(DesignTokens.spacingMd),
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer.withOpacity(0.1),
                borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                border: Border.all(
                  color: theme.colorScheme.error.withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Icon(
                        Icons.security_rounded,
                        color: theme.colorScheme.error,
                        size: 20,
                      ),
                      const Gap(DesignTokens.spacingXs),
                      Text(
                        'Security Notice',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const Gap(DesignTokens.spacingXs),
                  Text(
                    'Your financial data is stored securely on your device with '
                    'bank-grade encryption. Never share your PIN with anyone.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onErrorContainer,
                    ),
                  ),
                ],
              ),
            ).animate().slideY(begin: 0.3, delay: 250.ms).fadeIn(),
          ],
        ),
      ),
    );
  }

  Future<void> _showPinChangeModal(BuildContext context) async {
    final bool success = (await showPinChangeModal(context)) ?? false;
    
    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('PIN changed successfully!'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _toggleBiometric(BuildContext context, WidgetRef ref, bool enabled) async {
    final bool success = await ref.read(settingsProvider.notifier).setBiometricEnabled(enabled);
    
    if (!success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(enabled 
              ? 'Failed to enable biometric authentication. Please check your device settings.'
              : 'Failed to disable biometric authentication.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } else if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(enabled 
              ? 'Biometric authentication enabled successfully!'
              : 'Biometric authentication disabled.'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    }
  }

  void _showSecurityInfoDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Security Features'),
          content: const SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
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
              ],
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

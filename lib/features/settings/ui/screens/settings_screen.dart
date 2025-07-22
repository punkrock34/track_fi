import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../../../core/providers/theme/theme_provider.dart';
import '../../../../../core/theme/design_tokens/design_tokens.dart';
import '../../../../../shared/utils/ui_utils.dart';
import '../../../../../shared/widgets/navigation/swipe_navigation_wrapper.dart';
import '../../../../../shared/widgets/theme/theme_toggle.dart';
import '../../../../shared/models/theme_enums.dart';
import '../../models/settings_state.dart';
import '../../providers/settings_providers.dart';
import '../widgets/settings_group.dart';
import '../widgets/settings_item.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    _loadAppInfo();
  }

  Future<void> _loadAppInfo() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = '${packageInfo.version} (${packageInfo.buildNumber})';
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final SettingsState settingsState = ref.watch(settingsProvider);

    return SwipeNavigationWrapper(
      currentRoute: '/settings',
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
          backgroundColor: theme.colorScheme.surface,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(DesignTokens.spacingMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Security Settings
              SettingsGroup(
                title: 'Security',
                children: <Widget>[
                  SettingsItem(
                    title: 'Security Settings',
                    subtitle: 'PIN, biometrics, and authentication',
                    icon: Icons.security_rounded,
                    onTap: () => context.go('/settings/security'),
                    showTrailing: true,
                  ).animate().slideX(begin: 0.3, delay: 100.ms).fadeIn(),
                  
                  SettingsItem(
                    title: 'Biometric Authentication',
                    subtitle: settingsState.biometricEnabled
                        ? 'Enabled' 
                        : 'Disabled',
                    icon: Icons.fingerprint_rounded,
                    trailing: Switch(
                      value: settingsState.biometricEnabled,
                      onChanged: settingsState.isLoading
                          ? null 
                          : (bool value) => _toggleBiometric(value),
                    ),
                  ).animate().slideX(begin: 0.3, delay: 150.ms).fadeIn(),
                ],
              ),

              const Gap(DesignTokens.spacingLg),

              // Appearance Settings
              SettingsGroup(
                title: 'Appearance',
                children: <Widget>[
                  SettingsItem(
                    title: 'Theme',
                    subtitle: UiUtils.getThemeDescription(ref.watch(themeProvider)),
                    icon: Icons.palette_rounded,
                    trailing: const ThemeToggle(
                      showLabel: false,
                      size: ThemeToggleSize.small,
                    ),
                  ).animate().slideX(begin: 0.3, delay: 200.ms).fadeIn(),
                ],
              ),

              const Gap(DesignTokens.spacingLg),

              // Data Settings
              SettingsGroup(
                title: 'Data',
                children: <Widget>[
                  SettingsItem(
                    title: 'Export Data',
                    subtitle: 'Download your financial data',
                    icon: Icons.download_rounded,
                    onTap: () => UiUtils.showComingSoon(context, 'Export Data'),
                    showTrailing: true,
                  ).animate().slideX(begin: 0.3, delay: 250.ms).fadeIn(),
                ],
              ),

              const Gap(DesignTokens.spacingLg),

              // Support Settings
              SettingsGroup(
                title: 'Support',
                children: <Widget>[
                  SettingsItem(
                    title: 'Help & FAQ',
                    subtitle: 'Get help with TrackFi',
                    icon: Icons.help_outline_rounded,
                    onTap: () => UiUtils.showComingSoon(context, 'Help & FAQ'),
                    showTrailing: true,
                  ).animate().slideX(begin: 0.3, delay: 350.ms).fadeIn(),
                  
                  SettingsItem(
                    title: 'Contact Support',
                    subtitle: 'Get in touch with our team',
                    icon: Icons.contact_support_rounded,
                    onTap: () => UiUtils.showComingSoon(context, 'Contact Support'),
                    showTrailing: true,
                  ).animate().slideX(begin: 0.3, delay: 400.ms).fadeIn(),
                  
                  SettingsItem(
                    title: 'Privacy Policy',
                    subtitle: 'Learn how we protect your data',
                    icon: Icons.privacy_tip_rounded,
                    onTap: () => UiUtils.showComingSoon(context, 'Privacy Policy'),
                    showTrailing: true,
                  ).animate().slideX(begin: 0.3, delay: 450.ms).fadeIn(),
                ],
              ),

              const Gap(DesignTokens.spacingLg),

              // About
              SettingsGroup(
                title: 'About',
                children: <Widget>[
                  SettingsItem(
                    title: 'Version',
                    subtitle: _appVersion.isNotEmpty ? _appVersion : 'Loading...',
                    icon: Icons.info_outline_rounded,
                  ).animate().slideX(begin: 0.3, delay: 500.ms).fadeIn(),
                ],
              ),

              const Gap(DesignTokens.spacingMd),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _toggleBiometric(bool enabled) async {
    final bool success = await ref.read(settingsProvider.notifier).setBiometricEnabled(enabled);
    
    if (!success && mounted) {
      UiUtils.showError(
        context,
        enabled
            ? 'Failed to enable biometric authentication'
            : 'Failed to disable biometric authentication',
      );
    }
  }
}

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
import '../../../../core/providers/auth/auth_service_provider.dart';
import '../../../../core/providers/session/session_provider.dart';
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

    return SwipeNavigationWrapper(
      currentRoute: 'settings',
      child: Scaffold(
        body: CustomScrollView(
          slivers: <Widget>[
            // Custom App Bar matching Dashboard style
            SliverAppBar(
              expandedHeight: 140,
              floating: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: <Color>[
                        theme.colorScheme.primaryContainer.withOpacity(0.1),
                        theme.colorScheme.secondaryContainer.withOpacity(0.05),
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(DesignTokens.spacingMd),
                      child: Column(
                        children: <Widget>[
                          // Top Header Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              // App Title
                              Row(
                                children: <Widget>[
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: <Color>[
                                          theme.colorScheme.primary,
                                          theme.colorScheme.secondary,
                                        ],
                                      ),
                                      borderRadius:
                                          BorderRadius.circular(DesignTokens.radiusMd),
                                    ),
                                    child: Icon(
                                      Icons.settings_rounded,
                                      color: theme.colorScheme.onPrimary,
                                      size: 24,
                                    ),
                                  ),
                                  const Gap(DesignTokens.spacingSm),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        'Settings',
                                        style: theme.textTheme.titleLarge?.copyWith(
                                          fontWeight: FontWeight.w800,
                                          color: theme.colorScheme.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ).animate().slideX(begin: -0.3, delay: 100.ms).fadeIn(),

                              // Action Buttons
                              Row(
                                children: <Widget>[
                                  Container(
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.surfaceVariant
                                          .withOpacity(0.5),
                                      borderRadius:
                                          BorderRadius.circular(DesignTokens.radiusMd),
                                    ),
                                    child: IconButton(
                                      icon: const Icon(Icons.info_outline_rounded),
                                      onPressed: () => _showAppInfo(context),
                                      tooltip: 'App Info',
                                    ),
                                  ),
                                ],
                              ).animate().slideX(begin: 0.3, delay: 150.ms).fadeIn(),
                            ],
                          ),

                          const Gap(DesignTokens.spacingSm),

                          // Settings Summary Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                'Customize your TrackFi experience',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                                ),
                              ).animate().slideX(begin: -0.3, delay: 200.ms).fadeIn(),

                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: DesignTokens.spacingXs,
                                  vertical: DesignTokens.spacing2xs,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                                  border: Border.all(
                                    color: theme.colorScheme.primary.withOpacity(0.3),
                                    width: 0.5,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Icon(
                                      Icons.tune,
                                      size: 14,
                                      color: theme.colorScheme.primary,
                                    ),
                                    const Gap(DesignTokens.spacing2xs),
                                    Text(
                                      'Preferences',
                                      style: theme.textTheme.labelSmall?.copyWith(
                                        color: theme.colorScheme.primary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ).animate().slideX(begin: 0.3, delay: 250.ms).fadeIn(),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Settings Content
            SliverPadding(
              padding: const EdgeInsets.all(DesignTokens.spacingMd),
              sliver: SliverList(
                delegate: SliverChildListDelegate(<Widget>[
                  // Security Settings
                  SettingsGroup(
                    title: 'Security',
                    children: <Widget>[
                      SettingsItem(
                        title: 'Security Settings',
                        subtitle: 'PIN, biometrics, and authentication',
                        icon: Icons.security_rounded,
                        onTap: () => context.goNamed('security-settings'),
                        showTrailing: true,
                      ).animate().slideX(begin: 0.3, delay: 100.ms).fadeIn(),
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

                  const Gap(DesignTokens.spacingLg),

                  // Account / Session
                  SettingsGroup(
                    title: 'Account',
                    children: <Widget>[
                      SettingsItem(
                        title: 'Log Out',
                        subtitle: 'Sign out of your account',
                        icon: Icons.logout_rounded,
                        showTrailing: true,
                        onTap: _handleLogout,
                      ).animate().slideX(begin: 0.3, delay: 550.ms).fadeIn(),
                    ],
                  ),

                  const Gap(DesignTokens.spacingXl),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAppInfo(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: <Color>[
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.secondary,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                ),
                child: Icon(
                  Icons.account_balance_wallet_rounded,
                  color: Theme.of(context).colorScheme.onPrimary,
                  size: 20,
                ),
              ),
              const Gap(DesignTokens.spacingSm),
              const Text('TrackFi'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Version: $_appVersion'),
              const Gap(DesignTokens.spacingSm),
              const Text(
                'TrackFi is a personal finance management app designed to help you track your financial accounts and transactions securely on your device.',
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleLogout() async {
    final bool? shouldLogout = await UiUtils.showConfirmationDialog(
      context,
      title: 'Log Out?',
      message: 'Are you sure you want to log out?',
      confirmText: 'Log Out',
      isDestructive: true,
    );

    if (!(shouldLogout ?? false)) {
      return;
    }

    ref.read(sessionProvider.notifier).logout();
    ref.read(authServiceProvider.notifier).reset();

    if(!mounted) {
      return;
    }

    context.goNamed('auth');
  }
}

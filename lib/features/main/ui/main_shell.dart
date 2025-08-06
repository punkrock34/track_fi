import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/session/session_provider.dart';
import '../../../core/theme/design_tokens/design_tokens.dart';
import '../models/navigation_item.dart';
import '../providers/navigation_provider.dart';
import 'widgets/navigation_button.dart';

class MainShell extends ConsumerWidget {
  const MainShell({super.key, required this.child});

  final Widget child;

  static final List<NavigationItem> _navigationItems = <NavigationItem>[
    const NavigationItem(
      label: 'Dashboard',
      icon: Icons.dashboard_rounded,
      activeIcon: Icons.dashboard,
      routeName: 'dashboard',
    ),
    const NavigationItem(
      label: 'Accounts',
      icon: Icons.account_balance_rounded,
      activeIcon: Icons.account_balance,
      routeName: 'accounts',
    ),
    const NavigationItem(
      label: 'Transactions',
      icon: Icons.receipt_long_rounded,
      activeIcon: Icons.receipt_long,
      routeName: 'transactions',
    ),
    const NavigationItem(
      label: 'Settings',
      icon: Icons.settings_rounded,
      activeIcon: Icons.settings,
      routeName: 'settings',
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String currentLocation = GoRouterState.of(context).uri.path;
    final int currentIndex = _getCurrentIndex(currentLocation);

    return Scaffold(
      body: GestureDetector(
        onTap: () {
          Future<void>.microtask(() => ref.read(sessionProvider.notifier).updateActivity());
        },
        onPanDown: (_) {
          Future<void>.microtask(() => ref.read(sessionProvider.notifier).updateActivity());
        },
        child: child,
      ),
      bottomNavigationBar: _buildBottomNavigation(context, ref, currentIndex),
    );
  }

  Widget _buildBottomNavigation(BuildContext context, WidgetRef ref, int currentIndex) {
    final ThemeData theme = Theme.of(context);
    MediaQuery.of(context);
    
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.2),
            width: 0.5,
          ),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          constraints: const BoxConstraints(
            minHeight: 56, // Minimum height
            maxHeight: 80,  // Maximum height to prevent overflow
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: DesignTokens.spacingXs,
            vertical: DesignTokens.spacing2xs,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _navigationItems.asMap().entries.map((MapEntry<int, NavigationItem> entry) {
              final int index = entry.key;
              final NavigationItem item = entry.value;
              final bool isSelected = index == currentIndex;
              
              return Expanded(
                child: NavigationButton(
                  item: item,
                  isSelected: isSelected,
                  onTap: () => _onNavigationTap(context, ref, index, item.routeName),
                  animationDelay: Duration(milliseconds: index * 50),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  int _getCurrentIndex(String location) {
    final String pathSegment = location.split('/').where((String e) => e.isNotEmpty).firstOrNull ?? '';

    for (int i = 0; i < _navigationItems.length; i++) {
      if (_navigationItems[i].routeName == pathSegment) {
        return i;
      }
    }
    return 0; // Default to Dashboard
  }

  void _onNavigationTap(BuildContext context, WidgetRef ref, int index, String routeName) {
    ref.read(navigationProvider.notifier).updateCurrentIndex(index);
    Future<void>.microtask(() => ref.read(sessionProvider.notifier).updateActivity());
    context.goNamed(routeName);
  }
}

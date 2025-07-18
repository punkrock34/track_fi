import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/session/session_provider.dart';
import '../../../core/theme/design_tokens/design_tokens.dart';
import '../models/navigation_item.dart';
import '../providers/navigation_provider.dart';

class MainShell extends ConsumerWidget {
  const MainShell({super.key, required this.child});

  final Widget child;

  static final List<NavigationItem> _navigationItems = <NavigationItem>[
    const NavigationItem(
      label: 'Dashboard',
      icon: Icons.dashboard_rounded,
      activeIcon: Icons.dashboard,
      route: '/dashboard',
    ),
    const NavigationItem(
      label: 'Accounts',
      icon: Icons.account_balance_rounded,
      activeIcon: Icons.account_balance,
      route: '/accounts',
    ),
    const NavigationItem(
      label: 'Transactions',
      icon: Icons.receipt_long_rounded,
      activeIcon: Icons.receipt_long,
      route: '/transactions',
    ),
    const NavigationItem(
      label: 'Settings',
      icon: Icons.settings_rounded,
      activeIcon: Icons.settings,
      route: '/settings',
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
                child: _NavigationButton(
                  item: item,
                  isSelected: isSelected,
                  onTap: () => _onNavigationTap(context, ref, index, item.route),
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
    for (int i = 0; i < _navigationItems.length; i++) {
      if (location.startsWith(_navigationItems[i].route)) {
        return i;
      }
    }
    return 0; // Default to Dashboard
  }

  void _onNavigationTap(BuildContext context, WidgetRef ref, int index, String route) {
    ref.read(navigationProvider.notifier).updateCurrentIndex(index);
    Future<void>.microtask(() => ref.read(sessionProvider.notifier).updateActivity());
    context.go(route);
  }
}

class _NavigationButton extends StatelessWidget {
  const _NavigationButton({
    required this.item,
    required this.isSelected,
    required this.onTap,
    required this.animationDelay,
  });

  final NavigationItem item;
  final bool isSelected;
  final VoidCallback onTap;
  final Duration animationDelay;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        constraints: const BoxConstraints(
          minHeight: 56,
          maxWidth: 80, // Prevent labels from getting too wide
        ),
        padding: const EdgeInsets.symmetric(
          vertical: 4,
          horizontal: 2,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            AnimatedContainer(
              duration: DesignTokens.durationMedium,
              curve: Curves.easeInOut,
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colorScheme.primaryContainer.withOpacity(0.3)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
              ),
              child: Icon(
                isSelected ? item.activeIcon : item.icon,
                size: 22, // Slightly smaller to prevent overflow
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 2),
            AnimatedDefaultTextStyle(
              duration: DesignTokens.durationMedium,
              curve: Curves.easeInOut,
              style: theme.textTheme.labelSmall!.copyWith(
                fontSize: 10, // Smaller font to prevent overflow
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withOpacity(0.6),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
              child: Text(
                item.label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ).animate(delay: animationDelay)
       .slideY(begin: 0.3)
       .fadeIn(),
    );
  }
}

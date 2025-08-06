import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/session/session_provider.dart';
import '../../../features/main/providers/navigation_provider.dart';
import 'gesture_recognizers/allow_multiple_horizontal_drag.dart';

class SwipeNavigationWrapper extends ConsumerWidget {
  const SwipeNavigationWrapper({
    super.key,
    required this.child,
    required this.currentRoute,
    this.enableSwipeNavigation = true,
    this.enableCircularNavigation = true,
    this.useTabLocking = false,
    this.currentTabIndex,
    this.totalTabs,
  });

  final Widget child;
  final String currentRoute;
  final bool enableSwipeNavigation;
  final bool enableCircularNavigation;
  final bool useTabLocking;
  final int? currentTabIndex;
  final int? totalTabs;

  static const List<String> _routeNames = <String>[
    'dashboard',
    'accounts',
    'transactions',
    'settings',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!enableSwipeNavigation) {
      return child;
    }

    final int index = _getRouteIndex(currentRoute);

    return RawGestureDetector(
      gestures: <Type, GestureRecognizerFactory<GestureRecognizer>>{
        AllowMultipleHorizontalDragGestureRecognizer:
            GestureRecognizerFactoryWithHandlers<
                AllowMultipleHorizontalDragGestureRecognizer>(
          () => AllowMultipleHorizontalDragGestureRecognizer(
              debugOwner: 'SwipeNavigationWrapper'),
          (AllowMultipleHorizontalDragGestureRecognizer instance) {
            instance.onEnd = (DragEndDetails details) {
              final double dx = details.velocity.pixelsPerSecond.dx;
              final double dy = details.velocity.pixelsPerSecond.dy;

              if (dx.abs() <= 300 || dx.abs() <= dy.abs()) {
                return;
              }
              _handleSwipe(context, ref, dx, index);
            };
          },
        ),
      },
      behavior: HitTestBehavior.translucent,
      child: child,
    );
  }

  int _getRouteIndex(String route) {
    return _routeNames.indexWhere(route.startsWith).clamp(0, _routeNames.length - 1);
  }

  void _handleSwipe(BuildContext context, WidgetRef ref, double dx, int index) {
    int? nextIndex;

    final int? tabIndex = currentTabIndex;
    final int? total = totalTabs;

    final bool tabLockingEnabled = useTabLocking && tabIndex != null && total != null;
    final bool onFirstTab = tabLockingEnabled && tabIndex == 0;
    final bool onLastTab = tabLockingEnabled && tabIndex == total - 1;

    if (tabLockingEnabled) {
      if (dx < 0 && onLastTab) {
        nextIndex = _nextIndex(index);
      }
      if (dx > 0 && onFirstTab) {
        nextIndex = _previousIndex(index);
      }
    } else {
      nextIndex = dx < 0 ? _nextIndex(index) : _previousIndex(index);
    }

    if (nextIndex == null || nextIndex == index) {
      return;
    }

    HapticFeedback.lightImpact();
    Future<void>.microtask(() => ref.read(sessionProvider.notifier).updateActivity());
    ref.read(navigationProvider.notifier).updateCurrentIndex(nextIndex);
    context.goNamed(_routeNames[nextIndex]);
  }

  int? _nextIndex(int index) {
    if (index < _routeNames.length - 1) {
      return index + 1;
    }
    if (enableCircularNavigation) {
      return 0;
    }
    return null;
  }

  int? _previousIndex(int index) {
    if (index > 0) {
      return index - 1;
    }
    if (enableCircularNavigation) {
      return _routeNames.length - 1;
    }
    return null;
  }
}

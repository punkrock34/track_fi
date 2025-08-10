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
    this.minHorizontalDistance = 72.0,
    this.minHorizontalVelocity = 900.0,
    this.maxOffAxisRatio = 0.5,
    this.onlyFromScreenEdges = false,
    this.edgeActivationWidth = 28.0,
  });

  final Widget child;
  final String currentRoute;
  final bool enableSwipeNavigation;
  final bool enableCircularNavigation;
  final bool useTabLocking;
  final int? currentTabIndex;
  final int? totalTabs;

  final double minHorizontalDistance;
  final double minHorizontalVelocity;
  final double maxOffAxisRatio;
  final bool onlyFromScreenEdges;
  final double edgeActivationWidth;

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

    final int index = _routeIndexFor(currentRoute);

    Offset? startGlobal;
    double dx = 0, dy = 0;

    return RawGestureDetector(
      gestures: <Type, GestureRecognizerFactory<GestureRecognizer>>{
        AllowMultipleHorizontalDragGestureRecognizer:
            GestureRecognizerFactoryWithHandlers<
                AllowMultipleHorizontalDragGestureRecognizer>(
          () => AllowMultipleHorizontalDragGestureRecognizer(debugOwner: 'SwipeNavigationWrapper'),
          (AllowMultipleHorizontalDragGestureRecognizer g) {
            g.onStart = (DragStartDetails d) {
              startGlobal = d.globalPosition;
              dx = 0; dy = 0;
            };
            g.onUpdate = (DragUpdateDetails d) {
              dx += d.delta.dx;
              dy += d.delta.dy;
            };
            g.onEnd = (DragEndDetails d) {
              if (!_edgeAllowed(context, startGlobal)) {
                return;
              }
              if (!_distanceAllowed(dx)) {
                return;
              }
              if (!_angleAllowed(dx, dy)) {
                return;
              }
              if (!_velocityAllowed(d)) {
                return;
              }
              _navigate(context, ref, dx, index);
            };
          },
        ),
      },
      behavior: HitTestBehavior.translucent,
      child: child,
    );
  }

  int _routeIndexFor(String route) =>
      _routeNames.indexWhere(route.startsWith).clamp(0, _routeNames.length - 1);

  bool _edgeAllowed(BuildContext context, Offset? start) {
    if (!onlyFromScreenEdges || start == null) {
      return true;
    }
    final double w = MediaQuery.of(context).size.width;
    return start.dx <= edgeActivationWidth || start.dx >= w - edgeActivationWidth;
    }

  bool _distanceAllowed(double dx) => dx.abs() >= minHorizontalDistance;

  bool _angleAllowed(double dx, double dy) {
    final double adx = dx.abs(), ady = dy.abs();
    final double offAxis = adx == 0 ? double.infinity : ady / adx;
    return offAxis <= maxOffAxisRatio;
  }

  bool _velocityAllowed(DragEndDetails details) =>
      details.velocity.pixelsPerSecond.dx.abs() >= minHorizontalVelocity;

  void _navigate(BuildContext context, WidgetRef ref, double dx, int index) {
    final int? next = _nextIndexFrom(dx, index);
    if (next == null || next == index) {
      return;
    }

    HapticFeedback.lightImpact();
    Future<void>.microtask(() => ref.read(sessionProvider.notifier).updateActivity());
    ref.read(navigationProvider.notifier).updateCurrentIndex(next);
    context.goNamed(_routeNames[next]);
  }

  int? _nextIndexFrom(double dx, int index) {
    final bool locked = useTabLocking && currentTabIndex != null && totalTabs != null;
    final bool onFirstTab = locked && currentTabIndex == 0;
    final bool onLastTab  = locked && currentTabIndex == (totalTabs! - 1);

    if (locked) {
      if (dx < 0 && onLastTab) {
        return _nextIndex(index);
      }
      if (dx > 0 && onFirstTab) {
        return _previousIndex(index);
      }
      return null;
    }
    return dx < 0 ? _nextIndex(index) : _previousIndex(index);
  }

  int? _nextIndex(int index) =>
      (index < _routeNames.length - 1) ? index + 1 : (enableCircularNavigation ? 0 : null);

  int? _previousIndex(int index) =>
      (index > 0) ? index - 1 : (enableCircularNavigation ? _routeNames.length - 1 : null);
}

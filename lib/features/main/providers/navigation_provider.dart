import 'package:flutter_riverpod/flutter_riverpod.dart';

class NavigationNotifier extends StateNotifier<int> {
  NavigationNotifier() : super(0);

  // ignore: use_setters_to_change_properties
  void updateCurrentIndex(int index) {
    state = index;
  }
}

final StateNotifierProvider<NavigationNotifier, int> navigationProvider =
    StateNotifierProvider<NavigationNotifier, int>(
  (StateNotifierProviderRef<NavigationNotifier, int> ref) => NavigationNotifier(),
);

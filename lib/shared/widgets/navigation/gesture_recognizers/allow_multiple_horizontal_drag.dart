import 'package:flutter/gestures.dart';

class AllowMultipleHorizontalDragGestureRecognizer extends HorizontalDragGestureRecognizer {
  AllowMultipleHorizontalDragGestureRecognizer({super.debugOwner});

  @override
  void rejectGesture(int pointer) {
    acceptGesture(pointer);
  }
}

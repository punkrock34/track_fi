import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/session/session_state.dart';
import '../providers/session/session_provider.dart';

class SessionRefresh extends ChangeNotifier {
  SessionRefresh(ProviderContainer container) {
    container.listen(
      sessionProvider,
      (SessionState? previous, SessionState next) {
        notifyListeners();
      },
    );
  }
}

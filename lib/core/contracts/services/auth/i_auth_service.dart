import '../../../../features/auth/models/auth_state.dart';

abstract class IAuthService {
  AuthenticationState get state;
  set state(AuthenticationState state);

  Future<void> init();
  void updatePin(String pin);
  Future<void> authenticateWithPin();
  void retryBiometric();
  void fallbackToPin();
  void reset();
  void dispose();
}

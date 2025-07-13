import 'has_status.dart';

extension ErrorState<T extends HasStatus> on T {
  T error(String message) => copyWith(
        isLoading: false,
        errorMessage: message,
      ) as T;

  T clearError() => copyWith(
        
      ) as T;
}

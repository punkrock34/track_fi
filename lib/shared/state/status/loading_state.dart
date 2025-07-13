import 'has_status.dart';

extension LoadingState<T extends HasStatus> on T {
  T loading() => copyWith(
        isLoading: true,
      ) as T;

  T notLoading() => copyWith(
        isLoading: false,
      ) as T;
}

abstract class HasStatus {
  bool get isLoading;
  String? get errorMessage;

  HasStatus copyWith({
    bool? isLoading,
    String? errorMessage,
  });
}

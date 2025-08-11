class SaveResult {
  const SaveResult({
    required this.success,
    this.path,
    this.displayName,
  });

  final bool success;
  final String? path;
  final String? displayName;
}

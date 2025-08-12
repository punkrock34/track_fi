class TransactionFormValidators {
  TransactionFormValidators._();

  static String? validateAmount(String? value) {
    if (value?.isEmpty ?? true) {
      return 'Amount is required';
    }
    final double? amount = double.tryParse(value!);
    if (amount == null || amount <= 0) {
      return 'Enter a valid amount greater than 0';
    }
    return null;
  }

  static String? validateDescription(String? value) {
    if (value?.trim().isEmpty ?? true) {
      return 'Description is required';
    }
    if (value!.trim().length < 3) {
      return 'Description must be at least 3 characters';
    }
    if (value.length > 100) {
      return 'Description must be less than 100 characters';
    }
    return null;
  }

  static String? validateReference(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    if (value.length > 50) {
      return 'Reference must be less than 50 characters';
    }
    return null;
  }
}

class AddAccountState {
  const AddAccountState({
    this.name = '',
    this.type = 'current',
    this.balance = 0.0,
    this.currency = 'GBP',
    this.bankName,
    this.accountNumber,
    this.sortCode,
    this.isLoading = false,
    this.errorMessage,
  });

  final String name;
  final String type;
  final double balance;
  final String currency;
  final String? bankName;
  final String? accountNumber;
  final String? sortCode;
  final bool isLoading;
  final String? errorMessage;

  AddAccountState copyWith({
    String? name,
    String? type,
    double? balance,
    String? currency,
    String? bankName,
    String? accountNumber,
    String? sortCode,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AddAccountState(
      name: name ?? this.name,
      type: type ?? this.type,
      balance: balance ?? this.balance,
      currency: currency ?? this.currency,
      bankName: bankName ?? this.bankName,
      accountNumber: accountNumber ?? this.accountNumber,
      sortCode: sortCode ?? this.sortCode,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  bool get isValid => name.trim().isNotEmpty;

  AddAccountState loading() => copyWith(isLoading: true);
  AddAccountState error(String message) => copyWith(isLoading: false, errorMessage: message);
  AddAccountState success() => copyWith(isLoading: false);
}

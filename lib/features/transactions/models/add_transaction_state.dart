import '../../../core/models/database/transaction.dart';

class AddTransactionState {
  const AddTransactionState({
    this.accountId,
    this.amount = 0.0,
    this.description = '',
    this.reference,
    this.transactionDate,
    this.type = TransactionType.debit,
    this.categoryId,
    this.isLoading = false,
    this.errorMessage,
  });

  final String? accountId;
  final double amount;
  final String description;
  final String? reference;
  final DateTime? transactionDate;
  final TransactionType type;
  final String? categoryId;
  final bool isLoading;
  final String? errorMessage;

  AddTransactionState copyWith({
    String? accountId,
    double? amount,
    String? description,
    String? reference,
    DateTime? transactionDate,
    TransactionType? type,
    String? categoryId,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AddTransactionState(
      accountId: accountId ?? this.accountId,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      reference: reference ?? this.reference,
      transactionDate: transactionDate ?? this.transactionDate,
      type: type ?? this.type,
      categoryId: categoryId ?? this.categoryId,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  bool get isValid =>
      accountId != null &&
      accountId!.isNotEmpty &&
      amount > 0 &&
      transactionDate != null;

  AddTransactionState loading() => copyWith(isLoading: true);
  AddTransactionState error(String message) => copyWith(isLoading: false, errorMessage: message);
  AddTransactionState success() => copyWith(isLoading: false);
}

import 'package:uuid/uuid.dart';

import '../../../core/models/database/transaction.dart';

class AddTransactionState {
  const AddTransactionState({
    this.accountId,
    this.accountCurrency,
    this.amount = 0.0,
    this.description = '',
    this.reference,
    this.transactionDate,
    this.type = TransactionType.debit,
    this.categoryId,
    this.isLoading = false,
    this.errorMessage,
  });

  static const Uuid _uuid = Uuid();

  final String? accountId;
  final String? accountCurrency;
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
    String? accountCurrency,
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
      accountCurrency: accountCurrency ?? this.accountCurrency,
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

  bool get isValid => validationError == null;

  String? get validationError {
    if (accountId == null || accountId!.isEmpty) {
      return 'Please select an account';
    }
    if (accountCurrency == null || accountCurrency!.isEmpty) {
      return 'Account currency is required';
    }
    if (amount <= 0) {
      return 'Amount must be greater than £0.00';
    }
    if (description.trim().isEmpty) {
      return 'Description is required';
    }
    if (description.trim().length < 3) {
      return 'Description must be at least 3 characters';
    }
    if (description.length > 100) {
      return 'Description must be less than 100 characters';
    }
    if (transactionDate == null) {
      return 'Transaction date is required';
    }
    if (transactionDate!.isAfter(DateTime.now().add(const Duration(days: 1)))) {
      return 'Transaction date cannot be in the future';
    }
    return null;
  }

  Transaction toTransaction() {
    final DateTime now = DateTime.now();
    final String transactionId = 'txn_${_uuid.v4()}';

    return Transaction(
      id: transactionId,
      accountId: accountId!,
      accountCurrency: accountCurrency!,
      categoryId: categoryId,
      amount: amount,
      description: description.trim(),
      reference: (reference?.trim().isNotEmpty ?? false) ? reference!.trim() : null,
      transactionDate: transactionDate!,
      type: type,
      createdAt: now,
      updatedAt: now,
    );
  }

  AddTransactionState loading() => copyWith(isLoading: true);
  AddTransactionState error(String message) => copyWith(isLoading: false, errorMessage: message);
  AddTransactionState success() => copyWith(isLoading: false);
}

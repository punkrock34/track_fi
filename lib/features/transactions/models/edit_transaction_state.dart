import '../../../core/models/database/transaction.dart';

class EditTransactionState {
  const EditTransactionState({
    this.transactionId,
    this.accountId,
    this.amount = 0.0,
    this.description = '',
    this.reference,
    this.transactionDate,
    this.type = TransactionType.debit,
    this.categoryId,
    this.isLoading = false,
    this.errorMessage,
    this.originalTransaction,
    this.hasChanges = false,
  });

  factory EditTransactionState.fromTransaction(Transaction tx) {
    return EditTransactionState(
      transactionId: tx.id,
      accountId: tx.accountId,
      amount: tx.amount,
      description: tx.description,
      reference: tx.reference,
      transactionDate: tx.transactionDate,
      type: tx.type,
      categoryId: tx.categoryId,
      originalTransaction: tx,
    );
  }

  final String? transactionId;
  final String? accountId;
  final double amount;
  final String description;
  final String? reference;
  final DateTime? transactionDate;
  final TransactionType type;
  final String? categoryId;
  final bool isLoading;
  final String? errorMessage;

  final Transaction? originalTransaction;
  final bool hasChanges;

  String get effectiveAccountId =>
      accountId ?? originalTransaction?.accountId ?? '';

  double get effectiveAmount => (amount == 0.0 && originalTransaction != null)
      ? originalTransaction!.amount
      : amount;

  String get effectiveDescription =>
      description.isNotEmpty
          ? description
          : (originalTransaction?.description ?? '');

  String? get effectiveReference {
    if (reference != null) {
      return reference;
    }

    final String? orig = originalTransaction?.reference;
    return (orig != null && orig.isNotEmpty) ? orig : null;
  }

  DateTime? get effectiveDate =>
      transactionDate ?? originalTransaction?.transactionDate;

  TransactionType get effectiveType => type;

  String? get effectiveCategoryId =>
      categoryId ?? originalTransaction?.categoryId;

  EditTransactionState copyWith({
    String? transactionId,
    String? accountId,
    double? amount,
    String? description,
    String? reference,
    DateTime? transactionDate,
    TransactionType? type,
    String? categoryId,
    bool? isLoading,
    String? errorMessage,
    Transaction? originalTransaction,
    bool? hasChanges,
  }) {
    return EditTransactionState(
      transactionId: transactionId ?? this.transactionId,
      accountId: accountId ?? this.accountId,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      reference: reference ?? this.reference,
      transactionDate: transactionDate ?? this.transactionDate,
      type: type ?? this.type,
      categoryId: categoryId ?? this.categoryId,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      originalTransaction: originalTransaction ?? this.originalTransaction,
      hasChanges: hasChanges ?? this.hasChanges,
    );
  }

  bool get isValid {
    if ((transactionId == null || transactionId!.isEmpty) &&
        originalTransaction == null) {
      return false;
    }
    if (effectiveAccountId.isEmpty) {
      return false;
    }
    if (effectiveAmount <= 0) {
      return false;
    }
    final String desc = effectiveDescription.trim();
    if (desc.isEmpty || desc.length < 3 || desc.length > 100) {
      return false;
    }
    final DateTime? date = effectiveDate;
    if (date == null ||
        date.isAfter(DateTime.now().add(const Duration(days: 1)))) {
      return false;
    }
    return true;
  }

  Transaction? toUpdatedTransaction() {
    if (!isValid || originalTransaction == null) {
      return null;
    }
    return Transaction(
      id: originalTransaction!.id,
      accountId: effectiveAccountId,
      categoryId: effectiveCategoryId,
      amount: effectiveAmount,
      description: effectiveDescription.trim(),
      reference: (effectiveReference?.trim().isNotEmpty ?? false)
          ? effectiveReference!.trim()
          : null,
      transactionDate: effectiveDate!,
      balanceAfter: originalTransaction!.balanceAfter,
      type: effectiveType,
      status: originalTransaction!.status,
      createdAt: originalTransaction!.createdAt,
      updatedAt: DateTime.now(),
      syncedAt: originalTransaction!.syncedAt,
    );
  }

  EditTransactionState loading() =>
      copyWith(isLoading: true);

  EditTransactionState error(String message) =>
      copyWith(isLoading: false, errorMessage: message);

  EditTransactionState success() => copyWith(isLoading: false);

  EditTransactionState _checkForChanges() {
    if (originalTransaction == null) {
      return this;
    }
    final bool changed =
        effectiveAccountId != originalTransaction!.accountId ||
        effectiveAmount != originalTransaction!.amount ||
        effectiveDescription != originalTransaction!.description ||
        effectiveReference != originalTransaction!.reference ||
        effectiveDate != originalTransaction!.transactionDate ||
        effectiveType != originalTransaction!.type ||
        effectiveCategoryId != originalTransaction!.categoryId;
    return copyWith(hasChanges: changed);
  }

  EditTransactionState updateField({
    String? accountId,
    double? amount,
    String? description,
    String? reference,
    DateTime? transactionDate,
    TransactionType? type,
    String? categoryId,
  }) {
    return copyWith(
      accountId: accountId ?? this.accountId,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      reference: reference ?? this.reference,
      transactionDate: transactionDate ?? this.transactionDate,
      type: type ?? this.type,
      categoryId: categoryId ?? this.categoryId,
    )._checkForChanges();
  }
}

class Transaction {

  const Transaction({
    required this.id,
    required this.accountId,
    required this.accountCurrency,
    this.categoryId,
    required this.amount,
    required this.description,
    this.reference,
    required this.transactionDate,
    this.balanceAfter,
    required this.type,
    this.status = 'completed',
    required this.createdAt,
    required this.updatedAt,
    this.syncedAt,
  });

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'] as String,
      accountId: map['account_id'] as String,
      accountCurrency: map['account_currency'] as String? ?? 'RON',
      categoryId: map['category_id'] as String?,
      amount: (map['amount'] as num).toDouble(),
      description: map['description'] as String,
      reference: map['reference'] as String?,
      transactionDate: DateTime.parse(map['transaction_date'] as String),
      balanceAfter: map['balance_after'] != null
        ? (map['balance_after'] as num).toDouble()
        : null,
      type: TransactionType.values.firstWhere(
        (TransactionType e) => e.name == map['type'],
        orElse: () => TransactionType.debit,
      ),
      status: map['status'] as String? ?? 'completed',
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      syncedAt: map['synced_at'] != null
        ? DateTime.parse(map['synced_at'] as String)
        : null,
    );
  }
  final String id;
  final String accountId;
  final String accountCurrency;
  final String? categoryId;
  final double amount;
  final String description;
  final String? reference;
  final DateTime transactionDate;
  final double? balanceAfter;
  final TransactionType type;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? syncedAt;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'account_id': accountId,
      'account_currency': accountCurrency,
      'category_id': categoryId,
      'amount': amount,
      'description': description,
      'reference': reference,
      'transaction_date': transactionDate.toIso8601String(),
      'balance_after': balanceAfter,
      'type': type.name,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'synced_at': syncedAt?.toIso8601String(),
    };
  }

  Transaction copyWith({
    String? id,
    String? accountId,
    String? accountCurrency,
    String? categoryId,
    double? amount,
    String? description,
    String? reference,
    DateTime? transactionDate,
    double? balanceAfter,
    TransactionType? type,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? syncedAt,
  }) {
    return Transaction(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      accountCurrency: accountCurrency ?? this.accountCurrency,
      categoryId: categoryId ?? this.categoryId,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      reference: reference ?? this.reference,
      transactionDate: transactionDate ?? this.transactionDate,
      balanceAfter: balanceAfter ?? this.balanceAfter,
      type: type ?? this.type,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncedAt: syncedAt ?? this.syncedAt,
    );
  }
}

enum TransactionType { debit, credit }

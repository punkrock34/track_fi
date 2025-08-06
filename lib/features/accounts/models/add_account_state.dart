import 'package:uuid/uuid.dart';

import '../../../core/models/database/account.dart';

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
    this.isEditMode = false,
    this.accountId,
    this.createdAt,
    this.updatedAt,
  });

  static const Uuid _uuid = Uuid();

  final String name;
  final String type;
  final double balance;
  final String currency;
  final String? bankName;
  final String? accountNumber;
  final String? sortCode;
  final bool isLoading;
  final String? errorMessage;
  final bool isEditMode;
  final String? accountId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

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
    bool? isEditMode,
    String? accountId,
    DateTime? createdAt,
    DateTime? updatedAt,
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
      isEditMode: isEditMode ?? this.isEditMode,
      accountId: accountId ?? this.accountId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isValid => name.trim().isNotEmpty;

  Account toAccount() => Account(
    id: accountId ?? 'acc_${_uuid.v4()}',
    name: name.trim(),
    type: type,
    balance: balance,
    currency: currency,
    bankName: bankName,
    accountNumber: accountNumber,
    sortCode: sortCode,
    createdAt: createdAt ?? DateTime.now(),
    updatedAt: DateTime.now(),
  );

  AddAccountState loading() => copyWith(isLoading: true);
  AddAccountState error(String message) => copyWith(isLoading: false, errorMessage: message);
  AddAccountState success() => copyWith(isLoading: false);
}

import 'package:uuid/uuid.dart';

import '../../../core/models/database/account.dart';

class AddAccountState {
  
  const AddAccountState({
    this.name = '',
    this.type = 'current',
    this.balance = 0.0,
    this.currency,
    this.bankName,
    this.accountNumber,
    this.sortCode,
    this.isLoading = false,
    this.errorMessage,
  });

  static const Uuid _uuid = Uuid();

  final String name;
  final String type;
  final double balance;
  final String? currency;
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

  Account toAccount() => Account(
    id: 'acc_${_uuid.v4()}',
    name: name.trim(),
    type: type,
    balance: balance,
    currency: currency ?? 'RON',
    bankName: (bankName?.isNotEmpty ?? false) ? bankName : null,
    accountNumber: (accountNumber?.isNotEmpty ?? false) ? accountNumber : null,
    sortCode: (sortCode?.isNotEmpty ?? false) ? sortCode : null,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  AddAccountState loading() => copyWith(isLoading: true);
  AddAccountState error(String message) => copyWith(isLoading: false, errorMessage: message);
  AddAccountState success() => copyWith(isLoading: false);
}

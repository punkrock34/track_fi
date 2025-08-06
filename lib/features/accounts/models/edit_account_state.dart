import '../../../core/models/database/account.dart';

class EditAccountState {
  const EditAccountState({
    this.accountId,
    this.name = '',
    this.type = 'current',
    this.balance = 0.0,
    this.currency = 'GBP',
    this.bankName,
    this.accountNumber,
    this.sortCode,
    this.isActive = true,
    this.isLoading = false,
    this.errorMessage,
    this.originalAccount,
    this.hasChanges = false,
  });

  final String? accountId;
  final String name;
  final String type;
  final double balance;
  final String currency;
  final String? bankName;
  final String? accountNumber;
  final String? sortCode;
  final bool isActive;
  final bool isLoading;
  final String? errorMessage;
  final Account? originalAccount;
  final bool hasChanges;

  EditAccountState copyWith({
    String? accountId,
    String? name,
    String? type,
    double? balance,
    String? currency,
    String? bankName,
    String? accountNumber,
    String? sortCode,
    bool? isActive,
    bool? isLoading,
    String? errorMessage,
    Account? originalAccount,
    bool? hasChanges,
  }) {
    return EditAccountState(
      accountId: accountId ?? this.accountId,
      name: name ?? this.name,
      type: type ?? this.type,
      balance: balance ?? this.balance,
      currency: currency ?? this.currency,
      bankName: bankName ?? this.bankName,
      accountNumber: accountNumber ?? this.accountNumber,
      sortCode: sortCode ?? this.sortCode,
      isActive: isActive ?? this.isActive,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      originalAccount: originalAccount ?? this.originalAccount,
      hasChanges: hasChanges ?? this.hasChanges,
    );
  }

  bool get isValid => accountId != null && name.trim().isNotEmpty;

  Account? toUpdatedAccount() {
    if (!isValid || originalAccount == null) {
      return null;
    }
    
    return originalAccount!.copyWith(
      name: name.trim(),
      type: type,
      balance: balance,
      currency: currency,
      bankName: (bankName?.isNotEmpty ?? false) ? bankName : null,
      accountNumber: (accountNumber?.isNotEmpty ?? false) ? accountNumber : null,
      sortCode: (sortCode?.isNotEmpty ?? false) ? sortCode : null,
      isActive: isActive,
      updatedAt: DateTime.now(),
    );
  }

  EditAccountState loading() => copyWith(isLoading: true);
  EditAccountState error(String message) => copyWith(isLoading: false, errorMessage: message);
  EditAccountState success() => copyWith(isLoading: false);

  EditAccountState fromAccount(Account account) {
    return EditAccountState(
      accountId: account.id,
      name: account.name,
      type: account.type,
      balance: account.balance,
      currency: account.currency,
      bankName: account.bankName,
      accountNumber: account.accountNumber,
      sortCode: account.sortCode,
      isActive: account.isActive,
      originalAccount: account,
    );
  }

  EditAccountState _checkForChanges() {
    if (originalAccount == null) {
      return this;
    }
    
    final bool changed = name != originalAccount!.name ||
                        type != originalAccount!.type ||
                        balance != originalAccount!.balance ||
                        currency != originalAccount!.currency ||
                        bankName != originalAccount!.bankName ||
                        accountNumber != originalAccount!.accountNumber ||
                        sortCode != originalAccount!.sortCode ||
                        isActive != originalAccount!.isActive;
    
    return copyWith(hasChanges: changed);
  }

  EditAccountState updateField<T>({
    String? name,
    String? type,
    double? balance,
    String? currency,
    String? bankName,
    String? accountNumber,
    String? sortCode,
    bool? isActive,
  }) {
    return copyWith(
      name: name ?? this.name,
      type: type ?? this.type,
      balance: balance ?? this.balance,
      currency: currency ?? this.currency,
      bankName: bankName ?? this.bankName,
      accountNumber: accountNumber ?? this.accountNumber,
      sortCode: sortCode ?? this.sortCode,
      isActive: isActive ?? this.isActive,
    )._checkForChanges();
  }
}

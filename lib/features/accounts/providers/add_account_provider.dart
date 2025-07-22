import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/contracts/services/database/storage/i_account_storage_service.dart';
import '../../../core/logging/log.dart';
import '../../../core/models/database/account.dart';
import '../../../core/providers/database/storage/account_storage_service_provider.dart';
import '../models/add_account_state.dart';

class AddAccountNotifier extends StateNotifier<AddAccountState> {
  AddAccountNotifier(this._ref) : super(const AddAccountState());

  final Ref _ref;

  IAccountStorageService get _accountStorage => _ref.read(accountStorageProvider);

  void updateName(String name) {
    state = state.copyWith(name: name);
  }

  void updateType(String type) {
    state = state.copyWith(type: type);
  }

  void updateBalance(double balance) {
    state = state.copyWith(balance: balance);
  }

  void updateCurrency(String currency) {
    state = state.copyWith(currency: currency);
  }

  void updateBankName(String? bankName) {
    state = state.copyWith(bankName: bankName);
  }

  void updateAccountNumber(String? accountNumber) {
    state = state.copyWith(accountNumber: accountNumber);
  }

  void updateSortCode(String? sortCode) {
    state = state.copyWith(sortCode: sortCode);
  }

  Future<bool> createAccount() async {
    if (!state.isValid) {
      state = state.error('Account name is required');
      return false;
    }

    if (state.isLoading) {
      return false;
    }

    state = state.loading();

    try {
      final DateTime now = DateTime.now();
      final String accountId = 'acc_${now.millisecondsSinceEpoch}';

      final Account account = Account(
        id: accountId,
        name: state.name.trim(),
        type: state.type,
        balance: state.balance,
        currency: state.currency,
        bankName: (state.bankName?.trim().isEmpty ?? true) ? null : state.bankName!.trim(),
        accountNumber: (state.accountNumber?.trim().isEmpty ?? true) ? null : state.accountNumber!.trim(),
        sortCode: (state.sortCode?.trim().isEmpty ?? true) ? null : state.sortCode!.trim(),
        createdAt: now,
        updatedAt: now,
      );

      await _accountStorage.save(account);
      state = state.success();
      return true;
    } catch (e, stackTrace) {
      await log(
        message: 'Failed to create account',
        error: e,
        stackTrace: stackTrace,
      );
      state = state.error('Failed to create account. Please try again.');
      return false;
    }
  }

  void reset() {
    state = const AddAccountState();
  }
}

final StateNotifierProvider<AddAccountNotifier, AddAccountState> addAccountProvider =
    StateNotifierProvider<AddAccountNotifier, AddAccountState>(
  (StateNotifierProviderRef<AddAccountNotifier, AddAccountState> ref) => AddAccountNotifier(ref),
);

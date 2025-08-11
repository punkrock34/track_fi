import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/contracts/services/database/storage/i_account_storage_service.dart';
import '../../../core/logging/log.dart';
import '../../../core/models/database/account.dart';
import '../../../core/providers/database/storage/account_storage_service_provider.dart';
import '../../../core/providers/financial/active_accounts_provider.dart';
import '../../../core/providers/financial/converted_balances_provider.dart';
import '../../../core/providers/financial/inactive_accounts_provider.dart';
import '../../../core/providers/financial/total_balance_provider.dart';
import '../../dashboard/providers/dashboard_provider.dart';
import '../models/add_account_state.dart';
import 'accounts_provider.dart';

class AddAccountNotifier extends StateNotifier<AddAccountState> {
  AddAccountNotifier(this._ref) : super(const AddAccountState());

  final Ref _ref;

  IAccountStorageService get _accountStorage => _ref.read(accountStorageProvider);

  void updateName(String name) {
    if (!mounted) {
      return;
    }
    state = state.copyWith(name: name);
  }

  void updateType(String type) {
    if (!mounted) {
      return;
    }
    state = state.copyWith(type: type);
  }

  void updateBalance(double balance) {
    if (!mounted) {
      return;
    }
    state = state.copyWith(balance: balance);
  }

  void updateCurrency(String currency) {
    if (!mounted) {
      return;
    }
    state = state.copyWith(currency: currency);
  }

  void updateBankName(String? bankName) {
    if (!mounted) {
      return;
    }
    state = state.copyWith(bankName: bankName);
  }

  void updateAccountNumber(String? accountNumber) {
    if (!mounted) {
      return;
    }
    state = state.copyWith(accountNumber: accountNumber);
  }

  void updateSortCode(String? sortCode) {
    if (!mounted) {
      return;
    }
    state = state.copyWith(sortCode: sortCode);
  }

  Future<bool> saveAccount() async {
    if (!state.isValid) {
      return false;
    }

    state = state.loading();

    try {
      final Account account = state.toAccount();
      await _accountStorage.save(account);

      _ref.invalidate(accountProvider(account.id));
      _ref.invalidate(accountsProvider);

      _ref.invalidate(activeAccountsProvider);
      _ref.invalidate(inactiveAccountsProvider);

      _ref.invalidate(convertedBalancesProvider);
      _ref.invalidate(totalBalanceProvider);

      await _ref.read(dashboardProvider.notifier).loadDashboardData();
      await _ref.read(accountsProvider.notifier).loadAccounts();

      if (!mounted) {
        return false;
      }
      
      state = state.success();
      return true;
    } catch (e, stackTrace) {
      await log(
        message: 'Failed to create account',
        error: e,
        stackTrace: stackTrace,
      );
      
      if (!mounted) {
        return false;
      }
      
      state = state.error('Failed to create account. Please try again.');
      return false;
    }
  }

  void reset() {
    if (!mounted) {
      return;
    }
    state = const AddAccountState();
  }
}

final StateNotifierProvider<AddAccountNotifier, AddAccountState> addAccountProvider =
    StateNotifierProvider<AddAccountNotifier, AddAccountState>(
  (StateNotifierProviderRef<AddAccountNotifier, AddAccountState> ref) => AddAccountNotifier(ref),
);

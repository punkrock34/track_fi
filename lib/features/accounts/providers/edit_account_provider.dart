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
import '../models/edit_account_state.dart';
import 'accounts_provider.dart';

class EditAccountNotifier extends StateNotifier<EditAccountState> {
  EditAccountNotifier(this._ref) : super(const EditAccountState());

  final Ref _ref;

  IAccountStorageService get _accountStorage => _ref.read(accountStorageProvider);

  Future<void> loadAccount(String accountId) async {
    state = state.loading();
    
    try {
      final Account? account = await _accountStorage.get(accountId);
      
      if (account == null) {
        state = state.error('Account not found');
        return;
      }
      
      state = const EditAccountState().fromAccount(account);
    } catch (e, stackTrace) {
      await log(
        message: 'Failed to load account for editing',
        error: e,
        stackTrace: stackTrace,
      );
      state = state.error('Failed to load account');
    }
  }

  void updateName(String name) {
    if (!mounted) {
      return;
    }
    state = state.updateField(name: name);
  }

  void updateType(String type) {
    if (!mounted) {
      return;
    }
    state = state.updateField(type: type);
  }

  void updateBalance(double balance) {
    if (!mounted) {
      return;
    }
    state = state.updateField(balance: balance);
  }

  void updateCurrency(String currency) {
    if (!mounted) {
      return;
    }
    state = state.updateField(currency: currency);
  }

  void updateBankName(String? bankName) {
    if (!mounted) {
      return;
    }
    state = state.updateField(bankName: bankName);
  }

  void updateAccountNumber(String? accountNumber) {
    if (!mounted) {
      return;
    }
    state = state.updateField(accountNumber: accountNumber);
  }

  void updateSortCode(String? sortCode) {
    if (!mounted) {
      return;
    }
    state = state.updateField(sortCode: sortCode);
  }

  void updateIsActive(bool isActive) {
    if (!mounted) {
      return;
    }
    state = state.updateField(isActive: isActive);
  }

  Future<bool> saveChanges() async {
    if (!state.isValid || !state.hasChanges) {
      return false;
    }

    state = state.loading();

    try {
      final Account? updatedAccount = state.toUpdatedAccount();
      
      if (updatedAccount == null) {
        state = state.error('Invalid account data');
        return false;
      }

      await _accountStorage.update(updatedAccount);
      
      _ref.invalidate(accountProvider(updatedAccount.id));
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
        message: 'Failed to save account changes',
        error: e,
        stackTrace: stackTrace,
      );
      
      if (!mounted) {
        return false;
      }
      
      state = state.error('Failed to save changes. Please try again.');
      return false;
    }
  }

  void reset() {
    if (!mounted) {
      return;
    }
    state = const EditAccountState();
  }

  void discardChanges() {
    if (!mounted || state.originalAccount == null) {
      return;
    }
    state = const EditAccountState().fromAccount(state.originalAccount!);
  }
}

final StateNotifierProvider<EditAccountNotifier, EditAccountState> editAccountProvider =
    StateNotifierProvider<EditAccountNotifier, EditAccountState>(
  (StateNotifierProviderRef<EditAccountNotifier, EditAccountState> ref) => EditAccountNotifier(ref),
);

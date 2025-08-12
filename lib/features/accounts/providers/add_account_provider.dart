import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/contracts/services/database/storage/i_account_storage_service.dart';
import '../../../core/logging/log.dart';
import '../../../core/models/database/account.dart';
import '../../../core/providers/database/storage/account_storage_service_provider.dart';
import '../../../core/providers/financial/active_accounts_provider.dart';
import '../../../core/providers/financial/base_currency_provider.dart';
import '../../../core/providers/financial/converted_balances_provider.dart';
import '../../../core/providers/financial/inactive_accounts_provider.dart';
import '../../../core/providers/financial/total_balance_provider.dart';
import '../../dashboard/providers/dashboard_provider.dart';
import '../models/add_account_state.dart';
import 'accounts_provider.dart';

class AddAccountNotifier extends StateNotifier<AddAccountState> {
  AddAccountNotifier(this._ref) : super(const AddAccountState()) {
    _seedBaseCurrency();
    _ref.listen<AsyncValue<String>>(baseCurrencyProvider, (AsyncValue<String>? prev, AsyncValue<String> next) {
      next.whenData((String base) {
        if (!mounted) {
          return;
        }
        if (state.currency == null) {
          state = state.copyWith(currency: base);
        }
      });
    });
  }

  final Ref _ref;
  static const Uuid _uuid = Uuid();

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
      final String base =
          _ref.read(baseCurrencyProvider).asData?.value ?? 'RON';

      final Account account = Account(
        id: 'acc_${_uuid.v4()}',
        name: state.name.trim(),
        type: state.type,
        balance: state.balance,
        currency: state.currency ?? base,
        bankName: (state.bankName?.isNotEmpty ?? false) ? state.bankName : null,
        accountNumber: (state.accountNumber?.isNotEmpty ?? false) ? state.accountNumber : null,
        sortCode: (state.sortCode?.isNotEmpty ?? false) ? state.sortCode : null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

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
    _seedBaseCurrency();
  }

  void _seedBaseCurrency() {
    final AsyncValue<String> baseNow = _ref.read(baseCurrencyProvider);
    baseNow.whenData((String base) {
      if (!mounted) {
        return;
      }
      if (state.currency == null) {
        state = state.copyWith(currency: base);
      }
    });
  }
}

final StateNotifierProvider<AddAccountNotifier, AddAccountState> addAccountProvider =
    StateNotifierProvider<AddAccountNotifier, AddAccountState>(
  (StateNotifierProviderRef<AddAccountNotifier, AddAccountState> ref) => AddAccountNotifier(ref),
);

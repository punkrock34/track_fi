import '../models/account_model.dart';

class DashboardController {
  List<Account> getMockAccounts() {
    return [
      Account(name: 'Revolut', balance: 1230.50, type: AccountType.bank),
      Account(name: 'Trading212', balance: 3421.00, type: AccountType.trading),
      Account(name: 'Crypto Wallet', balance: 904.20, type: AccountType.crypto),
    ];
  }

  double getTotalBalance(List<Account> accounts) {
    return accounts.fold(0, (sum, acc) => sum + acc.balance);
  }
}

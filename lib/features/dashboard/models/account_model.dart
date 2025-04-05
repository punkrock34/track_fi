enum AccountType { bank, trading, crypto }

class Account {
  final String name;
  final double balance;
  final AccountType type;

  Account({
    required this.name,
    required this.balance,
    required this.type,
  });
}

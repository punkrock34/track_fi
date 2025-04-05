import 'package:flutter/material.dart';
import 'package:trackfi/features/dashboard/models/account_model.dart';

class AccountCard extends StatelessWidget {
  final Account account;
  const AccountCard({super.key, required this.account});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Define colors based on account type
    Color cardColor;
    Color iconColor;
    IconData icon;
    
    switch (account.type) {
      case AccountType.bank:
        icon = Icons.account_balance;
        cardColor = isDark ? const Color(0xFF2A3F5F) : const Color(0xFFE8F1FF);
        iconColor = const Color(0xFF3366FF);
        break;
      case AccountType.trading:
        icon = Icons.show_chart;
        cardColor = isDark ? const Color(0xFF2F4046) : const Color(0xFFE8F6F0);
        iconColor = const Color(0xFF33C759);
        break;
      case AccountType.crypto:
        icon = Icons.currency_bitcoin;
        cardColor = isDark ? const Color(0xFF483F26) : const Color(0xFFFFF8E1);
        iconColor = const Color(0xFFFFC107);
        break;
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    account.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    _getAccountTypeString(account.type),
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white60 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '€${account.balance.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      Icons.arrow_upward,
                      color: Colors.green,
                      size: 14,
                    ),
                    Text(
                      '2.4%',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  String _getAccountTypeString(AccountType type) {
    switch (type) {
      case AccountType.bank:
        return 'Banking Account';
      case AccountType.trading:
        return 'Investment Account';
      case AccountType.crypto:
        return 'Cryptocurrency Wallet';
    }
  }
}
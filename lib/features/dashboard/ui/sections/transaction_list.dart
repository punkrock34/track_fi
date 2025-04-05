import 'package:flutter/material.dart';
import 'package:trackfi/app/theme/theme_extensions.dart';

class TransactionList extends StatelessWidget {
  const TransactionList({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    final items = [
      _build('Deposit', 'Trading212', '+ €500.00', now.subtract(const Duration(days: 1)), Colors.green),
      _build('Withdrawal', 'Revolut', '- €120.50', now.subtract(const Duration(days: 3)), Colors.red),
      _build('Exchange', 'Crypto Wallet', '- €75.30', now.subtract(const Duration(days: 4)), Colors.orange),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Recent Activities',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        ...items,
      ],
    );
  }

  Widget _build(String type, String account, String amount, DateTime date, Color color) {
    return Builder(builder: (context) {
      final theme = Theme.of(context);
      return Card(
        elevation: 0,
        margin: const EdgeInsets.only(bottom: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: theme.cardBorder, width: 0.5),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withAlpha((0.15 * 255).round()),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  type == 'Deposit' ? Icons.arrow_downward : 
                  type == 'Withdrawal' ? Icons.arrow_upward : Icons.swap_horiz,
                  color: color,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(type, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(account, style: TextStyle(fontSize: 12, color: theme.textSubtle)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(amount, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
                  Text('${date.day}/${date.month}/${date.year}', style: TextStyle(fontSize: 12, color: theme.textSubtle)),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }
}

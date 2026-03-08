import 'package:flutter/material.dart';
import '../../transactions/domain/transaction.dart';
import '../../transactions/domain/category.dart';

class RecentTransactionTile extends StatelessWidget {
  final TransactionModel transaction;
  final Category category;

  const RecentTransactionTile({
    super.key,
    required this.transaction,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    final amount = (transaction.amountCents / 100).toStringAsFixed(2);

    final color = transaction.isIncome ? Colors.green : Colors.red;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Color(category.color).withOpacity(0.2),
          child: Icon(
            IconData(category.icon, fontFamily: 'MaterialIcons'),
            color: Color(category.color),
          ),
        ),
        title: Text(category.name),
        subtitle: Text(transaction.note ?? ''),
        trailing: Text(
          "${transaction.isIncome ? '+' : '-'} €$amount",
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

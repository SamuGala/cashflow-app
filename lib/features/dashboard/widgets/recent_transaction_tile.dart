import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../transactions/domain/transaction.dart';
import '../../transactions/domain/category.dart';
import '../../../core/currency/currency_metadata.dart';
import '../../../core/currency/currency_provider.dart';
import '../../../core/utils/category_localization.dart';

class RecentTransactionTile extends ConsumerWidget {
  final TransactionModel transaction;
  final Category category;

  const RecentTransactionTile({
    super.key,
    required this.transaction,
    required this.category,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currency = ref.watch(currencyProvider).value?.baseCurrency ?? 'EUR';
    final amount = formatMoney(
      transaction.amountCents,
      currency,
      Localizations.localeOf(context).toString(),
    );

    final color = transaction.isIncome ? Colors.green : Colors.red;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Color(category.color).withValues(alpha: 0.2),
          child: Icon(
            category.isDefault
                ? categoryIcon(category.name)
                : customCategoryIcon(category.icon),
            size: 22,
            color: Color(category.color),
          ),
        ),
        title: Text(category.name),
        subtitle: Text(transaction.note ?? ''),
        trailing: Text(
          "${transaction.isIncome ? '+' : '-'} $amount",
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

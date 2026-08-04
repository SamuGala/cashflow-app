import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_vault/features/stats/providers/monthly_summary_provider.dart';
import 'package:pocket_vault/features/transactions/domain/transaction.dart';

void main() {
  test('monthly summary includes only the selected month and year', () {
    final transactions = [
      TransactionModel(
        id: 'income',
        amountCents: 200000,
        isIncome: true,
        categoryId: 'salary',
        date: DateTime(2026, 7, 1),
      ),
      TransactionModel(
        id: 'expense',
        amountCents: 4500,
        isIncome: false,
        categoryId: 'food',
        date: DateTime(2026, 7, 20),
      ),
      TransactionModel(
        id: 'other-year',
        amountCents: 99999,
        isIncome: true,
        categoryId: 'salary',
        date: DateTime(2025, 7, 1),
      ),
    ];

    final summary = calculateMonthlySummary(transactions, DateTime(2026, 7));

    expect(summary.income, 200000);
    expect(summary.expense, 4500);
  });
}

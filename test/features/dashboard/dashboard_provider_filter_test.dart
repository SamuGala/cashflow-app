import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_vault/core/providers/time_filter_provider.dart';
import 'package:pocket_vault/features/dashboard/providers/dashboard_provider.dart';
import 'package:pocket_vault/features/transactions/domain/transaction.dart';
import 'package:pocket_vault/features/transactions/providers/transaction_provider.dart';

class _SeededTransactions extends TransactionNotifier {
  @override
  Future<List<TransactionModel>> build() async => [
    TransactionModel(
      id: 'oct',
      amountCents: 100,
      isIncome: false,
      categoryId: 'food',
      date: DateTime(2026, 10, 31, 23, 59),
    ),
    TransactionModel(
      id: 'nov',
      amountCents: 300,
      isIncome: false,
      categoryId: 'food',
      date: DateTime(2026, 11, 1),
    ),
  ];
}

void main() {
  test(
    'dashboard query honours its explicit month and includes the entire period end',
    () async {
      final container = ProviderContainer(
        overrides: [transactionProvider.overrideWith(_SeededTransactions.new)],
      );
      addTearDown(container.dispose);
      await container.read(transactionProvider.future);
      container.read(timeFilterProvider.notifier).setMonth(DateTime(2026, 11));
      expect(
        container
            .read(
              dashboardProvider(
                DashboardQuery(
                  filter: TimeFilter.month,
                  start: DateTime(2026, 10),
                ),
              ),
            )
            .expense,
        100,
      );
      expect(
        container
            .read(
              dashboardProvider(
                DashboardQuery(
                  filter: TimeFilter.period,
                  start: DateTime(2026, 10, 31),
                  end: DateTime(2026, 10, 31),
                ),
              ),
            )
            .expense,
        100,
      );
      expect(
        container
            .read(
              dashboardProvider(const DashboardQuery(filter: TimeFilter.total)),
            )
            .expense,
        400,
      );
    },
  );
}

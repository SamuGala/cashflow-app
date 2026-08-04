import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_vault/core/database/app_database.dart';
import 'package:pocket_vault/features/forecast/providers/cashflow_forecast_provider.dart';
import 'package:pocket_vault/features/transactions/domain/transaction.dart';

void main() {
  test(
    '90-day forecast includes each active future recurrence exactly once',
    () {
      final now = DateTime(2026, 7, 31, 12);
      final forecast = buildCashflowForecast(
        now: now,
        through: DateTime(2026, 10, 31, 12),
        transactions: [
          TransactionModel(
            id: 'salary',
            amountCents: 200000,
            isIncome: true,
            categoryId: 'salary',
            date: DateTime(2026, 7, 1),
          ),
          TransactionModel(
            id: 'expense',
            amountCents: 50000,
            isIncome: false,
            categoryId: 'food',
            date: DateTime(2026, 7, 2),
          ),
        ],
        recurringTransactions: [
          RecurringTransaction(
            id: 'rent',
            amountCents: 100000,
            isIncome: false,
            categoryId: 'rent',
            dayOfMonth: 5,
            startDate: DateTime(2026, 7, 1),
            active: true,
            frequency: 'monthly',
            interval: 1,
          ),
          RecurringTransaction(
            id: 'inactive',
            amountCents: 999999,
            isIncome: false,
            categoryId: 'other',
            dayOfMonth: 1,
            startDate: DateTime(2026, 1, 1),
            active: false,
            frequency: 'monthly',
            interval: 1,
          ),
        ],
      );

      expect(forecast.currentBalanceMinor, 150000);
      expect(forecast.occurrences.map((item) => item.date), [
        DateTime(2026, 8, 5),
        DateTime(2026, 9, 5),
        DateTime(2026, 10, 5),
      ]);
      expect(forecast.projectedBalanceMinor, -150000);
    },
  );

  test('forecast rejects an invalid horizon', () {
    expect(
      () => buildCashflowForecast(
        transactions: const [],
        recurringTransactions: const [],
        now: DateTime(2026, 7, 31),
        through: DateTime(2026, 7, 31),
      ),
      throwsArgumentError,
    );
  });

  test('month horizons clamp safely at the end of short months', () {
    expect(
      forecastEndDate(DateTime(2026, 1, 31, 12), ForecastHorizon.oneMonth),
      DateTime(2026, 2, 28, 12),
    );
    expect(
      forecastEndDate(DateTime(2026, 7, 31), ForecastHorizon.oneYear),
      DateTime(2027, 7, 31),
    );
    expect(ForecastHorizon.values.map((value) => value.months), [
      1,
      2,
      3,
      6,
      12,
      24,
      60,
    ]);
    expect(
      forecastEndDate(DateTime(2024, 2, 29), ForecastHorizon.fiveYears),
      DateTime(2029, 2, 28),
    );
  });
}

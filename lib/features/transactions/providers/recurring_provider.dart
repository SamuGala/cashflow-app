import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';

import '../../../core/database/database_provider.dart';
import '../../../core/database/app_database.dart';
import 'category_provider.dart';
import '../../../core/currency/currency_provider.dart';
import '../domain/recurrence_calculator.dart';

final recurringProvider =
    AsyncNotifierProvider<RecurringNotifier, List<RecurringTransaction>>(
      RecurringNotifier.new,
    );

class RecurringNotifier extends AsyncNotifier<List<RecurringTransaction>> {
  Future<List<RecurringTransaction>> _load() async {
    final db = ref.read(databaseProvider);
    return db.select(db.recurringTransactions).get();
  }

  @override
  Future<List<RecurringTransaction>> build() async {
    ref.watch(currencyProvider.select((value) => value.value?.baseCurrency));
    final db = ref.read(databaseProvider);

    return await db.select(db.recurringTransactions).get();
  }

  /// DELETE RECURRING
  Future<void> deleteRecurring(String id) async {
    final db = ref.read(databaseProvider);

    await (db.delete(
      db.recurringTransactions,
    )..where((t) => t.id.equals(id))).go();

    state = AsyncData(await _load());
  }

  Future<void> restoreRecurring(RecurringTransaction recurring) async {
    final db = ref.read(databaseProvider);
    await db.into(db.recurringTransactions).insertOnConflictUpdate(recurring);
    state = AsyncData(await _load());
  }

  /// ENABLE / DISABLE RECURRING
  Future<void> toggleActive(String id, bool active) async {
    final db = ref.read(databaseProvider);

    await (db.update(db.recurringTransactions)..where((t) => t.id.equals(id)))
        .write(RecurringTransactionsCompanion(active: Value(active)));

    state = AsyncData(await _load());
  }

  Future<void> updateRecurring({
    required String id,
    required int amountCents,
    required String categoryId,
    required int dayOfMonth,
    String? currencyCode,
    RecurrenceFrequency frequency = RecurrenceFrequency.monthly,
    int interval = 1,
    int? dayOfWeek,
    int? monthOfYear,
    DateTime? endDate,
  }) async {
    final db = ref.read(databaseProvider);
    final conversion = await ref
        .read(currencyProvider.notifier)
        .convert(
          amountMinor: amountCents,
          sourceCurrency:
              currencyCode ??
              ref.read(currencyProvider).value?.baseCurrency ??
              'EUR',
        );

    await (db.update(
      db.recurringTransactions,
    )..where((t) => t.id.equals(id))).write(
      RecurringTransactionsCompanion(
        amountCents: Value(conversion.baseAmountMinor),
        categoryId: Value(categoryId),
        dayOfMonth: Value(dayOfMonth),
        originalAmountMinor: Value(conversion.originalAmountMinor),
        originalCurrency: Value(conversion.originalCurrency),
        eurAmountMicros: Value(conversion.eurAmountMicros),
        exchangeRateToEur: Value(conversion.exchangeRateToEur),
        frequency: Value(frequency.name),
        interval: Value(interval),
        dayOfWeek: Value(dayOfWeek),
        monthOfYear: Value(monthOfYear),
        endDate: Value(endDate),
      ),
    );
    await ref.read(categoryProvider.notifier).markUsed(categoryId);

    state = AsyncData(await db.select(db.recurringTransactions).get());
  }

  /// FORCE REFRESH
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = AsyncData(await _load());
  }
}

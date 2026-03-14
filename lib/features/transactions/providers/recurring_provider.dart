import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';

import '../../../core/database/database_provider.dart';
import '../../../core/database/app_database.dart';

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
  }) async {
    final db = ref.read(databaseProvider);

    await (db.update(
      db.recurringTransactions,
    )..where((t) => t.id.equals(id))).write(
      RecurringTransactionsCompanion(
        amountCents: Value(amountCents),
        categoryId: Value(categoryId),
        dayOfMonth: Value(dayOfMonth),
      ),
    );

    state = AsyncData(await db.select(db.recurringTransactions).get());
  }

  /// FORCE REFRESH
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = AsyncData(await _load());
  }
}

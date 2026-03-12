import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/providers/database_provider.dart';
import '../domain/transaction.dart';

final transactionProvider =
    AsyncNotifierProvider<TransactionNotifier, List<TransactionModel>>(
      TransactionNotifier.new,
    );

class TransactionNotifier extends AsyncNotifier<List<TransactionModel>> {
  final _uuid = const Uuid();

  @override
  Future<List<TransactionModel>> build() async {
    final db = ref.read(databaseProvider);

    /// genera eventuali transazioni ricorrenti

    final rows = await db.getAllTransactions();

    return rows
        .map(
          (r) => TransactionModel(
            id: r.id,
            amountCents: r.amountCents,
            isIncome: r.isIncome,
            categoryId: r.categoryId,
            date: r.date,
            note: r.note,
            isRecurring: r.isRecurring,
          ),
        )
        .toList();
  }

  Future<void> addTransaction({
    required int amountCents,
    required bool isIncome,
    required String categoryId,
    required DateTime date,
    String? note,
  }) async {
    final db = ref.read(databaseProvider);

    final transaction = TransactionModel(
      id: _uuid.v4(),
      amountCents: amountCents,
      isIncome: isIncome,
      categoryId: categoryId,
      date: date,
      note: note,
      isRecurring: false,
    );

    await db.insertTransaction(
      TransactionsCompanion.insert(
        id: transaction.id,
        amountCents: transaction.amountCents,
        isIncome: transaction.isIncome,
        categoryId: transaction.categoryId,
        date: transaction.date,
        note: Value(transaction.note),
        isRecurring: const Value(false),
      ),
    );

    final current = state.value ?? [];
    state = AsyncData([...current, transaction]);
  }

  Future<void> addRecurringTransaction({
    required int amountCents,
    required bool isIncome,
    required String categoryId,
    required int dayOfMonth,
    required DateTime startDate,
    String? note,
  }) async {
    final db = ref.read(databaseProvider);

    await db.insertRecurringTransaction(
      amountCents: amountCents,
      isIncome: isIncome,
      categoryId: categoryId,
      dayOfMonth: dayOfMonth,
      startDate: startDate,
      note: note,
    );
  }

  Future<void> deleteTransaction(String id) async {
    final db = ref.read(databaseProvider);

    await db.deleteTransactionById(id);

    final current = state.value ?? [];
    state = AsyncData(current.where((t) => t.id != id).toList());
  }

  Future<void> updateTransaction({
    required String id,
    required int amountCents,
    required bool isIncome,
    required String categoryId,
    required DateTime date,
    String? note,
  }) async {
    final db = ref.read(databaseProvider);

    await db.updateTransaction(
      id: id,
      amountCents: amountCents,
      isIncome: isIncome,
      categoryId: categoryId,
      date: date,
      note: note,
    );

    final current = state.value ?? [];

    final updated = current.map((t) {
      if (t.id == id) {
        return TransactionModel(
          id: id,
          amountCents: amountCents,
          isIncome: isIncome,
          categoryId: categoryId,
          date: date,
          note: note,
          isRecurring: t.isRecurring,
        );
      }
      return t;
    }).toList();

    state = AsyncData(updated);
  }

  /// DELETE ALL DATA
  Future<void> deleteAllData() async {
    final db = ref.read(databaseProvider);

    await db.clearAllData();

    state = const AsyncData([]);
  }
}

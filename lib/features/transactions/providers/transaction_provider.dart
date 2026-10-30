import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../domain/transaction.dart';
import '../providers/category_provider.dart';
import '../providers/recurring_provider.dart';
import '../../../core/currency/currency_provider.dart';
import '../domain/recurrence_calculator.dart';
import '../../../core/receipts/receipt_storage_service.dart';

final transactionProvider =
    AsyncNotifierProvider<TransactionNotifier, List<TransactionModel>>(
      TransactionNotifier.new,
    );

class TransactionNotifier extends AsyncNotifier<List<TransactionModel>> {
  final _uuid = const Uuid();

  @override
  Future<List<TransactionModel>> build() async {
    ref.watch(currencyProvider.select((value) => value.value?.baseCurrency));
    final db = ref.read(databaseProvider);

    final rows = await db.getAllTransactions();

    final transactions = rows
        .map(
          (r) => TransactionModel(
            id: r.id,
            amountCents: r.amountCents,
            isIncome: r.isIncome,
            categoryId: r.categoryId,
            date: r.date,
            note: r.note,
            isRecurring: r.isRecurring,
            originalAmountMinor: r.originalAmountMinor,
            originalCurrency: r.originalCurrency ?? 'EUR',
            eurAmountMicros: r.eurAmountMicros,
            exchangeRateToEur: r.exchangeRateToEur ?? 1,
            receiptPath: r.receiptPath,
            createdAt: r.createdAt,
            recurringSourceId: r.recurringSourceId,
            recurringOccurrenceKey: r.recurringOccurrenceKey,
          ),
        )
        .toList();
    return transactions;
  }

  Future<void> addTransaction({
    required int amountCents,
    required bool isIncome,
    required String categoryId,
    required DateTime date,
    String? note,
    String? currencyCode,
    String? receiptPath,
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
    final createdAt = DateTime.now();

    final transaction = TransactionModel(
      id: _uuid.v4(),
      amountCents: conversion.baseAmountMinor,
      isIncome: isIncome,
      categoryId: categoryId,
      date: date,
      note: note,
      isRecurring: false,
      originalAmountMinor: conversion.originalAmountMinor,
      originalCurrency: conversion.originalCurrency,
      eurAmountMicros: conversion.eurAmountMicros,
      exchangeRateToEur: conversion.exchangeRateToEur,
      receiptPath: receiptPath,
      createdAt: createdAt,
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
        originalAmountMinor: Value(transaction.originalAmountMinor),
        originalCurrency: Value(transaction.originalCurrency),
        eurAmountMicros: Value(transaction.eurAmountMicros),
        exchangeRateToEur: Value(transaction.exchangeRateToEur),
        receiptPath: Value(receiptPath),
        createdAt: Value(createdAt),
      ),
    );
    await ref.read(categoryProvider.notifier).markUsed(categoryId);

    final current = state.value ?? [];
    final updated = [...current, transaction];
    state = AsyncData(updated);
  }

  Future<void> restoreTransaction(TransactionModel tx) async {
    final db = ref.read(databaseProvider);

    await db.insertTransaction(
      TransactionsCompanion.insert(
        id: tx.id,
        amountCents: tx.amountCents,
        isIncome: tx.isIncome,
        categoryId: tx.categoryId,
        date: tx.date,
        note: Value(tx.note),
        isRecurring: Value(tx.isRecurring),
        originalAmountMinor: Value(tx.originalAmountMinor),
        originalCurrency: Value(tx.originalCurrency),
        eurAmountMicros: Value(tx.eurAmountMicros),
        exchangeRateToEur: Value(tx.exchangeRateToEur),
        receiptPath: Value(tx.receiptPath),
        createdAt: Value(tx.createdAt),
        recurringSourceId: Value(tx.recurringSourceId),
        recurringOccurrenceKey: Value(tx.recurringOccurrenceKey),
      ),
    );

    final current = state.value ?? [];
    final updated = [...current, tx];
    state = AsyncData(updated);
  }

  Future<void> addRecurringTransaction({
    required int amountCents,
    required bool isIncome,
    required String categoryId,
    required int dayOfMonth,
    required DateTime startDate,
    String? note,
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

    await db.insertRecurringTransaction(
      amountCents: conversion.baseAmountMinor,
      isIncome: isIncome,
      categoryId: categoryId,
      dayOfMonth: dayOfMonth,
      startDate: startDate,
      note: note,
      originalAmountMinor: conversion.originalAmountMinor,
      originalCurrency: conversion.originalCurrency,
      eurAmountMicros: conversion.eurAmountMicros,
      exchangeRateToEur: conversion.exchangeRateToEur,
      frequency: frequency,
      interval: interval,
      dayOfWeek: dayOfWeek,
      monthOfYear: monthOfYear,
      endDate: endDate,
    );
    await ref.read(categoryProvider.notifier).markUsed(categoryId);
  }

  Future<void> deleteTransaction(String id) async {
    final db = ref.read(databaseProvider);

    await db.deleteTransactionById(id);

    final current = state.value ?? [];
    final updated = current.where((t) => t.id != id).toList();
    state = AsyncData(updated);
  }

  Future<void> updateTransaction({
    required String id,
    required int amountCents,
    required bool isIncome,
    required String categoryId,
    required DateTime date,
    String? note,
    String? currencyCode,
    String? receiptPath,
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

    await db.updateTransaction(
      id: id,
      amountCents: conversion.baseAmountMinor,
      isIncome: isIncome,
      categoryId: categoryId,
      date: date,
      note: note,
      originalAmountMinor: conversion.originalAmountMinor,
      originalCurrency: conversion.originalCurrency,
      eurAmountMicros: conversion.eurAmountMicros,
      exchangeRateToEur: conversion.exchangeRateToEur,
      receiptPath: receiptPath,
    );
    await ref.read(categoryProvider.notifier).markUsed(categoryId);

    final current = state.value ?? [];

    final updated = current.map((t) {
      if (t.id == id) {
        return TransactionModel(
          id: id,
          amountCents: conversion.baseAmountMinor,
          isIncome: isIncome,
          categoryId: categoryId,
          date: date,
          note: note,
          isRecurring: t.isRecurring,
          originalAmountMinor: conversion.originalAmountMinor,
          originalCurrency: conversion.originalCurrency,
          eurAmountMicros: conversion.eurAmountMicros,
          exchangeRateToEur: conversion.exchangeRateToEur,
          receiptPath: receiptPath,
          createdAt: t.createdAt,
          recurringSourceId: t.recurringSourceId,
          recurringOccurrenceKey: t.recurringOccurrenceKey,
        );
      }
      return t;
    }).toList();

    state = AsyncData(updated);
  }

  /// DELETE ALL DATA
  Future<void> deleteAllData() async {
    final db = ref.read(databaseProvider);
    final receiptPaths = (state.value ?? const [])
        .map((transaction) => transaction.receiptPath)
        .whereType<String>()
        .toSet();

    await db.clearAllData();
    final receiptStorage = ref.read(receiptStorageServiceProvider);
    for (final path in receiptPaths) {
      await receiptStorage.remove(path);
    }
    ref.invalidate(categoryProvider);
    ref.invalidate(recurringProvider);

    state = const AsyncData([]);
  }
}

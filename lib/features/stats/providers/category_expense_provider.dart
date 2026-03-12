import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../transactions/providers/transaction_provider.dart';
import '../../transactions/providers/category_provider.dart';
import '../../transactions/domain/category.dart';
import '../../transactions/domain/transaction.dart';
import 'package:flutter/material.dart';

class CategoryExpense {
  final Category category;
  final int amount;

  const CategoryExpense({required this.category, required this.amount});
}

final categoryExpenseProvider = Provider<List<CategoryExpense>>((ref) {
  final transactionsAsync = ref.watch(transactionProvider);
  final categoriesAsync = ref.watch(categoryProvider);

  final List<Category> categories = categoriesAsync.value ?? [];

  final transactions = transactionsAsync.value ?? const <TransactionModel>[];

  final Map<String, int> totals = {};

  for (final tx in transactions) {
    if (!tx.isIncome) {
      totals[tx.categoryId] = (totals[tx.categoryId] ?? 0) + tx.amountCents;
    }
  }

  return totals.entries.map((entry) {
    final category = categories.firstWhere(
      (c) => c.id == entry.key,
      orElse: () => categories.first,
    );

    return CategoryExpense(category: category, amount: entry.value);
  }).toList();
});

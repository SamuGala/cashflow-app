import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../transactions/providers/transaction_provider.dart';
import '../../transactions/domain/transaction.dart';

final recentTransactionsProvider = Provider<List<TransactionModel>>((ref) {
  final transactionsAsync = ref.watch(transactionProvider);

  final transactions = transactionsAsync.value ?? const <TransactionModel>[];

  if (transactions.isEmpty) {
    return [];
  }

  final sorted = [...transactions]
    ..sort((a, b) => b.date.compareTo(a.date));

  return sorted.take(5).toList();
});
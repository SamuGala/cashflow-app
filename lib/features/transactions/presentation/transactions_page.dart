import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../providers/transactions_month_provider.dart';
import '../domain/transaction.dart';
import 'add_transaction_page.dart';
import '../providers/transaction_provider.dart';
import '../providers/category_provider.dart';
import '../providers/search_provider.dart';
import '../../transactions/domain/category.dart';
import '../../../l10n/app_localizations.dart';

class TransactionsPage extends ConsumerWidget {
  const TransactionsPage({super.key});

  void _openAddTransaction(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (_, __, ___) => const AddTransactionPage(),
        transitionsBuilder: (_, animation, __, child) {
          return SlideTransition(
            position: Tween(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;

    final searchQuery = ref.watch(transactionSearchProvider);
    final transactionsAsync = ref.watch(transactionProvider);
    final categoriesAsync = ref.watch(categoryProvider);

    final categories = categoriesAsync.value ?? [];
    final selectedMonth = ref.watch(transactionsMonthProvider);

    final currency = NumberFormat.currency(locale: 'it_IT', symbol: '€');
    final dateFormat = DateFormat('d MMMM yyyy', 'it_IT');

    return Scaffold(
      appBar: AppBar(
        title: Text(
          t.transactions,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAddTransaction(context),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          /// MONTH FILTER
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () {
                    final prev = DateTime(
                      selectedMonth.year,
                      selectedMonth.month - 1,
                    );
                    ref.read(transactionsMonthProvider.notifier).setMonth(prev);
                  },
                ),
                Text(
                  DateFormat('MMMM yyyy', 'it_IT').format(selectedMonth),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () {
                    final next = DateTime(
                      selectedMonth.year,
                      selectedMonth.month + 1,
                    );
                    ref.read(transactionsMonthProvider.notifier).setMonth(next);
                  },
                ),
              ],
            ),
          ),

          /// SEARCH
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              onChanged: (value) {
                ref.read(transactionSearchProvider.notifier).setQuery(value);
              },
              decoration: InputDecoration(
                hintText: t.lfTransactions,
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),

          Expanded(
            child: transactionsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text(error.toString())),
              data: (transactions) {
                final filteredMonth = transactions.where((tx) {
                  return tx.date.month == selectedMonth.month &&
                      tx.date.year == selectedMonth.year;
                }).toList();

                final sorted = [...filteredMonth]
                  ..sort((a, b) => b.date.compareTo(a.date));

                final filtered = sorted.where((tx) {
                  final category = categories.firstWhere(
                    (c) => c.id == tx.categoryId,
                    orElse: () => Category(
                      id: tx.categoryId,
                      name: t.categoryRemoved,
                      isIncome: tx.isIncome,
                      icon: Icons.help.codePoint,
                      color: Colors.grey.value,
                      isDefault: false,
                    ),
                  );

                  final query = searchQuery.toLowerCase();

                  return category.name.toLowerCase().contains(query) ||
                      (tx.note ?? '').toLowerCase().contains(query);
                }).toList();

                if (filtered.isEmpty) {
                  return Center(child: Text(t.noTransactions));
                }

                final Map<DateTime, List<TransactionModel>> grouped = {};

                for (final tx in filtered) {
                  final day = DateTime(
                    tx.date.year,
                    tx.date.month,
                    tx.date.day,
                  );
                  grouped.putIfAbsent(day, () => []);
                  grouped[day]!.add(tx);
                }

                final dates = grouped.keys.toList()
                  ..sort((a, b) => b.compareTo(a));

                return ListView(
                  children: dates.map((date) {
                    final items = grouped[date]!;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
                          child: Text(
                            dateFormat.format(date),
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),

                        ...items.map((tx) {
                          final category = categories.firstWhere(
                            (c) => c.id == tx.categoryId,
                            orElse: () => Category(
                              id: tx.categoryId,
                              name: t.categoryRemoved,
                              isIncome: tx.isIncome,
                              icon: Icons.help.codePoint,
                              color: Colors.grey.value,
                              isDefault: false,
                            ),
                          );

                          final amount = currency.format(tx.amountCents / 100);

                          return Dismissible(
                            key: ValueKey(tx.id),
                            direction: DismissDirection.endToStart,

                            background: Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 6,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(18),
                              ),
                              alignment: Alignment.centerRight,
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                            ),

                            confirmDismiss: (_) async {
                              return await showDialog(
                                context: context,
                                builder: (dialogContext) {
                                  return AlertDialog(
                                    title: Text(t.removeTransactionQ),
                                    content: Text(
                                      t.youSure,
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(dialogContext, false),
                                        child: Text(t.cancel),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(dialogContext, true),
                                        child: Text(t.delete),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },

                            onDismissed: (_) {
                              ref
                                  .read(transactionProvider.notifier)
                                  .deleteTransaction(tx.id);

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(t.transactionDeleted),
                                  action: SnackBarAction(
                                    label: "UNDO",
                                    onPressed: () {
                                      ref
                                          .read(transactionProvider.notifier)
                                          .addTransaction(
                                            amountCents: tx.amountCents,
                                            isIncome: tx.isIncome,
                                            categoryId: tx.categoryId,
                                            date: tx.date,
                                            note: tx.note,
                                          );
                                    },
                                  ),
                                ),
                              );
                            },

                            child: Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 6,
                              ),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    height: 42,
                                    width: 42,
                                    decoration: BoxDecoration(
                                      color: Color(
                                        category.color,
                                      ).withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      IconData(
                                        category.icon,
                                        fontFamily: 'MaterialIcons',
                                      ),
                                      color: Color(category.color),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          category.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                        Text(
                                          tx.note ?? "",
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '${tx.isIncome ? '+' : '-'} $amount',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14,
                                      color: tx.isIncome
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ],
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../providers/transaction_provider.dart';
import '../providers/category_provider.dart';
import '../providers/search_provider.dart';

import '../domain/transaction.dart';
import '../../transactions/domain/category.dart';

import 'add_transaction_page.dart';
import 'recurring_list.dart';

import '../../../l10n/app_localizations.dart';
import '../../../core/utils/category_localization.dart';
import '../../dashboard/widgets/revolut_month_selector.dart';
import '../../../core/providers/time_filter_provider.dart';

class TransactionsPage extends ConsumerStatefulWidget {
  const TransactionsPage({super.key});

  @override
  ConsumerState<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends ConsumerState<TransactionsPage> {
  final FocusNode searchFocus = FocusNode();
  bool showRecurring = false;
  final TextEditingController searchController = TextEditingController();
  String query = "";

  @override
  Widget build(BuildContext context) {
    final timeState = ref.watch(timeFilterProvider);

    final timeFilter = timeState.filter;
    final selectedMonth = timeState.month;

    final selectedRange = timeState.start != null && timeState.end != null
        ? DateTimeRange(start: timeState.start!, end: timeState.end!)
        : null;
    final t = AppLocalizations.of(context)!;

    final transactionsAsync = ref.watch(transactionProvider);
    final categoriesAsync = ref.watch(categoryProvider);

    final categories = categoriesAsync.value ?? [];

    final locale = Localizations.localeOf(context).toString();

    final currency = NumberFormat.currency(
      locale: locale,
      symbol: NumberFormat.simpleCurrency(locale: locale).currencySymbol,
    );

    final dateFormat = DateFormat.yMMMMd(locale);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            t.transactions,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
        ),
        body: Column(
          children: [
            /// TIME FILTER
            /// TIME FILTER
            if (!showRecurring)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: PremiumSegmentedSelector(
                  labels: [t.total, t.month, t.period],
                  selectedIndex: timeFilter.index,
                  onChanged: (index) async {
                    final selected = TimeFilter.values[index];

                    if (selected == TimeFilter.period) {
                      final range = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );

                      if (range != null) {
                        ref
                            .read(timeFilterProvider.notifier)
                            .setPeriod(range.start, range.end);
                      }

                      return;
                    }
                    ref.read(timeFilterProvider.notifier).setFilter(selected);
                  },
                ),
              ),
            if (!showRecurring && timeFilter == TimeFilter.month) ...[
              RevolutMonthSelector(
                initialDate: selectedMonth,
                onChanged: (date) {
                  ref.read(timeFilterProvider.notifier).setMonth(date);
                },
              ),
              const SizedBox(height: 10),
            ],

            if (!showRecurring && timeFilter == TimeFilter.period)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: GestureDetector(
                  onTap: () async {
                    final range = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                      initialDateRange: selectedRange,
                    );

                    if (range != null) {
                      ref
                          .read(timeFilterProvider.notifier)
                          .setPeriod(range.start, range.end);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_month),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            selectedRange == null
                                ? t.selectPeriod
                                : "${DateFormat.yMMM().format(selectedRange.start)} → "
                                      "${DateFormat.yMMM().format(selectedRange.end)}",
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        const Icon(Icons.expand_more),
                      ],
                    ),
                  ),
                ),
              ),

            /// SEGMENT SELECTOR
            Container(
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              width: double.infinity,
              child: SizedBox(
                width: double.infinity,
                child: SegmentedButton<bool>(
                  style: ButtonStyle(
                    minimumSize: const WidgetStatePropertyAll(
                      Size.fromHeight(48),
                    ),
                    shape: WidgetStatePropertyAll(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26),
                      ),
                    ),
                  ),
                  segments: [
                    ButtonSegment(value: false, label: Text(t.transactions)),
                    ButtonSegment(value: true, label: Text(t.recurrents)),
                  ],
                  selected: {showRecurring},
                  onSelectionChanged: (v) {
                    setState(() {
                      showRecurring = v.first;

                      if (showRecurring) {
                        searchController.clear();
                        query = "";
                      }
                    });
                  },
                ),
              ),
            ),
            if (!showRecurring) ...[
              Container(
                margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: TextField(
                  controller: searchController,
                  focusNode: searchFocus,
                  onChanged: (value) {
                    HapticFeedback.selectionClick();
                    setState(() {
                      query = value.toLowerCase();
                    });
                  },
                  decoration: InputDecoration(
                    hintText: t.searchBar,
                    prefixIcon: Icon(
                      Icons.search,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    suffixIcon: query.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              searchController.clear();
                              setState(() {
                                query = "";
                              });
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surfaceContainer,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(26),
                      borderSide: BorderSide(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.12),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(26),
                      borderSide: BorderSide(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.12),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(26),
                      borderSide: BorderSide(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.35),
                      ),
                    ),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 8),

            Expanded(
              child: showRecurring
                  ? const RecurringList()
                  : transactionsAsync.when(
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (error, stack) =>
                          Center(child: Text(error.toString())),
                      data: (transactions) {
                        final filteredTime = transactions.where((tx) {
                          if (timeFilter == TimeFilter.total) return true;

                          if (timeFilter == TimeFilter.month) {
                            return tx.date.month == selectedMonth.month &&
                                tx.date.year == selectedMonth.year;
                          }

                          if (timeFilter == TimeFilter.period &&
                              selectedRange != null) {
                            return tx.date.isAfter(
                                  selectedRange!.start.subtract(
                                    const Duration(days: 1),
                                  ),
                                ) &&
                                tx.date.isBefore(
                                  selectedRange!.end.add(
                                    const Duration(days: 1),
                                  ),
                                );
                          }

                          return true;
                        }).toList();

                        final sorted = [...filteredTime]
                          ..sort((a, b) => b.date.compareTo(a.date));

                        final filteredSearch = sorted.where((tx) {
                          if (query.isEmpty) return true;

                          final category = categories.firstWhere(
                            (c) => c.id == tx.categoryId,
                            orElse: () => categories.first,
                          );

                          final categoryNameTranslated = categoryName(
                            category.name,
                            t,
                          ).toLowerCase();

                          final note = (tx.note ?? "").toLowerCase();

                          return categoryNameTranslated.contains(query) ||
                              note.contains(query);
                        }).toList();

                        if (sorted.isEmpty) {
                          return Center(child: Text(t.noTransactions));
                        }

                        final Map<DateTime, List<TransactionModel>> grouped =
                            {};

                        for (final tx in sorted) {
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

                        final visibleDates = dates.where((date) {
                          final items = grouped[date]!
                              .where((tx) => filteredSearch.contains(tx))
                              .toList();

                          return items.isNotEmpty;
                        }).toList();

                        if (filteredSearch.isEmpty) {
                          return Center(child: Text(t.noTransactions));
                        }

                        return ListView(
                          keyboardDismissBehavior:
                              ScrollViewKeyboardDismissBehavior.onDrag,
                          children: visibleDates.map((date) {
                            final items = grouped[date]!
                                .where((tx) => filteredSearch.contains(tx))
                                .toList();

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    16,
                                    16,
                                    16,
                                    6,
                                  ),
                                  child: Text(
                                    dateFormat.format(date),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),

                                ...items.map((tx) {
                                  Category category;

                                  if (categories.isEmpty) {
                                    return const SizedBox();
                                  }

                                  category = categories.firstWhere(
                                    (c) => c.id == tx.categoryId,
                                    orElse: () => categories.first,
                                  );

                                  final amount = currency.format(
                                    tx.amountCents / 100,
                                  );

                                  return Dismissible(
                                    key: ValueKey(tx.id),
                                    direction: DismissDirection.horizontal,

                                    background: Container(
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 6,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.blue,
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                      alignment: Alignment.centerLeft,
                                      child: const Icon(
                                        Icons.edit,
                                        color: Colors.white,
                                      ),
                                    ),
                                    secondaryBackground: Container(
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

                                    confirmDismiss: (direction) async {
                                      if (direction ==
                                          DismissDirection.startToEnd) {
                                        Navigator.of(context).push(
                                          PageRouteBuilder(
                                            transitionDuration: const Duration(
                                              milliseconds: 300,
                                            ),
                                            pageBuilder: (_, __, ___) =>
                                                AddTransactionPage(
                                                  transaction: tx,
                                                ),
                                            transitionsBuilder:
                                                (_, animation, __, child) {
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
                                        return false;
                                      }

                                      return await showDialog<bool>(
                                        context: context,
                                        builder: (dialogContext) {
                                          return AlertDialog(
                                            title: Text(t.deleteMovement),
                                            content: Text(t.deleteMovementSure),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(
                                                  dialogContext,
                                                  false,
                                                ),
                                                child: Text(t.cancel),
                                              ),
                                              TextButton(
                                                onPressed: () => Navigator.pop(
                                                  dialogContext,
                                                  true,
                                                ),
                                                child: Text(t.delete),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },

                                    onDismissed: (_) {
                                      final deleted = tx;

                                      ref
                                          .read(transactionProvider.notifier)
                                          .deleteTransaction(tx.id);
                                    },

                                    child: _TransactionTile(
                                      tx: tx,
                                      category: category,
                                      amount: amount,
                                      t: t,
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
      ),
    );
  }
}

class _TransactionTile extends StatefulWidget {
  final TransactionModel tx;
  final Category category;
  final String amount;
  final AppLocalizations t;

  const _TransactionTile({
    required this.tx,
    required this.category,
    required this.amount,
    required this.t,
  });

  @override
  State<_TransactionTile> createState() => _TransactionTileState();
}

class _TransactionTileState extends State<_TransactionTile> {
  double scale = 1;

  void _press() => setState(() => scale = 0.95);
  void _release() => setState(() => scale = 1);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _press(),
      onTapCancel: _release,
      onTapUp: (_) => _release(),

      child: AnimatedScale(
        scale: scale,
        duration: const Duration(milliseconds: 120),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? Theme.of(context).colorScheme.surfaceContainer
                : Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              Container(
                height: 42,
                width: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Color(widget.category.color).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(
                      widget.category.isDefault
                          ? categoryIcon(widget.category.name)
                          : IconData(
                              widget.category.icon,
                              fontFamily: 'MaterialIcons',
                            ),
                      size: 24,
                      color: Color(widget.category.color),
                    ),
                    if (widget.tx.isRecurring)
                      Positioned(
                        right: -13,
                        bottom: -13,
                        child: Container(
                          height: 16,
                          width: 16,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.autorenew, size: 10),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      categoryName(widget.category.name, widget.t),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),

                    if (widget.tx.note != null && widget.tx.note!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey.withOpacity(0.15),
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            widget.tx.note!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              Text(
                '${widget.tx.isIncome ? '+' : '-'} ${widget.amount}',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  color: widget.tx.isIncome ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PremiumSegmentedSelector extends StatelessWidget {
  final List<String> labels;
  final int selectedIndex;
  final Function(int) onChanged;

  const PremiumSegmentedSelector({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: List.generate(labels.length, (index) {
          final active = selectedIndex == index;

          return Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                onChanged(index);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: active
                      ? Theme.of(context).colorScheme.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Text(
                  labels[index],
                  style: TextStyle(
                    color: active ? Colors.white : Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

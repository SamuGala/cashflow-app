import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/providers/balance_visibility_provider.dart';
import '../../../core/providers/selected_month_provider.dart';

import '../providers/dashboard_provider.dart';
import '../domain/dashboard_filter.dart';

import '../../transactions/providers/transaction_provider.dart';
import '../../transactions/providers/category_provider.dart';

import '../widgets/revolut_month_selector.dart';
import '../../../l10n/app_localizations.dart';
import '../../transactions/domain/category.dart';
import '../../../core/utils/category_localization.dart';
import '../../transactions/presentation/quick_add_transaction_sheet.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  DashboardFilter filter = DashboardFilter.total;

  bool showIncome = false;

  DateTime? customStart;
  DateTime? customEnd;

  int periodMonths = 6;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    final stats = ref.watch(
      dashboardProvider(
        DashboardQuery(filter: filter, start: customStart, end: customEnd),
      ),
    );
    final selectedMonth = ref.watch(selectedMonthProvider);
    final showBalance = ref.watch(balanceVisibilityProvider);

    final transactionsAsync = ref.watch(transactionProvider);
    final transactions = transactionsAsync.value ?? [];

    final categoriesAsync = ref.watch(categoryProvider);
    final List<Category> categories = categoriesAsync.value ?? [];

    final locale = Localizations.localeOf(context).toString();
    final currency = NumberFormat.currency(locale: locale, symbol: '€');

    String hide(String value) => showBalance ? value : "••••";

    double? savingPercent;
    String? insightMessage;
    bool expenseIncreased = false;

    /// Insight mese
    if (filter == DashboardFilter.month) {
      final lastMonth = DateTime(selectedMonth.year, selectedMonth.month - 1);

      final thisMonthExpense = transactions
          .where(
            (tx) =>
                !tx.isIncome &&
                tx.date.month == selectedMonth.month &&
                tx.date.year == selectedMonth.year,
          )
          .fold<int>(0, (sum, tx) => sum + tx.amountCents);

      final lastMonthExpense = transactions
          .where(
            (tx) =>
                !tx.isIncome &&
                tx.date.month == lastMonth.month &&
                tx.date.year == lastMonth.year,
          )
          .fold<int>(0, (sum, tx) => sum + tx.amountCents);

      if (lastMonthExpense > 0) {
        final diff = thisMonthExpense - lastMonthExpense;

        savingPercent = (diff.abs() / lastMonthExpense) * 100;
        expenseIncreased = diff > 0;

        insightMessage = expenseIncreased
            ? t.spentMore(savingPercent.toStringAsFixed(0))
            : t.savedMore(savingPercent.toStringAsFixed(0));
      }
    }

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        elevation: 2,
        child: const Icon(Icons.add),
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            showDragHandle: true,
            builder: (_) => const QuickAddTransactionSheet(),
          );
        },
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 50, 16, 20),
        children: [
          /// HEADER
          Row(
            children: [
              Text(
                t.appName,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: Icon(
                  showBalance ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  ref.read(balanceVisibilityProvider.notifier).toggle();
                },
              ),
            ],
          ),

          const SizedBox(height: 14),

          /// FILTER
          PremiumSegmentedSelector(
            labels: [t.total, t.month, t.period],
            selectedIndex: filter.index,
            onChanged: (index) {
              setState(() {
                filter = DashboardFilter.values[index];
              });
            },
          ),

          const SizedBox(height: 12),

          /// MONTH SELECTOR
          if (filter == DashboardFilter.month) ...[
            RevolutMonthSelector(
              initialDate: selectedMonth,
              onChanged: (date) {
                ref.read(selectedMonthProvider.notifier).state = date;
              },
            ),
            const SizedBox(height: 12),
          ],

          /// PERIOD SELECTOR
          if (filter == DashboardFilter.period) ...[
            PeriodSelector(
              start: customStart,
              end: customEnd,
              onChanged: (start, end) {
                setState(() {
                  customStart = start;
                  customEnd = end;
                });
              },
            ),
            const SizedBox(height: 12),
          ],

          /// BALANCE CARD
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xff6366F1), Color(0xff4F46E5)],
              ),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t.balance, style: const TextStyle(color: Colors.white70)),
                const SizedBox(height: 6),
                Text(
                  hide(currency.format(stats.balance / 100)),
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _StatBox(
                      label: t.income,
                      value: hide(currency.format(stats.income / 100)),
                      icon: Icons.arrow_upward,
                    ),
                    const SizedBox(width: 10),
                    _StatBox(
                      label: t.expense,
                      value: hide(currency.format(stats.expense / 100)),
                      icon: Icons.arrow_downward,
                    ),
                  ],
                ),
              ],
            ),
          ),

          if (filter == DashboardFilter.month && insightMessage != null)
            Container(
              margin: const EdgeInsets.only(top: 14),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: expenseIncreased
                    ? Colors.orange.withOpacity(.08)
                    : Colors.green.withOpacity(.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Icon(
                    expenseIncreased ? Icons.trending_up : Icons.trending_down,
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(insightMessage)),
                ],
              ),
            ),

          const SizedBox(height: 18),

          /// INCOME / EXPENSE TOGGLE
          Row(
            children: [
              ChoiceChip(
                label: Text(t.expenses),
                selected: !showIncome,
                onSelected: (_) => setState(() => showIncome = false),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: Text(t.incomes),
                selected: showIncome,
                onSelected: (_) => setState(() => showIncome = true),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Builder(
            builder: (_) {
              final Map<String, int> totals = {};

              for (final tx in transactions) {
                if (tx.isIncome != showIncome) continue;

                if (filter == DashboardFilter.month) {
                  if (tx.date.month != selectedMonth.month ||
                      tx.date.year != selectedMonth.year) {
                    continue;
                  }
                }

                if (filter == DashboardFilter.period &&
                    customStart != null &&
                    customEnd != null) {
                  if (tx.date.isBefore(customStart!) ||
                      tx.date.isAfter(customEnd!)) {
                    continue;
                  }
                }

                totals.update(
                  tx.categoryId,
                  (v) => v + tx.amountCents,
                  ifAbsent: () => tx.amountCents,
                );
              }

              final entries = totals.entries.toList()
                ..sort((a, b) => b.value.compareTo(a.value));

              if (entries.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(t.noTransactions),
                );
              }

              final totalExpense = entries.fold<int>(
                0,
                (sum, e) => sum + e.value,
              );

              return Column(
                children: entries.asMap().entries.map((entry) {
                  final index = entry.key;
                  final e = entry.value;

                  final category = categories.firstWhere(
                    (c) => c.id == e.key,
                    orElse: () => categories.first,
                  );

                  final amount = currency.format(e.value / 100);
                  final percent = e.value / totalExpense;

                  final topCategory = entries.first.key;

                  return TweenAnimationBuilder(
                    duration: Duration(milliseconds: 250 + index * 60),
                    tween: Tween(begin: 0.0, end: 1.0),
                    builder: (context, double value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, 16 * (1 - value)),
                          child: child,
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Theme.of(context).colorScheme.surfaceContainer
                            : Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                height: 44,
                                width: 44,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: category.id == topCategory
                                      ? Color(category.color).withOpacity(0.1)
                                      : Theme.of(context).colorScheme.surface,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Icon(
                                  category.isDefault
                                      ? categoryIcon(category.name)
                                      : IconData(
                                          category.icon,
                                          fontFamily: 'MaterialIcons',
                                        ),
                                  size: 28,
                                  color: Color(category.color),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  categoryName(category.name, t),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    hide(amount),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    "${(percent * 100).toStringAsFixed(0)}%",
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0, end: percent),
                              duration: const Duration(milliseconds: 700),
                              curve: Curves.easeOut,
                              builder: (context, value, _) {
                                return LinearProgressIndicator(
                                  value: value,
                                  minHeight: 7,
                                  backgroundColor: Colors.grey.withOpacity(
                                    0.15,
                                  ),
                                  valueColor: AlwaysStoppedAnimation(
                                    Color(category.color),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatBox({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.12),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Colors.white70)),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
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

class PeriodSelector extends StatelessWidget {
  final DateTime? start;
  final DateTime? end;
  final Function(DateTime, DateTime) onChanged;

  const PeriodSelector({
    super.key,
    required this.start,
    required this.end,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();

    String format(DateTime? d) {
      if (d == null) return "—";
      return DateFormat.yMMM(locale).format(d);
    }

    return GestureDetector(
      onTap: () async {
        final now = DateTime.now();

        final picked = await showDateRangePicker(
          context: context,
          firstDate: DateTime(now.year - 5),
          lastDate: DateTime(now.year + 1),
          initialDateRange: start != null && end != null
              ? DateTimeRange(start: start!, end: end!)
              : null,
        );

        if (picked != null) {
          onChanged(picked.start, picked.end);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            const Icon(Icons.date_range),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                "${format(start)}  →  ${format(end)}",
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            const Icon(Icons.expand_more),
          ],
        ),
      ),
    );
  }
}

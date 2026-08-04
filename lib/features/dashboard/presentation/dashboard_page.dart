import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/providers/balance_visibility_provider.dart';
import '../../../core/providers/time_filter_provider.dart';

import '../../transactions/providers/transaction_provider.dart';
import '../../transactions/providers/category_provider.dart';

import '../widgets/revolut_month_selector.dart';
import '../../../l10n/app_localizations.dart';
import '../../transactions/domain/category.dart';
import '../../../core/utils/category_localization.dart';
import '../../transactions/presentation/quick_add_transaction_sheet.dart';
import '../../../core/currency/currency_metadata.dart';
import '../../../core/currency/currency_provider.dart';
import '../../budgets/presentation/budget_card.dart';
import '../../goals/presentation/savings_goals_card.dart';
import '../../../shared/widgets/premium_segmented_selector.dart';
import '../../../core/receipts/receipt_scan_review_sheet.dart';
import '../../../core/receipts/receipt_capture_page.dart';
import '../../../core/receipts/receipt_scanner_service.dart';
import '../../../core/receipts/receipt_storage_service.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  bool showIncome = false;
  bool _isScanningReceipt = false;

  Future<void> _openQuickAdd({ReceiptScanReviewResult? receipt}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      useSafeArea: true,
      showDragHandle: false,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * .94,
      ),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 1,
        minChildSize: .32,
        maxChildSize: 1,
        shouldCloseOnMinExtent: true,
        builder: (_, scrollController) => QuickAddTransactionSheet(
          initialReceipt: receipt,
          scrollController: scrollController,
        ),
      ),
    );
  }

  Future<void> _scanReceipt() async {
    if (_isScanningReceipt) return;
    setState(() => _isScanningReceipt = true);
    final storage = ref.read(receiptStorageServiceProvider);
    try {
      final categories = await ref.read(categoryProvider.future);
      final fallbackCurrency =
          ref.read(currencyProvider).value?.baseCurrency ?? 'EUR';
      if (!mounted) return;
      final imagePath = await showReceiptCapture(
        context: context,
        storage: storage,
      );
      if (imagePath == null) return;
      final draft = await ref
          .read(receiptScannerServiceProvider)
          .scanStoredImage(
            imagePath: imagePath,
            categories: categories,
            fallbackCurrency: fallbackCurrency,
          );
      if (!mounted) {
        await storage.remove(draft.imagePath);
        return;
      }
      final reviewed = await showReceiptScanReview(
        context: context,
        draft: draft,
        categories: categories,
      );
      if (reviewed == null || !mounted) {
        await storage.remove(draft.imagePath);
        return;
      }
      await _openQuickAdd(receipt: reviewed);
    } on PlatformException catch (error) {
      if (!mounted) return;
      final t = AppLocalizations.of(context)!;
      final permissionDenied = error.code.toLowerCase().contains('denied');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            permissionDenied ? t.receiptPermissionDenied : t.cameraUnavailable,
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      final t = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.receiptAttachFailed)));
    } finally {
      if (mounted) setState(() => _isScanningReceipt = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    final timeState = ref.watch(timeFilterProvider);
    final filter = timeState.filter;
    final selectedMonth = timeState.month;
    final customStart = timeState.start;
    final customEnd = timeState.end;
    final showBalance = ref.watch(balanceVisibilityProvider);

    final transactionsAsync = ref.watch(transactionProvider);
    final transactions = transactionsAsync.value ?? [];

    final categoriesAsync = ref.watch(categoryProvider);
    final List<Category> categories = categoriesAsync.value ?? [];

    final locale = Localizations.localeOf(context).toString();
    final baseCurrency =
        ref.watch(currencyProvider).value?.baseCurrency ?? 'EUR';

    String hide(String value) => showBalance ? value : "••••";

    double? savingPercent;
    String? insightMessage;
    bool expenseIncreased = false;

    /// Insight mese
    if (filter == TimeFilter.month) {
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
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            key: const ValueKey('scan-receipt-button'),
            heroTag: 'scan-receipt',
            tooltip: t.scanReceipt,
            onPressed: _isScanningReceipt ? null : _scanReceipt,
            child: _isScanningReceipt
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2.4),
                  )
                : const Icon(Icons.photo_camera_outlined),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            key: const ValueKey('add-transaction-button'),
            heroTag: 'add-transaction',
            elevation: 2,
            tooltip: t.addTransaction,
            onPressed: () => _openQuickAdd(),
            child: const Icon(Icons.add),
          ),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            /// TIME FILTER
            PremiumSegmentedSelector(
              labels: [t.total, t.month, t.period],
              selectedIndex: filter.index,
              onChanged: (index) {
                final selected = TimeFilter.values[index];

                ref.read(timeFilterProvider.notifier).setFilter(selected);

                if (selected == TimeFilter.month) {
                  ref
                      .read(timeFilterProvider.notifier)
                      .setMonth(DateTime.now());
                }
              },
            ),

            const SizedBox(height: 14),

            /// MONTH SELECTOR
            if (filter == TimeFilter.month) ...[
              RevolutMonthSelector(
                initialDate: selectedMonth,
                onChanged: (date) {
                  ref.read(timeFilterProvider.notifier).setMonth(date);
                },
              ),
              const SizedBox(height: 14),
            ],

            /// PERIOD SELECTOR
            if (filter == TimeFilter.period) ...[
              PeriodSelector(
                start: customStart,
                end: customEnd,
                onChanged: (start, end) {
                  ref.read(timeFilterProvider.notifier).setPeriod(start, end);
                },
              ),
              const SizedBox(height: 14),
            ],

            const BudgetCard(),

            const SizedBox(height: 14),
            const SavingsGoalsCard(),

            if (filter == TimeFilter.month && insightMessage != null)
              Container(
                margin: const EdgeInsets.only(top: 14),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: expenseIncreased
                      ? Colors.orange.withValues(alpha: .08)
                      : Colors.green.withValues(alpha: .08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: (expenseIncreased ? Colors.orange : Colors.green)
                        .withValues(alpha: .18),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      expenseIncreased
                          ? Icons.trending_up
                          : Icons.trending_down,
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

                final filtered = transactions.where(
                  (tx) => isInSelectedTimeWindow(tx.date, timeState),
                );

                final filteredByType = filtered.where(
                  (tx) => tx.isIncome == showIncome,
                );

                for (final tx in filteredByType) {
                  totals.update(
                    tx.categoryId,
                    (v) => v + tx.amountCents,
                    ifAbsent: () => tx.amountCents,
                  );
                }

                final entries = totals.entries.toList()
                  ..removeWhere(
                    (entry) =>
                        !categories.any((category) => category.id == entry.key),
                  )
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

                    final amount = formatMoney(e.value, baseCurrency, locale);
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
                          border: Border.all(
                            color: Theme.of(
                              context,
                            ).colorScheme.outlineVariant.withValues(alpha: .65),
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  height: 46,
                                  width: 46,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: category.id == topCategory
                                        ? Color(
                                            category.color,
                                          ).withValues(alpha: 0.1)
                                        : Theme.of(context).colorScheme.surface,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Icon(
                                    category.isDefault
                                        ? categoryIcon(category.name)
                                        : customCategoryIcon(category.icon),
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
                                Text(
                                  hide(amount),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
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
                                    backgroundColor: Colors.grey.withValues(
                                      alpha: 0.15,
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
      return DateFormat.yMMMd(locale).format(d);
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

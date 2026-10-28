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
import '../../../shared/widgets/receipt_scan_icon.dart';
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
    final colors = Theme.of(context).colorScheme;

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

        final percent = hide(savingPercent.toStringAsFixed(0));
        insightMessage = savingPercent.round() == 0
            ? t.spentSameAsLastMonth
            : expenseIncreased
            ? t.spentMore(percent)
            : t.savedMore(percent);
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            onPressed: _isScanningReceipt ? null : _scanReceipt,
            child: _isScanningReceipt
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2.4),
                  )
                : const ReceiptScanIcon(),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            key: const ValueKey('add-transaction-button'),
            heroTag: 'add-transaction',
            elevation: 2,
            tooltip: t.addTransaction,
            onPressed: () => _openQuickAdd(),
            child: const Icon(Icons.add, size: 28),
          ),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 144),
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: colors.primaryContainer.withValues(alpha: .55),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.account_balance_wallet_outlined,
                    color: colors.primary,
                    size: 21,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    t.appName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -.4,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

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
                compact: true,
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
                // Keeps the message clear of the floating action buttons.
                padding: const EdgeInsets.fromLTRB(12, 12, 76, 12),
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
                      savingPercent!.round() == 0
                          ? Icons.trending_flat
                          : expenseIncreased
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
            Padding(
              padding: const EdgeInsets.only(right: 76),
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  Text(
                    filter == TimeFilter.month ? t.yourMonth : t.byCategory,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(
                    key: const ValueKey('category-flow-toggle'),
                    width: 142,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: colors.surfaceContainer,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            for (final income in [false, true])
                              Expanded(
                                child: Semantics(
                                  button: true,
                                  selected: showIncome == income,
                                  child: Material(
                                    color: showIncome == income
                                        ? colors.surface
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(9),
                                    clipBehavior: Clip.antiAlias,
                                    child: InkWell(
                                      onTap: () =>
                                          setState(() => showIncome = income),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 9,
                                        ),
                                        child: Text(
                                          income ? t.incomes : t.expenses,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: showIncome == income
                                                ? colors.onSurface
                                                : colors.onSurfaceVariant,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            Padding(
              padding: const EdgeInsets.only(right: 76),
              child: Builder(
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
                      (entry) => !categories.any(
                        (category) => category.id == entry.key,
                      ),
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

                      return _DashboardCategoryRow(
                        category: category,
                        label: categoryName(category.name, t),
                        amount: hide(amount),
                        ratio: percent,
                        index: index,
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

class _DashboardCategoryRow extends StatelessWidget {
  const _DashboardCategoryRow({
    required this.category,
    required this.label,
    required this.amount,
    required this.ratio,
    required this.index,
  });

  final Category category;
  final String label;
  final String amount;
  final double ratio;
  final int index;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return TweenAnimationBuilder<double>(
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : Duration(milliseconds: 250 + index * 40),
      tween: Tween(begin: 0, end: 1),
      builder: (_, value, child) => Opacity(opacity: value, child: child),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  height: 32,
                  width: 32,
                  decoration: BoxDecoration(
                    color: colors.surfaceContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    category.isDefault
                        ? categoryIcon(category.name)
                        : customCategoryIcon(category.icon),
                    size: 17,
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  flex: 3,
                  child: Text(
                    label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  flex: 2,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: Text(
                      amount,
                      key: ValueKey('category-total-${category.id}'),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 41, top: 5),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: ratio,
                  minHeight: 4,
                  color: colors.primary.withValues(alpha: .75),
                  backgroundColor: colors.surfaceContainer,
                ),
              ),
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
          firstDate: start != null && start!.isBefore(DateTime(now.year - 5))
              ? start!
              : DateTime(now.year - 5),
          lastDate: end != null && end!.isAfter(DateTime(now.year + 1))
              ? end!
              : DateTime(now.year + 1),
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

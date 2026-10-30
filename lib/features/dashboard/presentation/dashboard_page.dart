import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/providers/balance_visibility_provider.dart';
import '../../../core/providers/time_filter_provider.dart';

import '../../transactions/providers/transaction_provider.dart';
import '../../transactions/providers/category_provider.dart';

import '../../../l10n/app_localizations.dart';
import '../../transactions/domain/category.dart';
import '../../../core/utils/category_localization.dart';
import '../../transactions/presentation/quick_add_transaction_sheet.dart';
import '../../../core/currency/currency_metadata.dart';
import '../../../core/currency/currency_provider.dart';
import '../../budgets/presentation/budget_card.dart';
import '../../goals/presentation/savings_goals_card.dart';
import '../../../shared/widgets/vault_style.dart';
import '../../stats/widgets/stats_period_controls.dart';
import '../../../app/launch_actions.dart';
import '../../../core/security/auth_provider.dart';
import '../../recap/presentation/year_recap_entry.dart';
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

  @override
  void initState() {
    super.initState();
    launchActionChanges.addListener(_handleLaunchAction);
    WidgetsBinding.instance.addPostFrameCallback((_) => _handleLaunchAction());
  }

  @override
  void dispose() {
    launchActionChanges.removeListener(_handleLaunchAction);
    super.dispose();
  }

  /// Quick actions, the widget and notifications land here.
  void _handleLaunchAction() {
    // A page still on its way out after a lock must not take the action:
    // it belongs to the page shown after the PIN.
    if (!mounted || !ref.read(authProvider)) return;
    final action = takeLaunchAction(const {
      LaunchAction.addExpense,
      LaunchAction.addIncome,
      LaunchAction.scanReceipt,
      LaunchAction.openHome,
    });
    switch (action) {
      case LaunchAction.addExpense:
        _openQuickAdd();
      case LaunchAction.addIncome:
        _openQuickAdd(income: true);
      case LaunchAction.scanReceipt:
        _scanReceipt();
      case LaunchAction.openHome || LaunchAction.openRecurring || null:
        break;
    }
  }

  Future<void> _openQuickAdd({
    ReceiptScanReviewResult? receipt,
    bool income = false,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      // Above the navigation bar, so the pinned Save button is never covered.
      useRootNavigator: true,
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
          initialIncome: income,
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

    final expenseIncreasedColor = expenseIncreased
        ? VaultColors.expense(context)
        : VaultColors.income(context);

    return Scaffold(
      // The tab tint and wash are painted by the navigation shell.
      backgroundColor: Colors.transparent,
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            key: const ValueKey('scan-receipt-button'),
            heroTag: 'scan-receipt',
            tooltip: t.scanReceipt,
            backgroundColor: colors.surface,
            foregroundColor: colors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: colors.outlineVariant),
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
          padding: const EdgeInsets.fromLTRB(16, 2, 16, 144),
          children: [
            VaultPageHeader(
              title: t.home,
              trailing: StatsGlobalPeriodButton(transactions: transactions),
            ),
            const SizedBox(height: 14),

            const YearRecapBanner(),
            const BudgetCard(),

            const SizedBox(height: 12),
            const SavingsGoalsCard(),

            if (filter == TimeFilter.month && insightMessage != null)
              Container(
                margin: const EdgeInsets.only(top: 12),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: expenseIncreasedColor.withValues(alpha: .07),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: expenseIncreasedColor.withValues(alpha: .16),
                    width: .7,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: expenseIncreasedColor.withValues(alpha: .12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        savingPercent!.round() == 0
                            ? Icons.trending_flat_rounded
                            : expenseIncreased
                            ? Icons.trending_up_rounded
                            : Icons.trending_down_rounded,
                        size: 17,
                        color: expenseIncreasedColor,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        insightMessage,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 12),

            /// CATEGORY BREAKDOWN
            VaultSurface(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          filter == TimeFilter.month
                              ? t.yourMonth
                              : t.byCategory,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -.3,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _FlowToggle(
                        key: const ValueKey('category-flow-toggle'),
                        income: showIncome,
                        onChanged: (income) =>
                            setState(() => showIncome = income),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
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
                          (entry) => !categories.any(
                            (category) => category.id == entry.key,
                          ),
                        )
                        ..sort((a, b) => b.value.compareTo(a.value));

                      if (entries.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          child: Center(
                            child: Text(
                              t.noTransactions,
                              style: TextStyle(color: colors.onSurfaceVariant),
                            ),
                          ),
                        );
                      }

                      final totalAmount = entries.fold<int>(
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

                          final amount = formatMoney(
                            e.value,
                            baseCurrency,
                            locale,
                          );
                          final ratio = e.value / totalAmount;

                          return _DashboardCategoryRow(
                            category: category,
                            label: categoryName(category.name, t),
                            amount: hide(amount),
                            percent: hide(
                              NumberFormat.decimalPercentPattern(
                                locale: locale,
                                decimalDigits: 0,
                              ).format(ratio),
                            ),
                            ratio: showBalance ? ratio : 0,
                            index: index,
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FlowToggle extends StatelessWidget {
  const _FlowToggle({super.key, required this.income, required this.onChanged});

  final bool income;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 170),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surfaceContainer,
          borderRadius: BorderRadius.circular(11),
        ),
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: IntrinsicHeight(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final value in [false, true])
                  Flexible(
                    child: Semantics(
                      button: true,
                      selected: income == value,
                      child: Material(
                        color: income == value
                            ? colors.surface
                            : Colors.transparent,
                        elevation: income == value ? .5 : 0,
                        borderRadius: BorderRadius.circular(9),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () => onChanged(value),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 7,
                            ),
                            child: Text(
                              value ? t.incomes : t.expenses,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: income == value
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                                color: income == value
                                    ? VaultColors.flow(context, value)
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
    );
  }
}

class _DashboardCategoryRow extends StatelessWidget {
  const _DashboardCategoryRow({
    required this.category,
    required this.label,
    required this.amount,
    required this.percent,
    required this.ratio,
    required this.index,
  });

  final Category category;
  final String label;
  final String amount;
  final String percent;
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
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          border: index == 0
              ? null
              : Border(
                  top: BorderSide(color: colors.outlineVariant, width: .5),
                ),
        ),
        child: Row(
          children: [
            CategoryAvatar(category: category, size: 40),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          label,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Flexible(
                        flex: 2,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerRight,
                            child: Text(
                              amount,
                              key: ValueKey('category-total-${category.id}'),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                fontFeatures: [FontFeature.tabularFigures()],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 7),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: ratio,
                            minHeight: 6,
                            color: Color(category.color),
                            backgroundColor: colors.surfaceContainerHighest,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        width: 38,
                        child: Text(
                          percent,
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 12,
                            color: colors.onSurfaceVariant,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

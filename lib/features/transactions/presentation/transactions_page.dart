import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/input_formatters/capitalize_first_letter_formatter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../app/launch_actions.dart';
import '../../../core/security/auth_provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/category_provider.dart';

import '../domain/movement_filters.dart';
import '../domain/transaction.dart';
import '../../transactions/domain/category.dart';

import 'add_transaction_page.dart';
import 'movement_filters_sheet.dart';
import 'recurring_list.dart';

import '../../../l10n/app_localizations.dart';
import '../../../core/utils/category_localization.dart';
import '../../../core/providers/time_filter_provider.dart';
import '../../../core/currency/currency_metadata.dart';
import '../../../core/currency/currency_provider.dart';
import '../../../core/receipts/receipt_storage_service.dart';
import '../../../shared/widgets/vault_dialogs.dart';
import '../../../shared/widgets/vault_style.dart';
import '../../stats/widgets/stats_period_controls.dart';
import '../../../shared/widgets/inline_load_error.dart';

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
  MovementFilters filters = MovementFilters.none;

  /// Movements of the shared period that match the search, newest first:
  /// the pool the filters apply to.
  List<TransactionModel> _pool(
    List<TransactionModel> transactions,
    List<Category> categories,
    TimeFilterState timeState,
    AppLocalizations t,
  ) {
    final filteredTime = transactions.where((tx) {
      switch (timeState.filter) {
        case TimeFilter.total:
          return true;
        case TimeFilter.month:
          return tx.date.month == timeState.month.month &&
              tx.date.year == timeState.month.year;
        case TimeFilter.period:
          if (timeState.start == null || timeState.end == null) return true;
          return isInSelectedTimeWindow(tx.date, timeState);
      }
    }).toList()..sort((a, b) => b.date.compareTo(a.date));
    if (query.isEmpty || categories.isEmpty) return filteredTime;
    return filteredTime.where((tx) {
      final category = categories.firstWhere(
        (c) => c.id == tx.categoryId,
        orElse: () => categories.first,
      );
      final categoryNameTranslated = categoryName(
        category.name,
        t,
      ).toLowerCase();
      final note = (tx.note ?? "").toLowerCase();
      return categoryNameTranslated.contains(query) || note.contains(query);
    }).toList();
  }

  Future<void> _openFilters(
    List<TransactionModel> pool,
    List<Category> categories,
    String baseCurrency,
  ) async {
    FocusScope.of(context).unfocus();
    final next = await showMovementFiltersSheet(
      context,
      initial: filters,
      pool: pool,
      categories: categories,
      baseCurrency: baseCurrency,
    );
    if (next != null && mounted) setState(() => filters = next);
  }

  @override
  void initState() {
    super.initState();
    launchActionChanges.addListener(_handleLaunchAction);
    WidgetsBinding.instance.addPostFrameCallback((_) => _handleLaunchAction());
  }

  /// A tapped recurrence reminder opens the Recurring tab.
  void _handleLaunchAction() {
    // A page still on its way out after a lock must not take the action:
    // it belongs to the page shown after the PIN.
    if (!mounted || !ref.read(authProvider)) return;
    if (takeLaunchAction(const {LaunchAction.openRecurring}) == null) return;
    setState(() {
      showRecurring = true;
      searchController.clear();
      query = "";
    });
  }

  @override
  void dispose() {
    launchActionChanges.removeListener(_handleLaunchAction);
    searchFocus.dispose();
    searchController.dispose();
    super.dispose();
  }

  Future<bool?> _confirmDismiss(
    DismissDirection direction,
    TransactionModel tx,
  ) async {
    if (direction == DismissDirection.startToEnd) {
      Navigator.of(context).push(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 300),
          pageBuilder: (_, _, _) => AddTransactionPage(transaction: tx),
          transitionsBuilder: (_, animation, _, child) => SlideTransition(
            position: Tween(begin: const Offset(0, 1), end: Offset.zero)
                .animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                ),
            child: child,
          ),
        ),
      );
      return false;
    }
    final t = AppLocalizations.of(context)!;
    return showVaultDeleteDialog(
      context,
      title: t.deleteMovement,
      message: t.deleteMovementSure,
    );
  }

  Future<void> _delete(TransactionModel tx) async {
    final t = AppLocalizations.of(context)!;
    await ref.read(transactionProvider.notifier).deleteTransaction(tx.id);

    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    final snackbar = messenger.showSnackBar(
      SnackBar(
        content: Text(t.transactionDeleted),
        action: SnackBarAction(
          label: t.undo,
          onPressed: () {
            unawaited(
              ref.read(transactionProvider.notifier).restoreTransaction(tx),
            );
          },
        ),
      ),
    );
    final closeReason = await snackbar.closed;
    if (closeReason != SnackBarClosedReason.action) {
      await ref.read(receiptStorageServiceProvider).remove(tx.receiptPath);
    }
  }

  Widget _searchField(ColorScheme colors, AppLocalizations t) {
    return TextField(
      controller: searchController,
      focusNode: searchFocus,
      textCapitalization: TextCapitalization.sentences,
      inputFormatters: const [CapitalizeFirstLetterFormatter()],
      onChanged: (value) {
        HapticFeedback.selectionClick();
        setState(() {
          query = value.toLowerCase();
        });
      },
      style: const TextStyle(fontSize: 15),
      decoration: InputDecoration(
        hintText: t.searchBar,
        isDense: true,
        prefixIcon: Icon(
          Icons.search_rounded,
          size: 21,
          color: colors.onSurfaceVariant,
        ),
        suffixIcon: query.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.close_rounded, size: 19),
                onPressed: () {
                  searchController.clear();
                  setState(() {
                    query = "";
                  });
                },
              )
            : null,
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colors.outlineVariant, width: .7),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colors.outlineVariant, width: .7),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colors.primary.withValues(alpha: .45)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final timeState = ref.watch(timeFilterProvider);

    final t = AppLocalizations.of(context)!;

    final transactionsAsync = ref.watch(transactionProvider);
    final categoriesAsync = ref.watch(categoryProvider);

    final categories = categoriesAsync.value ?? [];

    final locale = Localizations.localeOf(context).toString();

    final baseCurrency =
        ref.watch(currencyProvider).value?.baseCurrency ?? 'EUR';

    final dateFormat = DateFormat.MMMMEEEEd(locale);
    final yearDateFormat = DateFormat.yMMMMEEEEd(locale);
    final colors = Theme.of(context).colorScheme;

    String money(int minor) => formatMoney(minor, baseCurrency, locale);
    final pool = _pool(
      transactionsAsync.value ?? const [],
      categories,
      timeState,
      t,
    );

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        // The tab tint and wash are painted by the navigation shell.
        backgroundColor: Colors.transparent,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 2, 16, 0),
                child: Column(
                  children: [
                    VaultPageHeader(
                      title: t.transactions,
                      trailing: showRecurring
                          ? null
                          : StatsGlobalPeriodButton(
                              transactions:
                                  transactionsAsync.value ??
                                  const <TransactionModel>[],
                            ),
                    ),
                    const SizedBox(height: 5),
                    VaultTabs(
                      labels: [t.movementsHistory, t.recurrents],
                      selectedIndex: showRecurring ? 1 : 0,
                      keyPrefix: 'transactions-tab',
                      onChanged: (index) {
                        setState(() {
                          showRecurring = index == 1;

                          if (showRecurring) {
                            searchController.clear();
                            query = "";
                          }
                        });
                      },
                    ),
                  ],
                ),
              ),
              if (!showRecurring) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Row(
                    children: [
                      Expanded(child: _searchField(colors, t)),
                      const SizedBox(width: 8),
                      _FilterButton(
                        count: filters.activeCount,
                        tooltip: t.filters,
                        onPressed: () =>
                            _openFilters(pool, categories, baseCurrency),
                      ),
                    ],
                  ),
                ),
                if (!filters.isEmpty)
                  _ActiveFilters(
                    filters: filters,
                    categories: categories,
                    money: money,
                    onChanged: (next) => setState(() => filters = next),
                  ),
              ],

              Expanded(
                child: showRecurring
                    ? const RecurringList()
                    : transactionsAsync.when(
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (_, _) => Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: InlineLoadError(
                              onRetry: () =>
                                  ref.invalidate(transactionProvider),
                            ),
                          ),
                        ),
                        data: (_) {
                          final filteredSearch = pool
                              .where(filters.matches)
                              .toList();

                          if (filteredSearch.isEmpty &&
                              !filters.isEmpty &&
                              pool.isNotEmpty &&
                              categories.isNotEmpty) {
                            return _EmptyMovements(
                              message: t.filterNoResults,
                              actionLabel: t.filterClear,
                              onAction: () => setState(
                                () => filters = MovementFilters.none,
                              ),
                            );
                          }

                          if (filteredSearch.isEmpty || categories.isEmpty) {
                            return _EmptyMovements(message: t.noTransactions);
                          }

                          final Map<DateTime, List<TransactionModel>> grouped =
                              {};

                          for (final tx in filteredSearch) {
                            final day = DateTime(
                              tx.date.year,
                              tx.date.month,
                              tx.date.day,
                            );
                            grouped.putIfAbsent(day, () => []).add(tx);
                          }

                          final dates = grouped.keys.toList()
                            ..sort((a, b) => b.compareTo(a));

                          final now = DateTime.now();

                          return ListView(
                            keyboardDismissBehavior:
                                ScrollViewKeyboardDismissBehavior.onDrag,
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
                            children: [
                              for (final date in dates) ...[
                                Builder(
                                  builder: (context) {
                                    final items = grouped[date]!;
                                    final net = items.fold<int>(
                                      0,
                                      (sum, tx) =>
                                          sum +
                                          (tx.isIncome
                                              ? tx.amountCents
                                              : -tx.amountCents),
                                    );
                                    return Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                        4,
                                        18,
                                        4,
                                        8,
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              toBeginningOfSentenceCase(
                                                (date.year == now.year
                                                        ? dateFormat
                                                        : yearDateFormat)
                                                    .format(date),
                                              ),
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                                color: colors.onSurfaceVariant,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            '${net > 0
                                                ? '+'
                                                : net < 0
                                                ? '−'
                                                : ''}${money(net.abs())}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              color: colors.onSurfaceVariant,
                                              fontFeatures: const [
                                                FontFeature.tabularFigures(),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                                VaultSurface(
                                  padding: EdgeInsets.zero,
                                  radius: 18,
                                  child: Column(
                                    children: [
                                      for (final (index, tx)
                                          in grouped[date]!.indexed)
                                        Dismissible(
                                          key: ValueKey(tx.id),
                                          direction:
                                              DismissDirection.horizontal,
                                          background: _SwipeBackground(
                                            color: colors.primary,
                                            icon: Icons.edit_outlined,
                                            label: t.modify,
                                            alignment: Alignment.centerLeft,
                                          ),
                                          secondaryBackground: _SwipeBackground(
                                            color: VaultColors.expense(context),
                                            icon: Icons.delete_outline_rounded,
                                            label: t.delete,
                                            alignment: Alignment.centerRight,
                                          ),
                                          confirmDismiss: (direction) =>
                                              _confirmDismiss(direction, tx),
                                          onDismissed: (_) => _delete(tx),
                                          child: _TransactionTile(
                                            tx: tx,
                                            category: categories.firstWhere(
                                              (c) => c.id == tx.categoryId,
                                              orElse: () => categories.first,
                                            ),
                                            amount: money(tx.amountCents),
                                            showDivider: index > 0,
                                            t: t,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                              Padding(
                                padding: const EdgeInsets.only(top: 18),
                                child: Text(
                                  t.swipeHint,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: colors.onSurfaceVariant.withValues(
                                      alpha: .8,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyMovements extends StatelessWidget {
  const _EmptyMovements({
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: .08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.receipt_long_outlined,
                color: colors.primary,
                size: 26,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.onSurfaceVariant),
            ),
            if (actionLabel != null) ...[
              const SizedBox(height: 12),
              OutlinedButton(
                key: const ValueKey('movement-filters-clear'),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: colors.outlineVariant),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({
    required this.count,
    required this.tooltip,
    required this.onPressed,
  });

  final int count;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final active = count > 0;
    return Tooltip(
      message: tooltip,
      child: Semantics(
        button: true,
        label: tooltip,
        value: active ? '$count' : null,
        child: Material(
          color: active ? colors.primary.withValues(alpha: .1) : colors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(
              color: active
                  ? colors.primary.withValues(alpha: .45)
                  : colors.outlineVariant,
              width: .7,
            ),
          ),
          child: InkWell(
            key: const ValueKey('movements-filter-button'),
            borderRadius: BorderRadius.circular(14),
            onTap: onPressed,
            child: SizedBox(
              width: 46,
              height: 46,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    Icons.tune_rounded,
                    size: 21,
                    color: active ? colors.primary : colors.onSurfaceVariant,
                  ),
                  if (active)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        key: const ValueKey('movements-filter-count'),
                        width: 16,
                        height: 16,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: colors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '$count',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: colors.onPrimary,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Removable chips for the filters in use, under the search field.
class _ActiveFilters extends StatelessWidget {
  const _ActiveFilters({
    required this.filters,
    required this.categories,
    required this.money,
    required this.onChanged,
  });

  final MovementFilters filters;
  final List<Category> categories;
  final String Function(int minor) money;
  final ValueChanged<MovementFilters> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final chips = <(String, String, MovementFilters)>[
      if (filters.flow != FlowFilter.all)
        (
          'flow',
          filters.flow == FlowFilter.income ? t.incomes : t.expenses,
          filters.copyWith(flow: FlowFilter.all),
        ),
      if (filters.categoryIds.isNotEmpty)
        (
          'categories',
          filters.categoryIds.length == 1
              ? categoryName(
                  categories
                          .where((c) => c.id == filters.categoryIds.first)
                          .firstOrNull
                          ?.name ??
                      filters.categoryIds.first,
                  t,
                )
              : t.filterCategoriesCount(filters.categoryIds.length),
          filters.copyWith(categoryIds: const {}),
        ),
      if (filters.hasAmount)
        (
          'amount',
          filters.minAmount == null
              ? '≤ ${money(filters.maxAmount!)}'
              : filters.maxAmount == null
              ? '≥ ${money(filters.minAmount!)}'
              : '${money(filters.minAmount!)} – ${money(filters.maxAmount!)}',
          filters.withoutAmount(),
        ),
      if (filters.currencies.isNotEmpty)
        (
          'currency',
          (filters.currencies.toList()..sort()).join(', '),
          filters.copyWith(currencies: const {}),
        ),
      if (filters.receipt != ReceiptFilter.any)
        (
          'receipt',
          filters.receipt == ReceiptFilter.withReceipt
              ? t.filterWithReceipt
              : t.filterWithoutReceipt,
          filters.copyWith(receipt: ReceiptFilter.any),
        ),
    ];
    final colors = Theme.of(context).colorScheme;
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        itemCount: chips.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final (kind, label, without) = chips[index];
          return Material(
            key: ValueKey('movement-filter-chip-$kind'),
            color: colors.primary.withValues(alpha: .1),
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                HapticFeedback.selectionClick();
                onChanged(without);
              },
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 8, 0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: colors.primary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.close_rounded,
                      size: 16,
                      color: colors.primary,
                      semanticLabel: MaterialLocalizations.of(
                        context,
                      ).deleteButtonTooltip,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SwipeBackground extends StatelessWidget {
  const _SwipeBackground({
    required this.color,
    required this.icon,
    required this.label,
    required this.alignment,
  });

  final Color color;
  final IconData icon;
  final String label;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    // Icon only: the label would duplicate the confirmation buttons.
    final content = [
      Semantics(
        label: label,
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    ];
    return Container(
      color: color,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      alignment: alignment,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: alignment == Alignment.centerLeft
            ? content
            : content.reversed.toList(),
      ),
    );
  }
}

class _TransactionTile extends StatefulWidget {
  final TransactionModel tx;
  final Category category;
  final String amount;
  final bool showDivider;
  final AppLocalizations t;

  const _TransactionTile({
    required this.tx,
    required this.category,
    required this.amount,
    required this.showDivider,
    required this.t,
  });

  @override
  State<_TransactionTile> createState() => _TransactionTileState();
}

class _TransactionTileState extends State<_TransactionTile> {
  bool pressed = false;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final note = widget.tx.note;
    final flowColor = VaultColors.flow(context, widget.tx.isIncome);
    return Material(
      color: pressed
          ? colors.primary.withValues(alpha: .05)
          : colors.surface.withValues(alpha: 0),
      child: InkWell(
        onHighlightChanged: (value) => setState(() => pressed = value),
        onTap: widget.tx.receiptPath == null
            ? null
            : () => showDialog<void>(
                context: context,
                builder: (dialogContext) => Dialog(
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    children: [
                      InteractiveViewer(
                        child: Image.file(
                          File(widget.tx.receiptPath!),
                          fit: BoxFit.contain,
                          errorBuilder: (_, _, _) => const SizedBox(
                            height: 240,
                            child: Center(
                              child: Icon(Icons.broken_image_outlined),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: IconButton.filled(
                          onPressed: () => Navigator.pop(dialogContext),
                          icon: const Icon(Icons.close),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            border: widget.showDivider
                ? Border(
                    top: BorderSide(color: colors.outlineVariant, width: .5),
                  )
                : null,
          ),
          child: Row(
            children: [
              CategoryAvatar(
                category: widget.category,
                size: 42,
                badge: widget.tx.isRecurring ? Icons.autorenew_rounded : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      categoryName(widget.category.name, widget.t),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    if (note != null && note.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          note,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${widget.tx.isIncome ? '+' : '−'}${widget.amount}',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: flowColor,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  if (widget.tx.receiptPath != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: Icon(
                        Icons.receipt_long_outlined,
                        size: 15,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

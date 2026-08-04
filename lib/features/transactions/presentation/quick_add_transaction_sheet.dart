import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../providers/transaction_provider.dart';
import '../providers/category_provider.dart';
import '../providers/recurring_provider.dart';
import '../domain/category.dart';
import 'add_category_dialog.dart';

import '../../../core/utils/category_localization.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/input_formatters/capitalize_first_letter_formatter.dart';
import '../../../core/currency/currency_metadata.dart';
import '../../../core/currency/currency_provider.dart';
import '../../../core/currency/currency_selector.dart';
import '../domain/recurrence_calculator.dart';
import '../../../core/receipts/receipt_storage_service.dart';
import '../../../core/receipts/receipt_scan_review_sheet.dart';

class QuickAddTransactionSheet extends ConsumerStatefulWidget {
  const QuickAddTransactionSheet({
    super.key,
    this.initialReceipt,
    this.scrollController,
  });

  final ReceiptScanReviewResult? initialReceipt;
  final ScrollController? scrollController;

  @override
  ConsumerState<QuickAddTransactionSheet> createState() =>
      _QuickAddTransactionSheetState();
}

class _QuickAddTransactionSheetState
    extends ConsumerState<QuickAddTransactionSheet> {
  int amountMinor = 0;
  bool shake = false;
  final noteController = TextEditingController();

  Category? selectedCategory;

  bool recurring = false;
  int recurringDay = DateTime.now().day;
  RecurrenceFrequency recurringFrequency = RecurrenceFrequency.monthly;
  int recurringInterval = 1;
  DateTime? recurringEndDate;

  bool isIncome = false;
  bool showKeypad = false;

  DateTime selectedDate = DateTime.now();
  String? selectedCurrency;
  String? receiptPath;
  bool _receiptCommitted = false;
  String? _pendingCategoryId;
  double _dismissDragDistance = 0;
  bool _isDismissing = false;

  @override
  void initState() {
    super.initState();
    final scanned = widget.initialReceipt;
    if (scanned == null) return;
    receiptPath = scanned.draft.imagePath;
    if (!scanned.appliesDetectedData) return;
    final extraction = scanned.draft.extraction;
    if (extraction == null) return;
    isIncome = false;
    selectedCurrency = extraction.currencyCode;
    amountMinor = extraction.amountMinor ?? 0;
    selectedDate = extraction.date ?? selectedDate;
    _pendingCategoryId = extraction.categoryId;
    noteController.text = extraction.merchant ?? '';
  }

  @override
  void dispose() {
    final uncommittedReceipt = receiptPath;
    if (!_receiptCommitted && uncommittedReceipt != null) {
      unawaited(
        File(
          uncommittedReceipt,
        ).delete().catchError((_) => File(uncommittedReceipt)),
      );
    }
    noteController.dispose();
    super.dispose();
  }

  void _addDigit(String digit) {
    _addDigits(digit);
  }

  void _addDigits(String digits) {
    setState(() {
      var next = amountMinor;
      for (final digit in digits.split('')) {
        if (next.toString().length >= 9 && next != 0) break;
        next = (next * 10) + int.parse(digit);
      }
      amountMinor = next;
    });
  }

  void _deleteDigit() {
    setState(() {
      amountMinor ~/= 10;
    });
  }

  void _clearAmount() {
    if (amountMinor == 0) return;
    setState(() => amountMinor = 0);
  }

  void _triggerShake() {
    setState(() => shake = true);

    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        setState(() => shake = false);
      }
    });
  }

  void _dismissFromDrag() {
    if (_isDismissing || !mounted) return;
    _isDismissing = true;
    Navigator.of(context).maybePop();
  }

  void _updateDismissDrag(DragUpdateDetails details) {
    if (_isDismissing) return;
    _dismissDragDistance = (_dismissDragDistance + details.delta.dy).clamp(
      0,
      120,
    );
    if (_dismissDragDistance >= 72) _dismissFromDrag();
  }

  void _endDismissDrag(DragEndDetails details) {
    if (_isDismissing) return;
    if (details.primaryVelocity != null && details.primaryVelocity! > 500) {
      _dismissFromDrag();
      return;
    }
    _dismissDragDistance = 0;
  }

  Future<void> _pickCategory() async {
    final t = AppLocalizations.of(context)!;
    final baseCurrency =
        ref.read(currencyProvider).value?.baseCurrency ?? 'EUR';
    selectedCurrency ??= baseCurrency;

    final categoriesAsync = ref.read(categoryProvider);
    final categories =
        categoriesAsync.value?.where((c) => c.isIncome == isIncome).toList() ??
        [];

    final picked = await showModalBottomSheet<Category>(
      context: context,
      showDragHandle: true,
      builder: (_) {
        return SafeArea(
          child: ListView(
            children: [
              ...categories.map(
                (c) => ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Color(c.color).withValues(alpha: .15),
                    child: Icon(
                      c.isDefault
                          ? categoryIcon(c.name)
                          : customCategoryIcon(c.icon),
                      color: Color(c.color),
                    ),
                  ),
                  title: Text(categoryName(c.name, t)),
                  trailing: selectedCategory?.id == c.id
                      ? const Icon(Icons.check)
                      : null,
                  onTap: () => Navigator.pop(context, c),
                ),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.add),
                title: Text(t.newCategory),
                onTap: () async {
                  final navigator = Navigator.of(context);
                  final created = await showAddCategoryDialog(
                    context,
                    isIncome,
                  );

                  if (created != null && navigator.mounted) {
                    navigator.pop(created);
                  }
                },
              ),
            ],
          ),
        );
      },
    );

    if (picked != null) {
      setState(() {
        selectedCategory = picked;
      });
    }
  }

  Future<void> _pickRecurringDay() async {
    final picked = await showModalBottomSheet<int>(
      context: context,
      builder: (_) {
        return ListView.builder(
          itemCount: 31,
          itemBuilder: (_, i) {
            final day = i + 1;

            return ListTile(
              title: Text(day.toString()),
              onTap: () => Navigator.pop(context, day),
            );
          },
        );
      },
    );

    if (picked != null) {
      setState(() {
        recurringDay = picked;
      });
    }
  }

  String _frequencyLabel(RecurrenceFrequency frequency) {
    final language = Localizations.localeOf(context).languageCode;
    return switch ((frequency, language)) {
      (RecurrenceFrequency.daily, 'it') => 'Giorni',
      (RecurrenceFrequency.weekly, 'it') => 'Settimane',
      (RecurrenceFrequency.monthly, 'it') => 'Mesi',
      (RecurrenceFrequency.yearly, 'it') => 'Anni',
      (RecurrenceFrequency.daily, 'es') => 'Días',
      (RecurrenceFrequency.weekly, 'es') => 'Semanas',
      (RecurrenceFrequency.monthly, 'es') => 'Meses',
      (RecurrenceFrequency.yearly, 'es') => 'Años',
      (RecurrenceFrequency.daily, _) => 'Days',
      (RecurrenceFrequency.weekly, _) => 'Weeks',
      (RecurrenceFrequency.monthly, _) => 'Months',
      (RecurrenceFrequency.yearly, _) => 'Years',
    };
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final currencyState = ref.watch(currencyProvider).value;
    final baseCurrency = currencyState?.baseCurrency ?? 'EUR';
    selectedCurrency ??= baseCurrency;

    final categoriesAsync = ref.watch(categoryProvider);

    final categories = categoriesAsync.value ?? [];

    if (selectedCategory == null && _pendingCategoryId != null) {
      selectedCategory = categories
          .where((category) => category.id == _pendingCategoryId)
          .firstOrNull;
      if (selectedCategory != null) _pendingCategoryId = null;
    }

    final filtered = categories.where((c) => c.isIncome == isIncome).toList();
    final recentCategories = filtered.take(4).toList();

    if (selectedCategory != null &&
        !recentCategories.any((c) => c.id == selectedCategory!.id)) {
      if (recentCategories.length == 4) {
        recentCategories.removeLast();
      }
      recentCategories.insert(0, selectedCategory!);
    }

    final canSave = amountMinor > 0 && selectedCategory != null;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: SingleChildScrollView(
        controller: widget.scrollController,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Semantics(
              label: MaterialLocalizations.of(context).closeButtonTooltip,
              child: GestureDetector(
                key: const ValueKey('quick-add-drag-handle'),
                behavior: HitTestBehavior.opaque,
                onVerticalDragUpdate: _updateDismissDrag,
                onVerticalDragEnd: _endDismissDrag,
                onVerticalDragCancel: () => _dismissDragDistance = 0,
                child: SizedBox(
                  width: double.infinity,
                  height: 22,
                  child: Center(
                    child: Container(
                      width: 42,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurfaceVariant.withValues(alpha: .38),
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            SegmentedButton<bool>(
              segments: [
                ButtonSegment(value: true, label: Text(t.income)),
                ButtonSegment(value: false, label: Text(t.expense)),
              ],
              selected: {isIncome},
              onSelectionChanged: (v) {
                setState(() {
                  isIncome = v.first;
                  selectedCategory = null;
                });
              },
            ),

            const SizedBox(height: 24),

            GestureDetector(
              onTap: () {
                setState(() {
                  showKeypad = true;
                });
              },
              child: Container(
                width: double.infinity,
                constraints: const BoxConstraints(minHeight: 150),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Theme.of(context).colorScheme.surface,
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      top: 0,
                      right: 0,
                      child: CurrencySelector(
                        value: selectedCurrency!,
                        compact: true,
                        onChanged: (currency) {
                          setState(() {
                            selectedCurrency = currency;
                            amountMinor = 0;
                          });
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 12, 8, 0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            t.amount,
                            style: Theme.of(context).textTheme.labelMedium
                                ?.copyWith(color: Colors.grey.shade600),
                          ),
                          const SizedBox(height: 7),
                          SizedBox(
                            width: double.infinity,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 140),
                                transitionBuilder: (child, animation) =>
                                    FadeTransition(
                                      opacity: animation,
                                      child: ScaleTransition(
                                        scale: Tween(
                                          begin: .97,
                                          end: 1.0,
                                        ).animate(animation),
                                        child: child,
                                      ),
                                    ),
                                child: Text(
                                  amountInputText(
                                    amountMinor,
                                    selectedCurrency!,
                                  ),
                                  key: ValueKey(
                                    '$amountMinor:$selectedCurrency',
                                  ),
                                  style: const TextStyle(
                                    fontSize: 40,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -1.2,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          if (amountMinor > 0 &&
                              selectedCurrency != baseCurrency &&
                              currencyState != null) ...[
                            const SizedBox(height: 5),
                            Text(
                              _conversionPreview(
                                    currencyState,
                                    baseCurrency,
                                    Localizations.localeOf(context).toString(),
                                  ) ??
                                  t.conversionOnSave,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2100),
                );

                if (picked != null) {
                  setState(() {
                    selectedDate = picked;
                  });
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade300),
                  color: Theme.of(context).colorScheme.surface,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 18),
                    const SizedBox(width: 10),
                    Text(
                      DateFormat.yMMMd(
                        Localizations.localeOf(context).toString(),
                      ).format(selectedDate),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const Spacer(),
                    const Icon(Icons.expand_more),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            if (!showKeypad) ...[
              if (recentCategories.isNotEmpty) ...[
                const SizedBox(height: 4),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    t.category,
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                Wrap(
                  key: ValueKey(recentCategories.map((e) => e.id).join()),
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    ...recentCategories.map((c) {
                      final selected = selectedCategory?.id == c.id;

                      return ActionChip(
                        avatar: CircleAvatar(
                          backgroundColor: Color(
                            c.color,
                          ).withValues(alpha: .15),
                          child: Icon(
                            c.isDefault
                                ? categoryIcon(c.name)
                                : customCategoryIcon(c.icon),
                            size: 18,
                            color: Color(c.color),
                          ),
                        ),
                        label: Text(categoryName(c.name, t)),
                        backgroundColor: selected
                            ? Color(c.color).withValues(alpha: .15)
                            : null,
                        onPressed: () {
                          setState(() {
                            selectedCategory = c;
                          });
                        },
                      );
                    }),

                    /// OTHER BUTTON
                    ActionChip(
                      avatar: const Icon(Icons.more_horiz),
                      label: Text(t.otherCategories),
                      onPressed: _pickCategory,
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: recurring
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey.shade300,
                    ),
                    color: recurring
                        ? Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.06)
                        : Theme.of(context).colorScheme.surface,
                  ),
                  child: Row(
                    children: [
                      Container(
                        height: 36,
                        width: 36,
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.autorenew, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t.recurrent,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              recurring
                                  ? t.recursEvery(
                                      recurringInterval,
                                      _frequencyLabel(
                                        recurringFrequency,
                                      ).toLowerCase(),
                                    )
                                  : t.recurrentMsg,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: recurring,
                        onChanged: (v) {
                          setState(() {
                            recurring = v;
                            if (v) {
                              recurringDay = selectedDate.day;
                            }
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],

              if (recurring)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(child: Text(t.repeatEvery)),
                            DropdownButton<int>(
                              value: recurringInterval,
                              underline: const SizedBox(),
                              items: List.generate(
                                12,
                                (index) => DropdownMenuItem(
                                  value: index + 1,
                                  child: Text('${index + 1}'),
                                ),
                              ),
                              onChanged: (value) => setState(
                                () => recurringInterval = value ?? 1,
                              ),
                            ),
                            const SizedBox(width: 8),
                            DropdownButton<RecurrenceFrequency>(
                              value: recurringFrequency,
                              underline: const SizedBox(),
                              items: RecurrenceFrequency.values
                                  .map(
                                    (value) => DropdownMenuItem(
                                      value: value,
                                      child: Text(_frequencyLabel(value)),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) => setState(() {
                                recurringFrequency =
                                    value ?? RecurrenceFrequency.monthly;
                              }),
                            ),
                          ],
                        ),
                        if (recurringFrequency == RecurrenceFrequency.monthly ||
                            recurringFrequency == RecurrenceFrequency.yearly)
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.calendar_month),
                            title: Text(t.dayOfMonth),
                            trailing: Text(
                              '$recurringDay',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            onTap: _pickRecurringDay,
                          ),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.event_busy_outlined),
                          title: Text(t.endDate),
                          subtitle: Text(
                            recurringEndDate == null
                                ? t.none
                                : DateFormat.yMMMd(
                                    Localizations.localeOf(context).toString(),
                                  ).format(recurringEndDate!),
                          ),
                          trailing: recurringEndDate == null
                              ? const Icon(Icons.chevron_right)
                              : IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: () =>
                                      setState(() => recurringEndDate = null),
                                ),
                          onTap: () async {
                            final value = await showDatePicker(
                              context: context,
                              initialDate:
                                  recurringEndDate ??
                                  selectedDate.add(const Duration(days: 30)),
                              firstDate: selectedDate,
                              lastDate: DateTime(selectedDate.year + 20),
                            );
                            if (value != null) {
                              setState(() => recurringEndDate = value);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: Theme.of(context).colorScheme.surface,
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.notes_rounded,
                      size: 20,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: noteController,
                        onChanged: (_) => setState(() {}),
                        textCapitalization: TextCapitalization.sentences,
                        inputFormatters: const [
                          CapitalizeFirstLetterFormatter(),
                        ],
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          hintText: t.note,
                          border: InputBorder.none,
                        ),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              if (!recurring && receiptPath != null)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.receipt_long),
                  title: Text(t.receiptAttached),
                  subtitle: Text(t.receiptLinked),
                  trailing: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () async {
                      final path = receiptPath;
                      setState(() => receiptPath = null);
                      await ref
                          .read(receiptStorageServiceProvider)
                          .remove(path);
                    },
                  ),
                ),
            ],

            if (showKeypad) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerLow.withValues(alpha: .62),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: GridView.count(
                  mainAxisSpacing: 2,
                  crossAxisSpacing: 8,
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 1.72,
                  children: [
                    ...['1', '2', '3', '4', '5', '6', '7', '8', '9'].map(
                      (digit) => _KeyButton(
                        key: ValueKey('quick-amount-key-$digit'),
                        label: digit,
                        onTap: () => _addDigit(digit),
                      ),
                    ),
                    _KeyButton(
                      key: const ValueKey('quick-amount-key-00'),
                      label: '00',
                      onTap: () => _addDigits('00'),
                    ),
                    _KeyButton(
                      key: const ValueKey('quick-amount-key-0'),
                      label: '0',
                      onTap: () => _addDigit('0'),
                    ),
                    _KeyButton(
                      key: const ValueKey('quick-amount-backspace'),
                      icon: Icons.backspace_outlined,
                      semanticsLabel: t.deleteDigit,
                      onTap: _deleteDigit,
                      onLongPress: _clearAmount,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(17),
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      showKeypad = false;
                    });
                  },
                  icon: const Icon(Icons.check_rounded),
                  label: Text(t.confirm),
                ),
              ),
            ],

            const SizedBox(height: 16),

            if (!showKeypad)
              AnimatedSlide(
                duration: const Duration(milliseconds: 120),
                offset: shake ? const Offset(-0.02, 0) : Offset.zero,
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: canSave
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey.shade300,
                          foregroundColor: canSave
                              ? Colors.white
                              : Colors.grey.shade600,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () async {
                          if (!canSave) {
                            HapticFeedback.mediumImpact();
                            _triggerShake();
                            return;
                          }

                          final cents = amountMinor;
                          final notifier = ref.read(
                            transactionProvider.notifier,
                          );
                          final t = AppLocalizations.of(context)!;

                          if (recurring) {
                            await notifier.addRecurringTransaction(
                              amountCents: cents,
                              isIncome: isIncome,
                              categoryId: selectedCategory!.id,
                              dayOfMonth: recurringDay,
                              startDate: selectedDate,
                              note: noteController.text.trim().isEmpty
                                  ? null
                                  : noteController.text.trim(),
                              currencyCode: selectedCurrency,
                              frequency: recurringFrequency,
                              interval: recurringInterval,
                              dayOfWeek:
                                  recurringFrequency ==
                                      RecurrenceFrequency.weekly
                                  ? selectedDate.weekday
                                  : null,
                              monthOfYear:
                                  recurringFrequency ==
                                      RecurrenceFrequency.yearly
                                  ? selectedDate.month
                                  : null,
                              endDate: recurringEndDate,
                            );

                            ref.invalidate(recurringProvider);
                            ref.invalidate(transactionProvider);

                            if (context.mounted) {
                              final locale = Localizations.localeOf(
                                context,
                              ).toString();

                              final nextDate = DateTime(
                                DateTime.now().year,
                                DateTime.now().month,
                                recurringDay,
                              );

                              final formatted = DateFormat.yMMMd(
                                locale,
                              ).format(nextDate);

                              final messenger = ScaffoldMessenger.of(context);

                              messenger
                                ..hideCurrentSnackBar()
                                ..showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      "${t.recurringCreationMsg} • $formatted",
                                    ),
                                    duration: const Duration(seconds: 4),
                                    behavior: SnackBarBehavior.floating,
                                    margin: const EdgeInsets.all(16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                );
                            }
                          } else {
                            await notifier.addTransaction(
                              amountCents: cents,
                              isIncome: isIncome,
                              categoryId: selectedCategory!.id,
                              date: selectedDate,
                              note: noteController.text.trim().isEmpty
                                  ? null
                                  : noteController.text.trim(),
                              currencyCode: selectedCurrency,
                              receiptPath: receiptPath,
                            );
                            _receiptCommitted = true;
                          }

                          if (context.mounted) Navigator.pop(context);
                        },
                        child: Text(t.saveTransaction),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.red.withValues(alpha: 0.08),
                          foregroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(t.cancel),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  String? _conversionPreview(
    CurrencyState currencyState,
    String baseCurrency,
    String locale,
  ) {
    try {
      final conversion = ref
          .read(currencyRatesServiceProvider)
          .convert(
            amountMinor: amountMinor,
            sourceCurrency: selectedCurrency!,
            baseCurrency: baseCurrency,
            ratesPerEuro: currencyState.rates.ratesPerEuro,
          );
      return AppLocalizations.of(context)!.convertedToMainCurrency(
        formatMoney(conversion.baseAmountMinor, baseCurrency, locale),
      );
    } catch (_) {
      return null;
    }
  }
}

class _KeyButton extends StatefulWidget {
  final String? label;
  final IconData? icon;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final String? semanticsLabel;

  const _KeyButton({
    super.key,
    this.label,
    this.icon,
    required this.onTap,
    this.onLongPress,
    this.semanticsLabel,
  });

  @override
  State<_KeyButton> createState() => _KeyButtonState();
}

class _KeyButtonState extends State<_KeyButton> {
  double scale = 1;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      label: widget.semanticsLabel ?? widget.label,
      child: AnimatedScale(
        scale: scale,
        duration: const Duration(milliseconds: 90),
        curve: Curves.easeOut,
        child: Material(
          color: Colors.transparent,
          shape: const StadiumBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            borderRadius: BorderRadius.circular(999),
            overlayColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.pressed)) {
                return colors.primary.withValues(alpha: .11);
              }
              return Colors.transparent;
            }),
            onHighlightChanged: (highlighted) {
              if (mounted) setState(() => scale = highlighted ? .91 : 1);
            },
            onTap: () {
              HapticFeedback.lightImpact();
              widget.onTap();
            },
            onLongPress: widget.onLongPress == null
                ? null
                : () {
                    HapticFeedback.mediumImpact();
                    widget.onLongPress!();
                  },
            child: Center(
              child: widget.icon != null
                  ? Icon(widget.icon, size: 24, color: colors.onSurfaceVariant)
                  : Text(
                      widget.label!,
                      style: TextStyle(
                        color: colors.onSurface,
                        fontSize: widget.label == '00' ? 22 : 28,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -.65,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../domain/category.dart';
import '../domain/transaction.dart';
import '../providers/transaction_provider.dart';
import '../providers/category_provider.dart';
import 'category_selector.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/utils/category_localization.dart';
import 'package:flutter/services.dart';
import '../../../core/input_formatters/capitalize_first_letter_formatter.dart';
import '../../../core/currency/currency_metadata.dart';
import '../../../core/currency/currency_provider.dart';
import '../../../core/currency/currency_selector.dart';
import '../../../core/receipts/receipt_storage_service.dart';

class AddTransactionPage extends ConsumerStatefulWidget {
  const AddTransactionPage({super.key, this.transaction});

  final TransactionModel? transaction;

  @override
  ConsumerState<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends ConsumerState<AddTransactionPage> {
  Category? selectedCategory;
  bool isIncome = true;
  bool shake = false;

  final amountController = TextEditingController();
  final noteController = TextEditingController();

  DateTime selectedDate = DateTime.now();
  String? selectedCurrency;
  String? receiptPath;

  bool categoryInitialized = false;
  void _triggerShake() {
    setState(() => shake = true);

    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        setState(() => shake = false);
      }
    });
  }

  @override
  void initState() {
    super.initState();

    final tx = widget.transaction;

    if (tx != null) {
      isIncome = tx.isIncome;
      selectedDate = tx.date;
      selectedCurrency = tx.originalCurrency;
      amountController.text = amountInputText(
        tx.originalAmountMinor,
        tx.originalCurrency,
      );
      noteController.text = tx.note ?? "";
      receiptPath = tx.receiptPath;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (categoryInitialized) return;

    final tx = widget.transaction;

    if (tx != null) {
      final categoriesAsync = ref.read(categoryProvider);

      categoriesAsync.whenData((categories) {
        final cat = categories.firstWhere(
          (c) => c.id == tx.categoryId,
          orElse: () => categories.first,
        );

        if (mounted) {
          setState(() {
            selectedCategory = cat;
            categoryInitialized = true;
          });
        }
      });
    }
  }

  Future<void> pickDate() async {
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
  }

  @override
  void dispose() {
    amountController.dispose();
    noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final parsedAmount = double.tryParse(
      amountController.text.replaceAll(',', '.'),
    );

    final canSave =
        selectedCategory != null && parsedAmount != null && parsedAmount > 0;
    final t = AppLocalizations.of(context)!;
    final baseCurrency =
        ref.watch(currencyProvider).value?.baseCurrency ?? 'EUR';
    final currencyState = ref.watch(currencyProvider).value;
    selectedCurrency ??= baseCurrency;
    final locale = Localizations.localeOf(context).toString();
    final dateFormat = DateFormat.yMMMd(locale);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.transaction == null ? t.addTransaction : t.saveTransaction,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            /// INCOME / EXPENSE
            SegmentedButton<bool>(
              segments: [
                ButtonSegment<bool>(
                  value: true,
                  label: Text(t.income),
                  icon: const Icon(Icons.arrow_downward),
                ),
                ButtonSegment<bool>(
                  value: false,
                  label: Text(t.expense),
                  icon: const Icon(Icons.arrow_upward),
                ),
              ],
              selected: {isIncome},
              onSelectionChanged: (value) {
                setState(() {
                  isIncome = value.first;
                  selectedCategory = null;
                });
              },
            ),

            const SizedBox(height: 24),

            /// AMOUNT
            TextField(
              controller: amountController,
              autofocus: true,
              onChanged: (_) => setState(() {}),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: t.amount,
                prefixIconConstraints: const BoxConstraints(minWidth: 82),
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(left: 8, right: 8),
                  child: CurrencySelector(
                    value: selectedCurrency!,
                    compact: true,
                    onChanged: (currency) {
                      setState(() => selectedCurrency = currency);
                    },
                  ),
                ),
              ),
            ),

            if (parsedAmount != null &&
                parsedAmount > 0 &&
                selectedCurrency != baseCurrency &&
                currencyState != null)
              Padding(
                padding: const EdgeInsets.only(top: 7, left: 12),
                child: Text(
                  _conversionPreview(
                        parsedAmount,
                        selectedCurrency!,
                        currencyState,
                        locale,
                      ) ??
                      t.conversionOnSave,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),

            const SizedBox(height: 16),

            /// CATEGORY
            InkWell(
              onTap: () async {
                final category = await showCategorySelector(context, isIncome);

                if (!mounted) return;

                if (category != null) {
                  setState(() {
                    selectedCategory = category;
                  });
                }
              },
              child: InputDecorator(
                decoration: InputDecoration(labelText: t.category),
                child: selectedCategory == null
                    ? Text(t.selectCategory)
                    : Row(
                        children: [
                          CircleAvatar(
                            radius: 14,
                            backgroundColor: Color(
                              selectedCategory!.color,
                            ).withValues(alpha: 0.2),
                            child: Icon(
                              selectedCategory!.isDefault
                                  ? categoryIcon(selectedCategory!.name)
                                  : customCategoryIcon(selectedCategory!.icon),
                              size: 20,
                              color: Color(selectedCategory!.color),
                            ),
                          ),

                          const SizedBox(width: 8),

                          Text(categoryName(selectedCategory!.name, t)),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 16),

            /// DATE
            InkWell(
              onTap: pickDate,
              child: InputDecorator(
                decoration: InputDecoration(labelText: t.date),
                child: Text(dateFormat.format(selectedDate)),
              ),
            ),

            const SizedBox(height: 16),

            /// NOTE
            TextField(
              controller: noteController,
              onChanged: (_) => setState(() {}),
              textCapitalization: TextCapitalization.sentences,
              inputFormatters: const [CapitalizeFirstLetterFormatter()],
              decoration: InputDecoration(labelText: t.note),
            ),

            const SizedBox(height: 8),
            if (receiptPath != null)
              Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    AspectRatio(
                      aspectRatio: 16 / 7,
                      child: Image.file(
                        File(receiptPath!),
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const Center(
                          child: Icon(Icons.broken_image_outlined),
                        ),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.receipt_long),
                      title: Text(t.receiptAttached),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () async {
                          final path = receiptPath;
                          setState(() => receiptPath = null);
                          if (path != widget.transaction?.receiptPath) {
                            await ref
                                .read(receiptStorageServiceProvider)
                                .remove(path);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 32),

            /// SAVE
            AnimatedSlide(
              duration: const Duration(milliseconds: 120),
              offset: shake ? const Offset(-0.02, 0) : Offset.zero,
              child: SizedBox(
                height: 52,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: canSave
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey.shade300,
                    foregroundColor: canSave
                        ? Colors.white
                        : Colors.grey.shade600,
                  ),
                  onPressed: () async {
                    if (!canSave) {
                      HapticFeedback.mediumImpact();
                      _triggerShake();
                      return;
                    }

                    final parsedAmount = double.tryParse(
                      amountController.text.replaceAll(',', '.'),
                    );

                    if (parsedAmount == null || parsedAmount <= 0) return;

                    final amountCents = majorToMinor(
                      parsedAmount,
                      selectedCurrency!,
                    );

                    final notifier = ref.read(transactionProvider.notifier);

                    if (widget.transaction != null) {
                      await notifier.updateTransaction(
                        id: widget.transaction!.id,
                        amountCents: amountCents,
                        isIncome: isIncome,
                        categoryId: selectedCategory!.id,
                        date: selectedDate,
                        note: noteController.text.trim().isEmpty
                            ? null
                            : noteController.text.trim(),
                        currencyCode: selectedCurrency,
                        receiptPath: receiptPath,
                      );
                    } else {
                      await notifier.addTransaction(
                        amountCents: amountCents,
                        isIncome: isIncome,
                        categoryId: selectedCategory!.id,
                        date: selectedDate,
                        note: noteController.text.trim().isEmpty
                            ? null
                            : noteController.text.trim(),
                        currencyCode: selectedCurrency,
                        receiptPath: receiptPath,
                      );
                    }
                    final previousReceipt = widget.transaction?.receiptPath;
                    if (previousReceipt != null &&
                        previousReceipt != receiptPath) {
                      await ref
                          .read(receiptStorageServiceProvider)
                          .remove(previousReceipt);
                    }

                    if (!mounted) return;

                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
                  },
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Text(t.saveTransaction, key: ValueKey(canSave)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _conversionPreview(
    double amount,
    String sourceCurrency,
    CurrencyState currencyState,
    String locale,
  ) {
    try {
      final conversion = ref
          .read(currencyRatesServiceProvider)
          .convert(
            amountMinor: majorToMinor(amount, sourceCurrency),
            sourceCurrency: sourceCurrency,
            baseCurrency: currencyState.baseCurrency,
            ratesPerEuro: currencyState.rates.ratesPerEuro,
          );
      return AppLocalizations.of(context)!.convertedToMainCurrency(
        formatMoney(
          conversion.baseAmountMinor,
          conversion.baseCurrency,
          locale,
        ),
      );
    } catch (_) {
      return null;
    }
  }
}

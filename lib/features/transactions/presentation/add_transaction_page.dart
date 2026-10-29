import 'dart:async';
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
import '../../../shared/widgets/vault_dialogs.dart';
import '../../../shared/widgets/vault_form.dart';
import '../../../shared/widgets/vault_style.dart';

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

    final colors = Theme.of(context).colorScheme;
    final flowColor = VaultColors.flow(context, isIncome);
    final editing = widget.transaction != null;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 4,
        title: Text(
          editing ? t.editTransaction : t.addTransaction,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.6,
          ),
        ),
        actions: [
          if (editing)
            IconButton(
              key: const ValueKey('edit-transaction-delete'),
              tooltip: t.delete,
              color: VaultColors.expense(context),
              icon: const Icon(Icons.delete_outline_rounded),
              onPressed: _delete,
            ),
          const SizedBox(width: 6),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          children: [
            /// INCOME / EXPENSE
            VaultFlowSwitch(
              isIncome: isIncome,
              onChanged: (value) {
                setState(() {
                  isIncome = value;
                  selectedCategory = null;
                });
              },
            ),

            const SizedBox(height: 12),

            /// AMOUNT
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 12, 10),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: colors.outlineVariant, width: .7),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        t.amount,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      const Spacer(),
                      CurrencySelector(
                        value: selectedCurrency!,
                        compact: true,
                        onChanged: (currency) {
                          setState(() => selectedCurrency = currency);
                        },
                      ),
                    ],
                  ),
                  TextField(
                    controller: amountController,
                    autofocus: !editing,
                    onChanged: (_) => setState(() {}),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1.4,
                      color: flowColor,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                    decoration: InputDecoration(
                      hintText: '0',
                      hintStyle: TextStyle(
                        color: colors.onSurface.withValues(alpha: .3),
                      ),
                      filled: false,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 6),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                  ),
                  if (parsedAmount != null &&
                      parsedAmount > 0 &&
                      selectedCurrency != baseCurrency &&
                      currencyState != null)
                    Text(
                      _conversionPreview(
                            parsedAmount,
                            selectedCurrency!,
                            currencyState,
                            locale,
                          ) ??
                          t.conversionOnSave,
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            /// CATEGORY
            VaultFieldTile(
              icon: Icons.category_outlined,
              label: t.category,
              onTap: () async {
                final category = await showCategorySelector(
                  context,
                  isIncome,
                  selectedId: selectedCategory?.id,
                );

                if (!mounted) return;

                if (category != null) {
                  setState(() {
                    selectedCategory = category;
                  });
                }
              },
              child: selectedCategory == null
                  ? Text(
                      t.selectCategory,
                      style: TextStyle(color: colors.onSurfaceVariant),
                    )
                  : Row(
                      children: [
                        CategoryAvatar(category: selectedCategory, size: 22),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            categoryName(selectedCategory!.name, t),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
            ),

            const SizedBox(height: 10),

            /// DATE
            VaultFieldTile(
              icon: Icons.calendar_today_rounded,
              label: t.date,
              onTap: pickDate,
              child: Text(dateFormat.format(selectedDate)),
            ),

            const SizedBox(height: 10),

            /// NOTE
            VaultFieldTile(
              icon: Icons.notes_rounded,
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
              child: TextField(
                controller: noteController,
                onChanged: (_) => setState(() {}),
                textCapitalization: TextCapitalization.sentences,
                inputFormatters: const [CapitalizeFirstLetterFormatter()],
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: t.note,
                  filled: false,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),

            if (receiptPath != null) ...[
              const SizedBox(height: 10),
              VaultSurface(
                padding: EdgeInsets.zero,
                radius: 16,
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
                      leading: Icon(
                        Icons.receipt_long_rounded,
                        color: VaultColors.income(context),
                      ),
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
            ],

            const SizedBox(height: 24),

            /// SAVE
            AnimatedSlide(
              duration: const Duration(milliseconds: 120),
              offset: shake ? const Offset(-0.02, 0) : Offset.zero,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(54),
                  backgroundColor: canSave
                      ? colors.primary
                      : colors.surfaceContainerHighest,
                  foregroundColor: canSave
                      ? colors.onPrimary
                      : colors.onSurfaceVariant,
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
          ],
        ),
      ),
    );
  }

  Future<void> _delete() async {
    final tx = widget.transaction;
    if (tx == null) return;
    final t = AppLocalizations.of(context)!;
    final confirmed = await showVaultDeleteDialog(
      context,
      title: t.deleteMovement,
      message: t.deleteMovementSure,
    );
    if (confirmed != true || !mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    final notifier = ref.read(transactionProvider.notifier);
    final receipts = ref.read(receiptStorageServiceProvider);
    await notifier.deleteTransaction(tx.id);
    if (!mounted) return;
    Navigator.of(context).pop();
    messenger.hideCurrentSnackBar();
    final closeReason = await messenger
        .showSnackBar(
          SnackBar(
            content: Text(t.transactionDeleted),
            action: SnackBarAction(
              label: t.undo,
              onPressed: () => unawaited(notifier.restoreTransaction(tx)),
            ),
          ),
        )
        .closed;
    if (closeReason != SnackBarClosedReason.action) {
      await receipts.remove(tx.receiptPath);
    }
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

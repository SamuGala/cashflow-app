import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../features/transactions/domain/category.dart';
import '../../l10n/app_localizations.dart';
import '../currency/currency_metadata.dart';
import '../currency/currency_selector.dart';
import '../input_formatters/capitalize_first_letter_formatter.dart';
import '../utils/category_localization.dart';
import 'receipt_scanner_service.dart';

enum ReceiptScanDecision { useDetectedData, attachOnly }

class ReceiptScanReviewResult {
  final ReceiptScanDecision decision;
  final ReceiptScanDraft draft;

  const ReceiptScanReviewResult({required this.decision, required this.draft});

  bool get appliesDetectedData =>
      decision == ReceiptScanDecision.useDetectedData;
}

Future<ReceiptScanReviewResult?> showReceiptScanReview({
  required BuildContext context,
  required ReceiptScanDraft draft,
  required Iterable<Category> categories,
}) {
  return showModalBottomSheet<ReceiptScanReviewResult>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _ReceiptScanReviewSheet(
      draft: draft,
      categories: categories
          .where((category) => !category.isIncome)
          .toList(growable: false),
    ),
  );
}

class _ReceiptScanReviewSheet extends StatefulWidget {
  final ReceiptScanDraft draft;
  final List<Category> categories;

  const _ReceiptScanReviewSheet({
    required this.draft,
    required this.categories,
  });

  @override
  State<_ReceiptScanReviewSheet> createState() =>
      _ReceiptScanReviewSheetState();
}

class _ReceiptScanReviewSheetState extends State<_ReceiptScanReviewSheet> {
  late final TextEditingController _merchantController;
  late final TextEditingController _amountController;
  late String _currencyCode;
  DateTime? _date;
  String? _categoryId;

  @override
  void initState() {
    super.initState();
    final extraction = widget.draft.extraction;
    _currencyCode = extraction?.currencyCode ?? 'EUR';
    _merchantController = TextEditingController(text: extraction?.merchant);
    _amountController = TextEditingController(
      text: extraction?.amountMinor == null
          ? ''
          : amountInputText(extraction!.amountMinor!, _currencyCode),
    );
    _date = extraction?.date;
    _categoryId = widget.categories
        .where((category) => category.id == extraction?.categoryId)
        .firstOrNull
        ?.id;
  }

  @override
  void dispose() {
    _merchantController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  ReceiptExtraction _editedExtraction() {
    final parsedAmount = double.tryParse(
      _amountController.text.trim().replaceAll(',', '.'),
    );
    final merchant = _merchantController.text.trim();
    final original = widget.draft.extraction;
    return ReceiptExtraction(
      amountMinor: parsedAmount == null || parsedAmount <= 0
          ? null
          : majorToMinor(parsedAmount, _currencyCode),
      currencyCode: _currencyCode,
      date: _date,
      merchant: merchant.isEmpty ? null : merchant,
      categoryId: _categoryId,
      confidence: original?.confidence ?? 0,
      recognizedText: original?.recognizedText ?? '',
    );
  }

  void _finish(ReceiptScanDecision decision) {
    Navigator.pop(
      context,
      ReceiptScanReviewResult(
        decision: decision,
        draft: ReceiptScanDraft(
          imagePath: widget.draft.imagePath,
          extraction: _editedExtraction(),
          automaticReadFailed: widget.draft.automaticReadFailed,
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _date ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 366)),
    );
    if (selected != null && mounted) setState(() => _date = selected);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final canUse = _editedExtraction().detectedFieldCount > 0;
    final colors = Theme.of(context).colorScheme;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          18,
          0,
          18,
          MediaQuery.viewInsetsOf(context).bottom + 18,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t.receiptScanReview,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.draft.extraction != null
                    ? t.receiptScanCheckData
                    : t.receiptScanNoData,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: AspectRatio(
                  aspectRatio: 16 / 6,
                  child: Image.file(
                    File(widget.draft.imagePath),
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => ColoredBox(
                      color: colors.surfaceContainerHighest,
                      child: const Center(
                        child: Icon(Icons.broken_image_outlined),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: colors.outlineVariant.withValues(alpha: .65),
                  ),
                ),
                child: Column(
                  children: [
                    TextField(
                      key: const ValueKey('receipt-review-merchant'),
                      controller: _merchantController,
                      textCapitalization: TextCapitalization.sentences,
                      inputFormatters: const [CapitalizeFirstLetterFormatter()],
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        labelText: t.receiptMerchant,
                        prefixIcon: const Icon(Icons.storefront_outlined),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: TextField(
                            key: const ValueKey('receipt-review-amount'),
                            controller: _amountController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            onChanged: (_) => setState(() {}),
                            decoration: InputDecoration(
                              labelText: t.amount,
                              prefixIcon: const Icon(Icons.payments_outlined),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: CurrencySelector(
                            value: _currencyCode,
                            compact: true,
                            onChanged: (value) {
                              setState(() => _currencyCode = value);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      key: ValueKey('receipt-review-category:$_categoryId'),
                      initialValue: _categoryId,
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: t.category,
                        prefixIcon: const Icon(Icons.category_outlined),
                      ),
                      items: widget.categories
                          .map(
                            (category) => DropdownMenuItem(
                              value: category.id,
                              child: Row(
                                children: [
                                  Icon(
                                    category.isDefault
                                        ? categoryIcon(category.name)
                                        : customCategoryIcon(category.icon),
                                    size: 19,
                                    color: Color(category.color),
                                  ),
                                  const SizedBox(width: 9),
                                  Expanded(
                                    child: Text(categoryName(category.name, t)),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(growable: false),
                      onChanged: (value) {
                        setState(() => _categoryId = value);
                      },
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      key: const ValueKey('receipt-review-date'),
                      borderRadius: BorderRadius.circular(12),
                      onTap: _pickDate,
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: t.date,
                          prefixIcon: const Icon(Icons.event_outlined),
                        ),
                        child: Text(
                          _date == null
                              ? '—'
                              : DateFormat.yMMMd(locale).format(_date!),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.lock_outline_rounded,
                    size: 17,
                    color: colors.primary,
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      t.receiptScanPrivate,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _finish(ReceiptScanDecision.attachOnly),
                      child: Text(t.attachOnly),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.icon(
                      key: const ValueKey('receipt-review-apply'),
                      onPressed: canUse
                          ? () => _finish(ReceiptScanDecision.useDetectedData)
                          : null,
                      icon: const Icon(Icons.check_rounded, size: 19),
                      label: Text(t.useDetectedData),
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

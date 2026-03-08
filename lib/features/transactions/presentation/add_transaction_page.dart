import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:another_flushbar/flushbar.dart';

import '../domain/category.dart';
import '../providers/transaction_provider.dart';
import 'select_category_sheet.dart';
import '../../../l10n/app_localizations.dart';

class AddTransactionPage extends ConsumerStatefulWidget {
  const AddTransactionPage({super.key});

  @override
  ConsumerState<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends ConsumerState<AddTransactionPage> {
  Category? selectedCategory;
  bool isIncome = true;

  final amountController = TextEditingController();
  final noteController = TextEditingController();

  DateTime selectedDate = DateTime.now();

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
    final dateFormat = DateFormat('dd MMM yyyy');
    final t = AppLocalizations.of(context)!;


    return Scaffold(
      appBar: AppBar(
        title: Text(
          t.addTransaction,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        elevation: 0,
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          /// ENTRATA / USCITA
          SegmentedButton<bool>(
            segments: [
              ButtonSegment<bool>(
                value: true,
                label: Text(
                  t.income,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.4,
                  ),
                ),
                icon: Icon(Icons.arrow_downward),
              ),

              ButtonSegment<bool>(
                value: false,
                label: Text(
                  t.expense,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.4,
                  ),
                ),
                icon: Icon(Icons.arrow_upward),
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

          /// IMPORTO
          TextField(
            controller: amountController,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: t.amount,
              prefixText: "€ ",
            ),
          ),

          const SizedBox(height: 16),

          /// CATEGORIA
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
                          ).withOpacity(0.2),
                          child: Icon(
                            IconData(
                              selectedCategory!.icon,
                              fontFamily: 'MaterialIcons',
                            ),
                            size: 16,
                            color: Color(selectedCategory!.color),
                          ),
                        ),

                        const SizedBox(width: 8),

                        Text(selectedCategory!.name),
                      ],
                    ),
            ),
          ),

          const SizedBox(height: 16),

          /// DATA
          InkWell(
            onTap: pickDate,
            child: InputDecorator(
              decoration: InputDecoration(labelText: t.date),
              child: Text(dateFormat.format(selectedDate)),
            ),
          ),

          const SizedBox(height: 16),

          /// NOTA
          TextField(
            controller: noteController,
            decoration: InputDecoration(labelText: t.note),
          ),

          const SizedBox(height: 32),

          /// SALVA
          SizedBox(
            height: 52,
            child: FilledButton(
              onPressed: () async {
                if (selectedCategory == null) return;

                final parsedAmount = double.tryParse(
                  amountController.text.replaceAll(',', '.'),
                );

                if (parsedAmount == null || parsedAmount <= 0) return;

                final amountCents = (parsedAmount * 100).round();

                await ref
                    .read(transactionProvider.notifier)
                    .addTransaction(
                      amountCents: amountCents,
                      isIncome: isIncome,
                      categoryId: selectedCategory!.id,
                      date: selectedDate,
                      note: noteController.text.trim().isEmpty
                          ? null
                          : noteController.text.trim(),
                    );

                if (!mounted) return;

                final flush = Flushbar(
                  icon: const Icon(Icons.check_circle, color: Colors.white),
                  message: t.transactionSaved,
                  duration: const Duration(seconds: 2),
                  margin: const EdgeInsets.all(16),
                  borderRadius: BorderRadius.circular(12),
                  backgroundColor: Colors.green.shade600,
                );

                await flush.show(context);

                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              },
              child: Text(t.saveTransaction),
            ),
          ),
        ],
      ),
    );
  }
}

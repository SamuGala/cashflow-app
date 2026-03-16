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
import '../../../core/database/database_provider.dart';

class QuickAddTransactionSheet extends ConsumerStatefulWidget {
  const QuickAddTransactionSheet({super.key});

  @override
  ConsumerState<QuickAddTransactionSheet> createState() =>
      _QuickAddTransactionSheetState();
}

class _QuickAddTransactionSheetState
    extends ConsumerState<QuickAddTransactionSheet> {
  String amount = "0.00";
  bool shake = false;
  final noteController = TextEditingController();

  Category? selectedCategory;

  bool recurring = false;
  int recurringDay = DateTime.now().day;

  bool isIncome = false;
  bool showKeypad = false;

  DateTime selectedDate = DateTime.now();

  void _addDigit(String digit) {
    setState(() {
      final digits = amount.replaceAll('.', '');

      if (digits.length >= 9) return;

      final newDigits = digits + digit;

      final value = int.parse(newDigits);

      final euros = value ~/ 100;
      final cents = value % 100;

      amount = "$euros.${cents.toString().padLeft(2, '0')}";
    });
  }

  void _deleteDigit() {
    setState(() {
      final digits = amount.replaceAll('.', '');

      if (digits.length <= 1) {
        amount = "0.00";
        return;
      }

      final newDigits = digits.substring(0, digits.length - 1);

      final value = int.parse(newDigits);

      final euros = value ~/ 100;
      final cents = value % 100;

      amount = "$euros.${cents.toString().padLeft(2, '0')}";
    });
  }

  void _triggerShake() {
    setState(() => shake = true);

    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        setState(() => shake = false);
      }
    });
  }

  Future<void> _pickCategory() async {
    final t = AppLocalizations.of(context)!;

    final categoriesAsync = ref.read(categoryProvider);
    final transactionsAsync = ref.read(transactionProvider);

    final categories =
        categoriesAsync.value?.where((c) => c.isIncome == isIncome).toList() ??
        [];

    final transactions = transactionsAsync.value ?? [];

    final Map<String, int> usage = {};

    for (final tx in transactions) {
      usage.update(tx.categoryId, (v) => v + 1, ifAbsent: () => 1);
    }

    final hasUsage = usage.isNotEmpty;

    categories.sort((a, b) {
      if (!hasUsage) {
        return a.name.compareTo(b.name);
      }

      final countA = usage[a.id] ?? 0;
      final countB = usage[b.id] ?? 0;

      if (countA != countB) {
        return countB.compareTo(countA);
      }

      return a.name.compareTo(b.name);
    });

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
                    backgroundColor: Color(c.color).withOpacity(.15),
                    child: Icon(
                      c.isDefault
                          ? categoryIcon(c.name)
                          : IconData(c.icon, fontFamily: 'MaterialIcons'),
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
                  final created = await showAddCategoryDialog(
                    context,
                    isIncome,
                  );

                  if (created != null && context.mounted) {
                    Navigator.pop(context, created);
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

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    final transactionsAsync = ref.watch(transactionProvider);
    final categoriesAsync = ref.watch(categoryProvider);

    final transactions = transactionsAsync.value ?? [];
    final categories = categoriesAsync.value ?? [];

    final filtered = categories.where((c) => c.isIncome == isIncome).toList();

    final Map<String, int> usage = {};

    for (final tx in transactions) {
      usage.update(tx.categoryId, (v) => v + 1, ifAbsent: () => 1);
    }

    filtered.sort((a, b) {
      final countA = usage[a.id] ?? 0;
      final countB = usage[b.id] ?? 0;

      if (countA != countB) {
        return countB.compareTo(countA);
      }

      return a.name.compareTo(b.name);
    });

    final mostUsed = filtered.take(4).toList();

    final amountValue = double.tryParse(amount);

    final canSave =
        amountValue != null && amountValue > 0 && selectedCategory != null;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Theme.of(context).colorScheme.surface,
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          "€",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          amount,
                          style: const TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      t.amount,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
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
              if (mostUsed.isNotEmpty) ...[
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
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    ...mostUsed.map((c) {
                      final selected = selectedCategory?.id == c.id;

                      return ActionChip(
                        avatar: CircleAvatar(
                          backgroundColor: Color(c.color).withOpacity(.15),
                          child: Icon(
                            c.isDefault
                                ? categoryIcon(c.name)
                                : IconData(c.icon, fontFamily: 'MaterialIcons'),
                            size: 18,
                            color: Color(c.color),
                          ),
                        ),
                        label: Text(categoryName(c.name, t)),
                        backgroundColor: selected
                            ? Color(c.color).withOpacity(.15)
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
                          ).colorScheme.primary.withOpacity(0.06)
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
                          ).colorScheme.primary.withOpacity(0.15),
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
                                  ? "${t.everyMonth} • ${t.day} $recurringDay"
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
                          });
                        },
                      ),
                    ],
                  ),
                ),

                if (recurring)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: _pickRecurringDay,
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_month),
                            const SizedBox(width: 10),
                            Text(
                              t.dayOfMonth,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              recurringDay.toString(),
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
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
              ],
            ],

            if (showKeypad) ...[
              const SizedBox(height: 24),
              GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.6,
                children: [
                  ...["1", "2", "3", "4", "5", "6", "7", "8", "9"].map(
                    (d) => _KeyButton(
                      label: d,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        _addDigit(d);
                      },
                    ),
                  ),
                  _KeyButton(label: "0", onTap: () => _addDigit("0")),
                  _KeyButton(icon: Icons.backspace, onTap: _deleteDigit),
                  const SizedBox(),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    setState(() {
                      showKeypad = false;
                    });
                  },
                  child: const Text("OK"),
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

                          final cents = (amountValue! * 100).round();
                          final notifier = ref.read(
                            transactionProvider.notifier,
                          );

                          await notifier.addTransaction(
                            amountCents: cents,
                            isIncome: isIncome,
                            categoryId: selectedCategory!.id,
                            date: selectedDate,
                            note: noteController.text.trim().isEmpty
                                ? null
                                : noteController.text.trim(),
                          );

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
                          backgroundColor: Colors.red.withOpacity(0.08),
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
}

class _KeyButton extends StatelessWidget {
  final String? label;
  final IconData? icon;
  final VoidCallback onTap;

  const _KeyButton({this.label, this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Center(
        child: icon != null
            ? Icon(icon, size: 22)
            : Text(
                label!,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}

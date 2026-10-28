import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../providers/recurring_provider.dart';
import '../providers/category_provider.dart';
import '../domain/category.dart';
import '../../../core/utils/category_localization.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/currency/currency_metadata.dart';
import '../../../core/currency/currency_selector.dart';
import '../domain/recurrence_calculator.dart';

class EditRecurringSheet extends ConsumerStatefulWidget {
  final RecurringTransaction recurring;

  const EditRecurringSheet({super.key, required this.recurring});

  @override
  ConsumerState<EditRecurringSheet> createState() => _EditRecurringSheetState();
}

class _EditRecurringSheetState extends ConsumerState<EditRecurringSheet> {
  late int amountCents;
  late int day;
  late String currencyCode;
  late RecurrenceFrequency frequency;
  late int recurrenceInterval;
  DateTime? endDate;

  Category? selectedCategory;

  @override
  void initState() {
    super.initState();

    amountCents =
        widget.recurring.originalAmountMinor ?? widget.recurring.amountCents;
    currencyCode = widget.recurring.originalCurrency ?? 'EUR';
    day = widget.recurring.dayOfMonth;
    frequency = recurrenceFrequencyFromName(widget.recurring.frequency);
    recurrenceInterval = widget.recurring.interval;
    endDate = widget.recurring.endDate;
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    final categoriesAsync = ref.watch(categoryProvider);
    final categories = (categoriesAsync.value ?? [])
        .where((category) => category.isIncome == widget.recurring.isIncome)
        .toList();

    if (categories.isEmpty) return const SizedBox();

    selectedCategory ??= categories.firstWhere(
      (c) => c.id == widget.recurring.categoryId,
      orElse: () => categories.first,
    );

    final top = categories.take(5).toList();

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        left: 16,
        right: 16,
        top: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            t.modifyRecurrent,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),

          const SizedBox(height: 20),

          /// AMOUNT
          GestureDetector(
            onTap: () async {
              final result = await showModalBottomSheet<int>(
                context: context,
                isScrollControlled: true,
                showDragHandle: true,
                builder: (_) => _AmountKeypad(
                  initial: amountCents,
                  currencyCode: currencyCode,
                ),
              );

              if (!mounted) return;

              if (result != null) {
                setState(() {
                  amountCents = result;
                });
              }
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(currencyCode, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 6),
                Text(
                  amountDisplayText(
                    amountCents,
                    currencyCode,
                    Localizations.localeOf(context).toString(),
                  ),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          CurrencySelector(
            value: currencyCode,
            onChanged: (currency) {
              setState(() {
                currencyCode = currency;
                amountCents = 0;
              });
            },
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(child: Text(t.repeatEvery)),
              DropdownButton<int>(
                value: recurrenceInterval,
                items: List.generate(
                  12,
                  (index) => DropdownMenuItem(
                    value: index + 1,
                    child: Text('${index + 1}'),
                  ),
                ),
                onChanged: (value) =>
                    setState(() => recurrenceInterval = value ?? 1),
              ),
              const SizedBox(width: 8),
              DropdownButton<RecurrenceFrequency>(
                value: frequency,
                items: RecurrenceFrequency.values
                    .map(
                      (value) => DropdownMenuItem(
                        value: value,
                        child: Text(value.name),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(
                  () => frequency = value ?? RecurrenceFrequency.monthly,
                ),
              ),
            ],
          ),

          if (frequency == RecurrenceFrequency.monthly ||
              frequency == RecurrenceFrequency.yearly)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(t.dayOfMonth),
                DropdownButton<int>(
                  value: day,
                  items: List.generate(
                    31,
                    (i) =>
                        DropdownMenuItem(value: i + 1, child: Text('${i + 1}')),
                  ),
                  onChanged: (v) {
                    if (v != null) setState(() => day = v);
                  },
                ),
              ],
            ),

          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.event_busy_outlined),
            title: Text(t.endDate),
            subtitle: Text(
              endDate == null
                  ? t.none
                  : MaterialLocalizations.of(
                      context,
                    ).formatMediumDate(endDate!),
            ),
            trailing: endDate == null
                ? const Icon(Icons.chevron_right)
                : IconButton(
                    onPressed: () => setState(() => endDate = null),
                    icon: const Icon(Icons.close),
                  ),
            onTap: () async {
              final value = await showDatePicker(
                context: context,
                initialDate:
                    endDate ?? DateTime.now().add(const Duration(days: 30)),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365 * 20)),
              );
              if (value != null) setState(() => endDate = value);
            },
          ),

          const SizedBox(height: 20),

          /// CATEGORY SELECTOR
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              ...top.map(
                (c) => _CategoryChip(
                  category: c,
                  selected: c.id == selectedCategory!.id,
                  onTap: () {
                    setState(() {
                      selectedCategory = c;
                    });
                  },
                ),
              ),

              _OtherCategoryButton(
                onTap: () async {
                  final result = await showModalBottomSheet<String>(
                    context: context,
                    showDragHandle: true,
                    builder: (_) => FractionallySizedBox(
                      heightFactor: 0.55,
                      child: CategorySelectorSheet(
                        isIncome: widget.recurring.isIncome,
                      ),
                    ),
                  );

                  if (result != null) {
                    final cat = categories.firstWhere((c) => c.id == result);

                    setState(() {
                      selectedCategory = cat;
                    });
                  }
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () async {
                await ref
                    .read(recurringProvider.notifier)
                    .updateRecurring(
                      id: widget.recurring.id,
                      amountCents: amountCents,
                      categoryId: selectedCategory!.id,
                      dayOfMonth: day,
                      currencyCode: currencyCode,
                      frequency: frequency,
                      interval: recurrenceInterval,
                      dayOfWeek: frequency == RecurrenceFrequency.weekly
                          ? widget.recurring.startDate.weekday
                          : null,
                      monthOfYear: frequency == RecurrenceFrequency.yearly
                          ? widget.recurring.startDate.month
                          : null,
                      endDate: endDate,
                    );

                if (context.mounted) Navigator.pop(context);
              },
              child: Text(t.save),
            ),
          ),
        ],
      ),
    );
  }
}

/// CATEGORY CHIP

class _CategoryChip extends StatelessWidget {
  final Category category;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.category,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: selected
              ? Color(category.color).withValues(alpha: .18)
              : Colors.transparent,
          border: Border.all(
            color: selected
                ? Color(category.color)
                : Theme.of(context).dividerColor,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              category.isDefault
                  ? categoryIcon(category.name)
                  : customCategoryIcon(category.icon),
              size: 20,
              color: Color(category.color),
            ),
            const SizedBox(width: 6),
            Text(categoryName(category.name, t)),
          ],
        ),
      ),
    );
  }
}

/// OTHER BUTTON

class _OtherCategoryButton extends StatelessWidget {
  final VoidCallback onTap;

  const _OtherCategoryButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.more_horiz, size: 18),
            const SizedBox(width: 6),
            Text(t.otherCategories),
          ],
        ),
      ),
    );
  }
}

/// KEYPAD

class _AmountKeypad extends StatefulWidget {
  final int initial;
  final String currencyCode;

  const _AmountKeypad({required this.initial, required this.currencyCode});

  @override
  State<_AmountKeypad> createState() => _AmountKeypadState();
}

class _AmountKeypadState extends State<_AmountKeypad> {
  late int cents;

  @override
  void initState() {
    super.initState();
    cents = widget.initial;
  }

  void addDigit(String d) {
    setState(() {
      cents = int.parse("${cents.toString()}$d");
    });
  }

  void delete() {
    setState(() {
      cents = cents ~/ 10;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(widget.currencyCode, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 6),
              Text(
                amountDisplayText(
                  cents,
                  widget.currencyCode,
                  Localizations.localeOf(context).toString(),
                ),
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.6,
            children: [
              ...[
                "1",
                "2",
                "3",
                "4",
                "5",
                "6",
                "7",
                "8",
                "9",
              ].map((d) => _KeyButton(label: d, onTap: () => addDigit(d))),
              _KeyButton(label: "0", onTap: () => addDigit("0")),
              _KeyButton(icon: Icons.backspace, onTap: delete),
              const SizedBox(),
            ],
          ),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                Navigator.pop(context, cents);
              },
              child: const Text("OK"),
            ),
          ),
        ],
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
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}

class CategorySelectorSheet extends ConsumerWidget {
  final bool isIncome;

  const CategorySelectorSheet({super.key, required this.isIncome});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = (ref.watch(categoryProvider).value ?? [])
        .where((category) => category.isIncome == isIncome)
        .toList();
    final t = AppLocalizations.of(context)!;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: categories.map((c) {
          return ListTile(
            leading: Icon(
              c.isDefault ? categoryIcon(c.name) : customCategoryIcon(c.icon),
              color: Color(c.color),
            ),
            title: Text(categoryName(c.name, t)),
            onTap: () {
              Navigator.pop(context, c.id);
            },
          );
        }).toList(),
      ),
    );
  }
}

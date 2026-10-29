import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../providers/recurring_provider.dart';
import '../providers/category_provider.dart';
import '../domain/category.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/currency/currency_metadata.dart';
import '../../../core/currency/currency_selector.dart';
import '../domain/recurrence_calculator.dart';
import 'recurring_list.dart' show recurrenceFrequencyLabel;
import '../../../shared/widgets/vault_form.dart';
import '../../../shared/widgets/vault_style.dart';

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
    if (!top.any((c) => c.id == selectedCategory!.id)) {
      if (top.length == 5) top.removeLast();
      top.insert(0, selectedCategory!);
    }
    final colors = Theme.of(context).colorScheme;
    final locale = Localizations.localeOf(context);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        left: 16,
        right: 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                t.modifyRecurrent,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -.6,
                ),
              ),
            ),

            const SizedBox(height: 14),

            /// AMOUNT
            InkWell(
              key: const ValueKey('edit-recurring-amount'),
              borderRadius: BorderRadius.circular(20),
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
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 12, 16),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: colors.outlineVariant, width: .7),
                ),
                child: Column(
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
                          value: currencyCode,
                          compact: true,
                          onChanged: (currency) {
                            setState(() {
                              currencyCode = currency;
                              amountCents = 0;
                            });
                          },
                        ),
                      ],
                    ),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        amountDisplayText(
                          amountCents,
                          currencyCode,
                          locale.toString(),
                        ),
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -1.4,
                          color: VaultColors.flow(
                            context,
                            widget.recurring.isIncome,
                          ),
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            /// SCHEDULE
            Container(
              padding: const EdgeInsets.fromLTRB(14, 8, 10, 4),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colors.outlineVariant, width: .7),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.autorenew_rounded,
                        size: 18,
                        color: colors.onSurfaceVariant,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          t.repeatEvery,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                      VaultPillDropdown<int>(
                        value: recurrenceInterval,
                        items: {for (var i = 1; i <= 12; i++) i: '$i'},
                        onChanged: (value) =>
                            setState(() => recurrenceInterval = value),
                      ),
                      const SizedBox(width: 6),
                      VaultPillDropdown<RecurrenceFrequency>(
                        value: frequency,
                        items: {
                          for (final value in RecurrenceFrequency.values)
                            value: recurrenceFrequencyLabel(value, locale),
                        },
                        onChanged: (value) => setState(() => frequency = value),
                      ),
                    ],
                  ),
                  if (frequency == RecurrenceFrequency.monthly ||
                      frequency == RecurrenceFrequency.yearly)
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_month_rounded,
                          size: 18,
                          color: colors.onSurfaceVariant,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            t.dayOfMonth,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: VaultPillDropdown<int>(
                            value: day,
                            items: {for (var i = 1; i <= 31; i++) i: '$i'},
                            onChanged: (v) => setState(() => day = v),
                          ),
                        ),
                      ],
                    ),
                  VaultOptionRow(
                    icon: Icons.event_busy_outlined,
                    label: t.endDate,
                    value: endDate == null
                        ? t.none
                        : MaterialLocalizations.of(
                            context,
                          ).formatMediumDate(endDate!),
                    trailing: endDate == null
                        ? null
                        : IconButton(
                            visualDensity: VisualDensity.compact,
                            onPressed: () => setState(() => endDate = null),
                            icon: const Icon(Icons.close_rounded, size: 18),
                          ),
                    onTap: () async {
                      final value = await showDatePicker(
                        context: context,
                        initialDate:
                            endDate ??
                            DateTime.now().add(const Duration(days: 30)),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(
                          const Duration(days: 365 * 20),
                        ),
                      );
                      if (value != null) setState(() => endDate = value);
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            /// CATEGORY SELECTOR
            VaultSectionLabel(t.category),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ...top.map(
                  (c) => VaultCategoryChip(
                    category: c,
                    selected: c.id == selectedCategory!.id,
                    onPressed: () {
                      setState(() {
                        selectedCategory = c;
                      });
                    },
                  ),
                ),

                VaultMoreChip(
                  label: t.otherCategories,
                  onPressed: () async {
                    final result = await showModalBottomSheet<String>(
                      context: context,
                      showDragHandle: true,
                      isScrollControlled: true,
                      useSafeArea: true,
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.sizeOf(context).height * .8,
                      ),
                      builder: (_) => CategorySelectorSheet(
                        isIncome: widget.recurring.isIncome,
                        selectedId: selectedCategory?.id,
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

            FilledButton(
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(54),
              ),
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
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        left: 16,
        right: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              amountDisplayText(
                cents,
                widget.currencyCode,
                Localizations.localeOf(context).toString(),
              ),
              style: const TextStyle(
                fontSize: 44,
                fontWeight: FontWeight.w800,
                letterSpacing: -1.5,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ),
          Text(
            widget.currencyCode,
            textAlign: TextAlign.center,
            style: TextStyle(color: colors.onSurfaceVariant, fontSize: 13),
          ),

          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest.withValues(alpha: .45),
              borderRadius: BorderRadius.circular(24),
            ),
            child: GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.9,
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
                const SizedBox(),
                _KeyButton(label: "0", onTap: () => addDigit("0")),
                _KeyButton(icon: Icons.backspace_outlined, onTap: delete),
              ],
            ),
          ),

          const SizedBox(height: 12),

          FilledButton.icon(
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(54),
            ),
            onPressed: () {
              Navigator.pop(context, cents);
            },
            icon: const Icon(Icons.check_rounded),
            label: Text(AppLocalizations.of(context)!.confirm),
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
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: icon != null ? Colors.transparent : colors.surface,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: Center(
          child: icon != null
              ? Icon(icon, size: 23, color: colors.onSurfaceVariant)
              : Text(
                  label!,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }
}

class CategorySelectorSheet extends ConsumerWidget {
  final bool isIncome;
  final String? selectedId;

  const CategorySelectorSheet({
    super.key,
    required this.isIncome,
    this.selectedId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = (ref.watch(categoryProvider).value ?? [])
        .where((category) => category.isIncome == isIncome)
        .toList();

    return VaultCategoryList(
      categories: categories,
      selectedId: selectedId,
      onSelected: (c) => Navigator.pop(context, c.id),
    );
  }
}

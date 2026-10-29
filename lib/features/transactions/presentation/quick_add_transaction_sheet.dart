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
import 'recurring_list.dart' show recurrenceFrequencyLabel;

import '../../../l10n/app_localizations.dart';
import '../../../core/input_formatters/capitalize_first_letter_formatter.dart';
import '../../../core/currency/currency_metadata.dart';
import '../../../core/currency/currency_provider.dart';
import '../../../core/currency/currency_selector.dart';
import '../../../core/utils/category_localization.dart';
import '../domain/recurrence_calculator.dart';
import '../../../core/receipts/receipt_storage_service.dart';
import '../../../core/receipts/receipt_scan_review_sheet.dart';
import '../../../shared/widgets/vault_form.dart';
import '../../../shared/widgets/vault_style.dart';

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
    extends ConsumerState<QuickAddTransactionSheet>
    with TickerProviderStateMixin {
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

  DateTime selectedDate = DateTime.now();
  String? selectedCurrency;
  String? receiptPath;
  bool _receiptCommitted = false;
  String? _pendingCategoryId;
  double _dismissDragDistance = 0;
  bool _isDismissing = false;
  bool _saving = false;
  bool _saved = false;

  final _carousel = ScrollController();
  List<String> _carouselIds = const [];

  static const _tileExtent = 78.0;
  static const _tileGap = 8.0;

  /// One gentle "breath" of the glow for every digit typed.
  late final _breathe = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
  );

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

  bool get _animationsOff => MediaQuery.disableAnimationsOf(context);

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
    _breathe.dispose();
    _carousel.dispose();
    noteController.dispose();
    super.dispose();
  }

  void _pulse() {
    if (_animationsOff) return;
    _breathe.forward(from: 0);
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
    _pulse();
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

  /// Centers the tile of [id] in the carousel, even when it is not built yet
  /// (for example a category just created far from the visible tiles).
  void _revealCategory(String id) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_carousel.hasClients) return;
      final index = _carouselIds.indexOf(id);
      if (index < 0) return;
      final position = _carousel.position;
      final target =
          (index * (_tileExtent + _tileGap) -
                  (position.viewportDimension - _tileExtent) / 2)
              .clamp(position.minScrollExtent, position.maxScrollExtent);
      if (_animationsOff) {
        _carousel.jumpTo(target);
      } else {
        _carousel.animateTo(
          target,
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  void _selectCategory(Category category) {
    HapticFeedback.selectionClick();
    setState(() => selectedCategory = category);
    _revealCategory(category.id);
  }

  Future<void> _createCategory() async {
    final created = await showAddCategoryDialog(context, isIncome);
    if (created == null || !mounted) return;
    _selectCategory(created);
  }

  Future<void> _pickDate() async {
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

  Future<void> _editNote() async {
    final t = AppLocalizations.of(context)!;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          0,
          16,
          MediaQuery.viewInsetsOf(sheetContext).bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              t.note,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: -.3,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              key: const ValueKey('quick-note-field'),
              controller: noteController,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              inputFormatters: const [CapitalizeFirstLetterFormatter()],
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => Navigator.pop(sheetContext),
              decoration: InputDecoration(hintText: t.addNote),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            FilledButton(
              key: const ValueKey('quick-note-done'),
              onPressed: () => Navigator.pop(sheetContext),
              child: Text(t.done),
            ),
          ],
        ),
      ),
    );
    if (mounted) setState(() {});
  }

  Future<void> _editRecurrence() async {
    final result = await showModalBottomSheet<_RecurrenceChoice>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      builder: (_) => _RecurrenceSheet(
        initial: _RecurrenceChoice(
          enabled: recurring,
          frequency: recurringFrequency,
          interval: recurringInterval,
          // As before: switching the recurrence on starts from the chosen date.
          day: recurring ? recurringDay : selectedDate.day,
          endDate: recurringEndDate,
        ),
        startDate: selectedDate,
      ),
    );
    if (result == null || !mounted) return;
    setState(() {
      recurring = result.enabled;
      recurringFrequency = result.frequency;
      recurringInterval = result.interval;
      recurringDay = result.day;
      recurringEndDate = result.endDate;
    });
  }

  String _dateLabel(AppLocalizations t, String locale) {
    final today = DateTime.now();
    final day = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
    );
    final start = DateTime(today.year, today.month, today.day);
    if (day == start) return t.today;
    if (day == start.subtract(const Duration(days: 1))) return t.yesterday;
    return selectedDate.year == today.year
        ? DateFormat.MMMd(locale).format(selectedDate)
        : DateFormat.yMMMd(locale).format(selectedDate);
  }

  String _dateCaption(AppLocalizations t, String locale) {
    final label = _dateLabel(t, locale);
    final full = selectedDate.year == DateTime.now().year
        ? DateFormat.MMMMd(locale).format(selectedDate)
        : DateFormat.yMMMMd(locale).format(selectedDate);
    return label == t.today || label == t.yesterday ? '$label · $full' : full;
  }

  Future<void> _save(bool canSave) async {
    if (_saving) return;
    if (!canSave) {
      HapticFeedback.mediumImpact();
      _triggerShake();
      return;
    }
    setState(() => _saving = true);

    final cents = amountMinor;
    final notifier = ref.read(transactionProvider.notifier);
    final t = AppLocalizations.of(context)!;
    final note = noteController.text.trim().isEmpty
        ? null
        : noteController.text.trim();

    try {
      if (recurring) {
        await notifier.addRecurringTransaction(
          amountCents: cents,
          isIncome: isIncome,
          categoryId: selectedCategory!.id,
          dayOfMonth: recurringDay,
          startDate: selectedDate,
          note: note,
          currencyCode: selectedCurrency,
          frequency: recurringFrequency,
          interval: recurringInterval,
          dayOfWeek: recurringFrequency == RecurrenceFrequency.weekly
              ? selectedDate.weekday
              : null,
          monthOfYear: recurringFrequency == RecurrenceFrequency.yearly
              ? selectedDate.month
              : null,
          endDate: recurringEndDate,
        );

        ref.invalidate(recurringProvider);
        ref.invalidate(transactionProvider);

        if (mounted) {
          final locale = Localizations.localeOf(context).toString();

          final nextDate = DateTime(
            DateTime.now().year,
            DateTime.now().month,
            recurringDay,
          );

          final formatted = DateFormat.yMMMd(locale).format(nextDate);

          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text("${t.recurringCreationMsg} • $formatted"),
                duration: const Duration(seconds: 4),
              ),
            );
        }
      } else {
        await notifier.addTransaction(
          amountCents: cents,
          isIncome: isIncome,
          categoryId: selectedCategory!.id,
          date: selectedDate,
          note: note,
          currencyCode: selectedCurrency,
          receiptPath: receiptPath,
        );
        _receiptCommitted = true;
      }
    } catch (_) {
      if (mounted) setState(() => _saving = false);
      rethrow;
    }

    if (!mounted) return;
    HapticFeedback.lightImpact();
    setState(() => _saved = true);
    if (!_animationsOff) {
      await Future<void>.delayed(const Duration(milliseconds: 420));
    }
    if (mounted) Navigator.pop(context);
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
      if (selectedCategory != null) {
        _pendingCategoryId = null;
        _revealCategory(selectedCategory!.id);
      }
    }

    final filtered = categories.where((c) => c.isIncome == isIncome).toList();
    if (selectedCategory != null &&
        selectedCategory!.isIncome == isIncome &&
        !filtered.any((c) => c.id == selectedCategory!.id)) {
      filtered.insert(0, selectedCategory!);
    }

    _carouselIds = [for (final c in filtered) c.id];

    final canSave = amountMinor > 0 && selectedCategory != null;
    final colors = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final flowColor = VaultColors.flow(context, isIncome);
    final locale = Localizations.localeOf(context).toString();
    final symbol = NumberFormat.simpleCurrency(
      locale: locale,
      name: selectedCurrency,
    ).currencySymbol;
    final note = noteController.text.trim();
    final motion = _animationsOff
        ? Duration.zero
        : const Duration(milliseconds: 280);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 10,
      ),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: widget.scrollController,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: _gutter([
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
                            width: 40,
                            height: 5,
                            decoration: BoxDecoration(
                              color: colors.onSurfaceVariant.withValues(
                                alpha: .38,
                              ),
                              borderRadius: BorderRadius.circular(99),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  /// HEADER
                  Row(
                    children: [
                      _RoundButton(
                        key: const ValueKey('quick-add-close'),
                        icon: Icons.close_rounded,
                        tooltip: MaterialLocalizations.of(
                          context,
                        ).closeButtonTooltip,
                        onPressed: () => Navigator.maybePop(context),
                      ),
                      Expanded(
                        child: Center(
                          child: _FlowToggle(
                            isIncome: isIncome,
                            onChanged: (value) {
                              if (value == isIncome) return;
                              HapticFeedback.selectionClick();
                              setState(() {
                                isIncome = value;
                                selectedCategory = null;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 40),
                    ],
                  ),

                  const SizedBox(height: 24),

                  /// AMOUNT + GLOW
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        left: -16,
                        right: -16,
                        top: -12,
                        bottom: -36,
                        child: IgnorePointer(
                          child: _Glow(
                            color: flowColor.withValues(
                              alpha: dark ? .22 : .16,
                            ),
                            breathe: _breathe,
                          ),
                        ),
                      ),
                      Column(
                        children: [
                          Text(
                            _dateCaption(t, locale),
                            style: TextStyle(
                              fontSize: 13,
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {},
                            child: SizedBox(
                              width: double.infinity,
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: TweenAnimationBuilder<Color?>(
                                  tween: ColorTween(
                                    end: amountMinor > 0
                                        ? flowColor
                                        : colors.onSurface.withValues(
                                            alpha: .3,
                                          ),
                                  ),
                                  duration: _animationsOff
                                      ? Duration.zero
                                      : const Duration(milliseconds: 400),
                                  builder: (_, color, _) => Row(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          top: 10,
                                          right: 4,
                                        ),
                                        child: Text(
                                          symbol,
                                          style: TextStyle(
                                            fontSize: 28,
                                            fontWeight: FontWeight.w600,
                                            color: color?.withValues(
                                              alpha: (color.a * .75),
                                            ),
                                          ),
                                        ),
                                      ),
                                      AnimatedSwitcher(
                                        duration: _animationsOff
                                            ? Duration.zero
                                            : const Duration(milliseconds: 220),
                                        switchInCurve: Curves.easeOutCubic,
                                        transitionBuilder: (child, animation) =>
                                            FadeTransition(
                                              opacity: animation,
                                              child: SlideTransition(
                                                position: Tween(
                                                  begin: const Offset(0, .08),
                                                  end: Offset.zero,
                                                ).animate(animation),
                                                child: child,
                                              ),
                                            ),
                                        layoutBuilder: (current, previous) =>
                                            Stack(
                                              alignment: Alignment.center,
                                              children: [...previous, ?current],
                                            ),
                                        child: Text(
                                          amountDisplayText(
                                            amountMinor,
                                            selectedCurrency!,
                                            locale,
                                          ),
                                          key: ValueKey(
                                            '$amountMinor:$selectedCurrency',
                                          ),
                                          style: TextStyle(
                                            fontSize: 64,
                                            height: 1.05,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: -2.6,
                                            color: color,
                                            fontFeatures: const [
                                              FontFeature.tabularFigures(),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          CurrencySelector(
                            value: selectedCurrency!,
                            compact: true,
                            onChanged: (currency) {
                              setState(() {
                                selectedCurrency = currency;
                                amountMinor = 0;
                              });
                            },
                          ),
                          if (amountMinor > 0 &&
                              selectedCurrency != baseCurrency &&
                              currencyState != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              _conversionPreview(
                                    currencyState,
                                    baseCurrency,
                                    locale,
                                  ) ??
                                  t.conversionOnSave,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  /// CATEGORY CAROUSEL
                  _EdgeToEdge(
                    child: SizedBox(
                      height: 96,
                      child: ListView(
                        key: const ValueKey('quick-category-carousel'),
                        controller: _carousel,
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 2,
                        ),
                        physics: const BouncingScrollPhysics(),
                        children: [
                          for (final c in filtered) ...[
                            _CategoryTile(
                              key: ValueKey('tile-${c.id}'),
                              category: c,
                              selected: selectedCategory?.id == c.id,
                              duration: motion,
                              onTap: () => _selectCategory(c),
                            ),
                            const SizedBox(width: _tileGap),
                          ],
                          _NewCategoryTile(
                            label: t.newCategoryShort,
                            tooltip: t.newCategory,
                            onTap: _createCategory,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  /// NOTE / DATE / REPEAT
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _ActionPill(
                        key: const ValueKey('quick-note'),
                        icon: Icons.notes_rounded,
                        label: note.isEmpty ? t.note : note,
                        active: note.isNotEmpty,
                        onTap: _editNote,
                      ),
                      _ActionPill(
                        key: const ValueKey('quick-date'),
                        icon: Icons.calendar_today_rounded,
                        label: _dateLabel(t, locale),
                        onTap: _pickDate,
                      ),
                      _ActionPill(
                        key: const ValueKey('quick-repeat'),
                        icon: Icons.autorenew_rounded,
                        label: recurring
                            ? _everyLabel(
                                t,
                                recurringFrequency,
                                recurringInterval,
                              )
                            : t.repeat,
                        active: recurring,
                        onTap: _editRecurrence,
                      ),
                      if (!recurring && receiptPath != null)
                        _ActionPill(
                          key: const ValueKey('quick-receipt'),
                          icon: Icons.receipt_long_rounded,
                          label: t.receiptAttached,
                          active: true,
                          color: VaultColors.income(context),
                          onTap: () {},
                          onRemove: () async {
                            final path = receiptPath;
                            setState(() => receiptPath = null);
                            await ref
                                .read(receiptStorageServiceProvider)
                                .remove(path);
                          },
                        ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  /// KEYPAD
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final keyWidth = (constraints.maxWidth - 16) / 3;
                      return GridView.count(
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        crossAxisCount: 3,
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        physics: const NeverScrollableScrollPhysics(),
                        childAspectRatio: keyWidth / 50,
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
                      );
                    },
                  ),

                  const SizedBox(height: 12),
                ]),
              ),
            ),
          ),

          /// SAVE: pinned below the scrolling content, above the home indicator.
          SafeArea(
            top: false,
            minimum: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
              child: AnimatedSlide(
                duration: const Duration(milliseconds: 120),
                offset: shake ? const Offset(-0.02, 0) : Offset.zero,
                child: _SaveButton(
                  label: t.saveTransaction,
                  savedLabel: t.saved,
                  enabled: canSave,
                  saved: _saved,
                  duration: motion,
                  onPressed: () => _save(canSave),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Keeps the 16 px side gutter on every row except the carousel, which
  /// runs edge to edge.
  List<Widget> _gutter(List<Widget> children) => [
    for (final child in children)
      child is _EdgeToEdge
          ? child.child
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: child,
            ),
  ];

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

/// Soft two-lobed light behind the amount. It takes the flow color and
/// breathes once per digit, never continuously.
class _Glow extends StatelessWidget {
  const _Glow({required this.color, required this.breathe});

  final Color color;
  final Animation<double> breathe;

  @override
  Widget build(BuildContext context) {
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 600);
    return TweenAnimationBuilder<Color?>(
      tween: ColorTween(end: color),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (_, tint, _) => AnimatedBuilder(
        animation: breathe,
        builder: (_, _) {
          final pulse = Curves.easeOut.transform(
            breathe.value < .5 ? breathe.value * 2 : (1 - breathe.value) * 2,
          );
          final c = tint ?? color;
          // Radial gradients are circular: widen them into a soft ellipse.
          // Each fades to zero inside the box, so no edge ever shows.
          return Transform.scale(
            scaleX: 1.45 * (1 + .03 * pulse),
            scaleY: 1 + .03 * pulse,
            child: Stack(
              fit: StackFit.expand,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: const Alignment(-.25, .05),
                      radius: .46,
                      colors: [c, c.withValues(alpha: 0)],
                    ),
                  ),
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: const Alignment(.35, -.15),
                      radius: .38,
                      colors: [c, c.withValues(alpha: 0)],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Tooltip(
      message: tooltip,
      child: Material(
        color: colors.surface,
        shape: CircleBorder(
          side: BorderSide(color: colors.outlineVariant, width: .7),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: SizedBox.square(
            dimension: 40,
            child: Icon(icon, size: 20, color: colors.onSurface),
          ),
        ),
      ),
    );
  }
}

/// Expense / income switch with a sliding thumb.
class _FlowToggle extends StatelessWidget {
  const _FlowToggle({required this.isIncome, required this.onChanged});

  final bool isIncome;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: 184,
      height: 40,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            alignment: isIncome ? Alignment.centerRight : Alignment.centerLeft,
            duration: MediaQuery.disableAnimationsOf(context)
                ? Duration.zero
                : const Duration(milliseconds: 320),
            curve: Curves.easeOutBack,
            child: FractionallySizedBox(
              widthFactor: .5,
              heightFactor: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(11),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: .06),
                      blurRadius: 6,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Row(
            children: [
              for (final income in [false, true])
                Expanded(
                  child: Semantics(
                    button: true,
                    selected: isIncome == income,
                    child: InkWell(
                      key: ValueKey(
                        'flow-switch-${income ? 'income' : 'expense'}',
                      ),
                      borderRadius: BorderRadius.circular(11),
                      onTap: () => onChanged(income),
                      child: Center(
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 240),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isIncome == income
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: isIncome == income
                                ? VaultColors.flow(context, income)
                                : colors.onSurfaceVariant,
                          ),
                          child: Text(
                            income ? t.income : t.expense,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    super.key,
    required this.category,
    required this.selected,
    required this.duration,
    required this.onTap,
  });

  final Category category;
  final bool selected;
  final Duration duration;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final tint = Color(category.color);
    return Semantics(
      button: true,
      selected: selected,
      child: AnimatedScale(
        scale: selected ? 1.05 : 1,
        duration: duration,
        curve: Curves.easeOutBack,
        child: AnimatedContainer(
          key: ValueKey('quick-category-${category.id}'),
          duration: duration,
          curve: Curves.easeOutCubic,
          width: _QuickAddTransactionSheetState._tileExtent,
          decoration: BoxDecoration(
            color: selected
                ? Color.alphaBlend(tint.withValues(alpha: .08), colors.surface)
                : colors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected
                  ? tint.withValues(alpha: .55)
                  : colors.outlineVariant,
              width: selected ? 1.2 : .7,
            ),
          ),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CategoryAvatar(category: category, size: 36),
                    const SizedBox(height: 8),
                    Text(
                      categoryName(category.name, t),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NewCategoryTile extends StatelessWidget {
  const _NewCategoryTile({
    required this.label,
    required this.tooltip,
    required this.onTap,
  });

  final String label;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Tooltip(
      message: tooltip,
      child: Material(
        color: colors.primary.withValues(alpha: .05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: colors.primary.withValues(alpha: .28)),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          key: const ValueKey('quick-category-new'),
          onTap: onTap,
          child: SizedBox(
            width: 78,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: .1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.add_rounded, color: colors.primary),
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: colors.primary,
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

class _ActionPill extends StatelessWidget {
  const _ActionPill({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = false,
    this.color,
    this.onRemove,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool active;
  final Color? color;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final tint = color ?? colors.primary;
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.sizeOf(context).width - 32,
      ),
      child: AnimatedContainer(
        duration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : const Duration(milliseconds: 240),
        height: 36,
        decoration: BoxDecoration(
          color: active
              ? Color.alphaBlend(tint.withValues(alpha: .1), colors.surface)
              : colors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: active ? tint.withValues(alpha: .45) : colors.outlineVariant,
            width: .7,
          ),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onTap,
            child: Padding(
              padding: EdgeInsets.only(
                left: 12,
                right: onRemove == null ? 12 : 4,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 16, color: tint),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                        color: active ? tint : colors.onSurface,
                      ),
                    ),
                  ),
                  if (onRemove != null)
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints.tightFor(
                        width: 28,
                        height: 28,
                      ),
                      icon: Icon(Icons.close_rounded, size: 16, color: tint),
                      onPressed: onRemove,
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

class _SaveButton extends StatelessWidget {
  const _SaveButton({
    required this.label,
    required this.savedLabel,
    required this.enabled,
    required this.saved,
    required this.duration,
    required this.onPressed,
  });

  final String label;
  final String savedLabel;
  final bool enabled;
  final bool saved;
  final Duration duration;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final background = saved
        ? VaultColors.income(context)
        : enabled
        ? colors.primary
        : colors.surfaceContainerHighest;
    final foreground = saved
        ? colors.surface
        : enabled
        ? colors.onPrimary
        : colors.onSurfaceVariant;
    return AnimatedContainer(
      duration: duration,
      curve: Curves.easeOutCubic,
      height: 54,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          key: const ValueKey('quick-save'),
          borderRadius: BorderRadius.circular(16),
          onTap: saved ? null : onPressed,
          child: Center(
            child: AnimatedSwitcher(
              duration: duration,
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween(
                    begin: const Offset(0, .35),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              ),
              child: saved
                  ? Row(
                      key: const ValueKey('saved'),
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_rounded, color: foreground),
                        const SizedBox(width: 8),
                        Text(
                          savedLabel,
                          style: TextStyle(
                            color: foreground,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    )
                  : Text(
                      label,
                      key: const ValueKey('save'),
                      style: TextStyle(
                        color: foreground,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

/// "Ogni mese", "Ogni 2 settimane", ...
String _everyLabel(
  AppLocalizations t,
  RecurrenceFrequency frequency,
  int interval,
) => switch (frequency) {
  RecurrenceFrequency.daily => t.recurrenceEveryDays(interval),
  RecurrenceFrequency.weekly => t.recurrenceEveryWeeks(interval),
  RecurrenceFrequency.monthly => t.recurrenceEveryMonths(interval),
  RecurrenceFrequency.yearly => t.recurrenceEveryYears(interval),
};

class _EdgeToEdge extends StatelessWidget {
  const _EdgeToEdge({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => child;
}

class _RecurrenceChoice {
  final bool enabled;
  final RecurrenceFrequency frequency;
  final int interval;
  final int day;
  final DateTime? endDate;

  const _RecurrenceChoice({
    required this.enabled,
    required this.frequency,
    required this.interval,
    required this.day,
    required this.endDate,
  });
}

/// Recurrence options of a new movement: the same fields as before, gathered
/// in their own sheet behind the Repeat pill.
class _RecurrenceSheet extends StatefulWidget {
  const _RecurrenceSheet({required this.initial, required this.startDate});

  final _RecurrenceChoice initial;
  final DateTime startDate;

  @override
  State<_RecurrenceSheet> createState() => _RecurrenceSheetState();
}

class _RecurrenceSheetState extends State<_RecurrenceSheet> {
  late bool enabled = widget.initial.enabled;
  late RecurrenceFrequency frequency = widget.initial.frequency;
  late int interval = widget.initial.interval;
  late int day = widget.initial.day;
  late DateTime? endDate = widget.initial.endDate;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final locale = Localizations.localeOf(context);
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              t.repeat,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: -.3,
              ),
            ),
            const SizedBox(height: 12),
            VaultSurface(
              padding: const EdgeInsets.fromLTRB(16, 4, 8, 4),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t.recurrent,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              enabled
                                  ? _everyLabel(t, frequency, interval)
                                  : t.recurrentMsg,
                              style: TextStyle(
                                fontSize: 12,
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        key: const ValueKey('quick-recurring-switch'),
                        value: enabled,
                        onChanged: (value) => setState(() {
                          enabled = value;
                          if (value) day = widget.startDate.day;
                        }),
                      ),
                    ],
                  ),
                  AnimatedSize(
                    duration: MediaQuery.disableAnimationsOf(context)
                        ? Duration.zero
                        : const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    child: !enabled
                        ? const SizedBox(width: double.infinity)
                        : Column(
                            children: [
                              Divider(height: 12, color: colors.outlineVariant),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 6,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        t.repeatEvery,
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ),
                                    VaultPillDropdown<int>(
                                      key: const ValueKey(
                                        'quick-recurring-interval',
                                      ),
                                      value: interval,
                                      items: {
                                        for (var i = 1; i <= 12; i++) i: '$i',
                                      },
                                      onChanged: (value) =>
                                          setState(() => interval = value),
                                    ),
                                    const SizedBox(width: 8),
                                    VaultPillDropdown<RecurrenceFrequency>(
                                      key: const ValueKey(
                                        'quick-recurring-frequency',
                                      ),
                                      value: frequency,
                                      items: {
                                        for (final value
                                            in RecurrenceFrequency.values)
                                          value: recurrenceFrequencyLabel(
                                            value,
                                            locale,
                                          ),
                                      },
                                      onChanged: (value) =>
                                          setState(() => frequency = value),
                                    ),
                                  ],
                                ),
                              ),
                              if (frequency == RecurrenceFrequency.monthly ||
                                  frequency == RecurrenceFrequency.yearly)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 6,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          t.dayOfMonth,
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ),
                                      VaultPillDropdown<int>(
                                        key: const ValueKey(
                                          'quick-recurring-day',
                                        ),
                                        value: day,
                                        items: {
                                          for (var i = 1; i <= 31; i++) i: '$i',
                                        },
                                        onChanged: (value) =>
                                            setState(() => day = value),
                                      ),
                                    ],
                                  ),
                                ),
                              VaultOptionRow(
                                icon: Icons.event_busy_outlined,
                                label: t.endDate,
                                value: endDate == null
                                    ? t.none
                                    : DateFormat.yMMMd(
                                        locale.toString(),
                                      ).format(endDate!),
                                trailing: endDate == null
                                    ? null
                                    : IconButton(
                                        visualDensity: VisualDensity.compact,
                                        icon: const Icon(
                                          Icons.close_rounded,
                                          size: 18,
                                        ),
                                        onPressed: () =>
                                            setState(() => endDate = null),
                                      ),
                                onTap: () async {
                                  final value = await showDatePicker(
                                    context: context,
                                    initialDate:
                                        endDate ??
                                        widget.startDate.add(
                                          const Duration(days: 30),
                                        ),
                                    firstDate: widget.startDate,
                                    lastDate: DateTime(
                                      widget.startDate.year + 20,
                                    ),
                                  );
                                  if (value != null) {
                                    setState(() => endDate = value);
                                  }
                                },
                              ),
                            ],
                          ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              key: const ValueKey('quick-recurring-done'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
              ),
              onPressed: () => Navigator.pop(
                context,
                _RecurrenceChoice(
                  enabled: enabled,
                  frequency: frequency,
                  interval: interval,
                  day: day,
                  endDate: endDate,
                ),
              ),
              child: Text(t.done),
            ),
          ],
        ),
      ),
    );
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
          color: widget.icon != null ? Colors.transparent : colors.surface,
          borderRadius: BorderRadius.circular(16),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            overlayColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.pressed)) {
                return colors.primary.withValues(alpha: .11);
              }
              return Colors.transparent;
            }),
            onHighlightChanged: (highlighted) {
              if (mounted) setState(() => scale = highlighted ? .94 : 1);
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
                  ? Icon(widget.icon, size: 22, color: colors.onSurfaceVariant)
                  : Text(
                      widget.label!,
                      style: TextStyle(
                        color: colors.onSurface,
                        fontSize: widget.label == '00' ? 19 : 23,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -.5,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

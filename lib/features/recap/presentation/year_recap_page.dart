import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/currency/currency_metadata.dart';
import '../../../core/currency/currency_provider.dart';
import '../../../core/database/app_database.dart';
import '../../../core/utils/category_localization.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/vault_style.dart';
import '../../budgets/providers/budget_provider.dart';
import '../../goals/providers/savings_goals_provider.dart';
import '../../transactions/domain/category.dart';
import '../../transactions/presentation/quick_add_transaction_sheet.dart'
    show recurrenceEveryLabel;
import '../../transactions/domain/recurrence_calculator.dart';
import '../../transactions/providers/category_provider.dart';
import '../../transactions/providers/recurring_provider.dart';
import '../../transactions/providers/transaction_provider.dart';
import '../domain/year_recap.dart';

/// Today, injectable so tests and captures can stand in December.
final recapClockProvider = Provider<DateTime Function()>((_) => DateTime.now);

/// The recap of [year] from the live archive, or null while loading.
final yearRecapProvider = Provider.family<YearRecap?, int>((ref, year) {
  final transactions = ref.watch(transactionProvider).value;
  final recurring = ref.watch(recurringProvider).value;
  final goals = ref.watch(savingsGoalsProvider).value;
  final budgets = ref.watch(budgetProvider).value;
  if (transactions == null ||
      recurring == null ||
      goals == null ||
      budgets == null) {
    return null;
  }
  return buildYearRecap(
    year: year,
    transactions: transactions,
    recurring: recurring,
    goals: goals,
    budgets: budgets,
    now: ref.watch(recapClockProvider)(),
  );
});

Future<void> showYearRecap(BuildContext context, int year) {
  return Navigator.of(context, rootNavigator: true).push(
    PageRouteBuilder<void>(
      fullscreenDialog: true,
      transitionDuration: const Duration(milliseconds: 360),
      pageBuilder: (_, _, _) => YearRecapPage(year: year),
      transitionsBuilder: (_, animation, _, child) => FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween(begin: .96, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
          ),
          child: child,
        ),
      ),
    ),
  );
}

/// Everything a card needs to render, resolved once per build.
class _RecapContext {
  final YearRecap recap;
  final AppLocalizations t;
  final String locale;
  final Map<String, Category> categories;
  final String Function(int minor) money;
  final String Function(int minor) round;

  const _RecapContext({
    required this.recap,
    required this.t,
    required this.locale,
    required this.categories,
    required this.money,
    required this.round,
  });

  String categoryLabel(String id) {
    final category = categories[id];
    return category == null ? id : categoryName(category.name, t);
  }

  String month(int month, {bool capital = false}) {
    final name = DateFormat.MMMM(locale).format(DateTime(2000, month));
    return capital ? toBeginningOfSentenceCase(name, locale) : name;
  }
}

class _RecapCard {
  final Color Function(BuildContext context, _RecapContext data) tint;
  final Widget Function(BuildContext context, _RecapContext data) build;

  const _RecapCard(this.tint, this.build);
}

class YearRecapPage extends ConsumerStatefulWidget {
  const YearRecapPage({super.key, required this.year, this.autoAdvance = true});

  final int year;

  /// Off in tests, where a running timer would never let the UI settle.
  final bool autoAdvance;

  static const cardDuration = Duration(seconds: 6);

  @override
  ConsumerState<YearRecapPage> createState() => _YearRecapPageState();
}

class _YearRecapPageState extends ConsumerState<YearRecapPage>
    with SingleTickerProviderStateMixin {
  late final _progress = AnimationController(
    vsync: this,
    duration: YearRecapPage.cardDuration,
  )..addStatusListener(_onProgress);
  int _index = 0;
  int _count = 0;

  @override
  void initState() {
    super.initState();
    if (widget.autoAdvance) _progress.forward();
  }

  @override
  void dispose() {
    _progress.dispose();
    super.dispose();
  }

  void _onProgress(AnimationStatus status) {
    if (status == AnimationStatus.completed && _index < _count - 1) _go(1);
  }

  void _go(int delta) {
    final next = (_index + delta).clamp(0, _count - 1);
    if (next == _index && delta != 0) {
      // Already at an end: replay the current card instead of nothing.
      if (widget.autoAdvance && delta < 0) _progress.forward(from: 0);
      return;
    }
    HapticFeedback.selectionClick();
    setState(() => _index = next);
    if (widget.autoAdvance) _progress.forward(from: 0);
  }

  void _pause() {
    if (_progress.isAnimating) _progress.stop();
  }

  void _resume() {
    if (widget.autoAdvance && !_progress.isCompleted) _progress.forward();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final recap = ref.watch(yearRecapProvider(widget.year));
    final categories = ref.watch(categoryProvider).value ?? const [];
    final currency = ref.watch(currencyProvider).value?.baseCurrency ?? 'EUR';
    final locale = Localizations.localeOf(context).toString();
    final colors = Theme.of(context).colorScheme;
    final reduce = MediaQuery.disableAnimationsOf(context);

    if (recap == null || recap.isEmpty) {
      return Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              Center(
                child: recap == null
                    ? const CircularProgressIndicator.adaptive()
                    : Text(t.recapNoData),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  key: const ValueKey('recap-close'),
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final data = _RecapContext(
      recap: recap,
      t: t,
      locale: locale,
      categories: {for (final c in categories) c.id: c},
      money: (minor) => formatMoney(minor, currency, locale),
      round: (minor) => NumberFormat.simpleCurrency(
        locale: locale,
        name: currency,
        decimalDigits: 0,
      ).format(minorToMajor(minor, currency)),
    );
    final cards = _recapCards(recap);
    _count = cards.length;
    _index = _index.clamp(0, cards.length - 1);
    final card = cards[_index];
    final tint = card.tint(context, data);
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: TweenAnimationBuilder<Color?>(
        tween: ColorTween(end: tint),
        duration: reduce ? Duration.zero : const Duration(milliseconds: 600),
        builder: (context, color, child) => DecoratedBox(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            gradient: RadialGradient(
              center: const Alignment(-.7, -.8),
              radius: 1.1,
              colors: [
                (color ?? tint).withValues(alpha: dark ? .28 : .2),
                Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0),
              ],
            ),
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(.9, .9),
                radius: .9,
                colors: [
                  (color ?? tint).withValues(alpha: dark ? .18 : .12),
                  Theme.of(
                    context,
                  ).scaffoldBackgroundColor.withValues(alpha: 0),
                ],
              ),
            ),
            child: child,
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: _ProgressBars(
                  count: cards.length,
                  index: _index,
                  progress: _progress,
                  autoAdvance: widget.autoAdvance,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 4, 0),
                child: Row(
                  children: [
                    VaultWalletMark(color: colors.onSurface),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          text: t.recapTitle('${widget.year}'),
                          children: [
                            TextSpan(
                              text: ' · Pockets Vault',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      key: const ValueKey('recap-close'),
                      tooltip: MaterialLocalizations.of(
                        context,
                      ).closeButtonTooltip,
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) => GestureDetector(
                    key: const ValueKey('recap-stories'),
                    behavior: HitTestBehavior.opaque,
                    onTapUp: (details) => _go(
                      details.localPosition.dx < constraints.maxWidth * .3
                          ? -1
                          : 1,
                    ),
                    onLongPressStart: (_) => _pause(),
                    onLongPressEnd: (_) => _resume(),
                    onHorizontalDragEnd: (details) {
                      final velocity = details.primaryVelocity ?? 0;
                      if (velocity.abs() > 200) _go(velocity < 0 ? 1 : -1);
                    },
                    child: Semantics(
                      label: t.recapCardOf(_index + 1, cards.length),
                      liveRegion: true,
                      child: AnimatedSwitcher(
                        duration: reduce
                            ? Duration.zero
                            : const Duration(milliseconds: 320),
                        switchInCurve: Curves.easeOutCubic,
                        layoutBuilder: (current, previous) => Stack(
                          alignment: Alignment.topCenter,
                          children: [...previous, ?current],
                        ),
                        transitionBuilder: (child, animation) => FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween(
                              begin: const Offset(0, .04),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                        ),
                        child: SingleChildScrollView(
                          key: ValueKey('recap-card-$_index'),
                          padding: const EdgeInsets.fromLTRB(20, 40, 20, 16),
                          child: _CardEnter(child: card.build(context, data)),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: FilledButton.tonalIcon(
                  key: const ValueKey('recap-share'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(0, 52),
                    backgroundColor: colors.surface,
                    foregroundColor: colors.onSurface,
                    side: BorderSide(color: colors.outlineVariant, width: .7),
                  ),
                  onPressed: () async {
                    _pause();
                    await _showRecapShareSheet(context, data);
                    _resume();
                  },
                  icon: const Icon(Icons.ios_share_rounded, size: 20),
                  label: Text(t.recapShare),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The cards shown for [recap]; cards without data are left out.
List<_RecapCard> _recapCards(YearRecap recap) => [
  const _RecapCard(_incomeTint, _incomeCard),
  if (recap.priciestMonth != null) const _RecapCard(_expenseTint, _monthsCard),
  if (recap.topCategories.isNotEmpty)
    _RecapCard(
      (context, d) => _categoryTint(context, d, recap.topCategories.first.key),
      _categoriesCard,
    ),
  if (recap.biggestExpense != null)
    _RecapCard(
      (context, d) =>
          _categoryTint(context, d, recap.biggestExpense!.categoryId),
      _biggestCard,
    ),
  const _RecapCard(_primaryTint, _rhythmCard),
  if (recap.recurring.isNotEmpty)
    _RecapCard(
      (context, d) =>
          _categoryTint(context, d, recap.recurring.first.row.categoryId),
      _recurringCard,
    ),
  if (recap.goals.isNotEmpty || recap.budgetMonthsKept != null)
    const _RecapCard(_savingsTint, _goalsCard),
  recap.hasPrevious
      ? const _RecapCard(_savingsTint, _compareCard)
      : const _RecapCard(_primaryTint, _firstYearCard),
];

/// How many cards the recap of [recap] shows, e.g. for the Home banner.
int recapCardCount(YearRecap recap) => _recapCards(recap).length;

Color _incomeTint(BuildContext context, _RecapContext _) =>
    VaultColors.income(context);
Color _expenseTint(BuildContext context, _RecapContext _) =>
    VaultColors.expense(context);
Color _savingsTint(BuildContext context, _RecapContext _) =>
    VaultColors.savings(context);
Color _primaryTint(BuildContext context, _RecapContext _) =>
    Theme.of(context).colorScheme.primary;

Color _categoryTint(BuildContext context, _RecapContext data, String id) {
  final category = data.categories[id];
  return category == null
      ? Theme.of(context).colorScheme.primary
      : Color(category.color);
}

class _ProgressBars extends StatelessWidget {
  const _ProgressBars({
    required this.count,
    required this.index,
    required this.progress,
    required this.autoAdvance,
  });

  final int count;
  final int index;
  final Animation<double> progress;
  final bool autoAdvance;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return AnimatedBuilder(
      animation: progress,
      builder: (context, _) => Row(
        children: [
          for (var i = 0; i < count; i++) ...[
            if (i > 0) const SizedBox(width: 4),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  minHeight: 3,
                  value: i < index
                      ? 1
                      : i > index
                      ? 0
                      : autoAdvance
                      ? progress.value
                      : 1,
                  color: colors.onSurface,
                  backgroundColor: colors.onSurface.withValues(alpha: .16),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// A short rise and fade every time a card appears.
class _CardEnter extends StatelessWidget {
  const _CardEnter({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return child;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
      builder: (_, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, 12 * (1 - value)),
          child: child,
        ),
      ),
      child: child,
    );
  }
}

/// Grows from zero to [value]; [format] renders the running number.
class _CountUp extends StatelessWidget {
  const _CountUp({
    required this.value,
    required this.format,
    required this.style,
    super.key,
  });

  final int value;
  final String Function(int value) format;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.disableAnimationsOf(context);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: reduce ? value.toDouble() : 0, end: value.toDouble()),
      duration: reduce ? Duration.zero : const Duration(milliseconds: 1100),
      curve: Curves.easeOutCubic,
      builder: (_, current, _) => FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Text(
          format(current.round()),
          semanticsLabel: format(value),
          style: style.copyWith(
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ),
    );
  }
}

/// Bar that grows to [ratio] of its width or height.
class _GrowBar extends StatelessWidget {
  const _GrowBar({
    required this.ratio,
    required this.color,
    this.vertical = false,
  });

  final double ratio;
  final Color color;
  final bool vertical;

  static const thickness = 6.0;

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.disableAnimationsOf(context);
    final dark = Theme.of(context).brightness == Brightness.dark;
    final track = dark ? const Color(0xFF2C3848) : const Color(0xFFEAEFF5);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: reduce ? ratio : 0, end: ratio.clamp(0, 1)),
      duration: reduce ? Duration.zero : const Duration(milliseconds: 900),
      curve: vertical ? Curves.easeOutBack : Curves.easeOutCubic,
      builder: (_, value, _) {
        final fill = DecoratedBox(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(vertical ? 7 : thickness),
          ),
        );
        if (vertical) {
          return Align(
            alignment: Alignment.bottomCenter,
            child: FractionallySizedBox(
              heightFactor: value.clamp(.02, 1.0),
              widthFactor: 1,
              child: fill,
            ),
          );
        }
        return ClipRRect(
          borderRadius: BorderRadius.circular(thickness),
          child: SizedBox(
            height: thickness,
            width: double.infinity,
            child: ColoredBox(
              color: track,
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: FractionallySizedBox(widthFactor: value, child: fill),
              ),
            ),
          ),
        );
      },
    );
  }
}

TextStyle _kicker(BuildContext context) => TextStyle(
  fontSize: 15,
  fontWeight: FontWeight.w700,
  color: Theme.of(context).colorScheme.onSurfaceVariant,
);

const _headline = TextStyle(
  fontSize: 32,
  height: 1.1,
  fontWeight: FontWeight.w800,
  letterSpacing: -1.2,
);

const _big = TextStyle(
  fontSize: 52,
  height: 1,
  fontWeight: FontWeight.w800,
  letterSpacing: -2,
);

TextStyle _body(BuildContext context) => TextStyle(
  fontSize: 15,
  height: 1.5,
  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: .78),
);

class _Column extends StatelessWidget {
  const _Column(this.children);

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      for (final (i, child) in children.indexed) ...[
        if (i > 0) const SizedBox(height: 16),
        child,
      ],
    ],
  );
}

class _Box extends StatelessWidget {
  const _Box(this.children);

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => VaultSurface(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (i, child) in children.indexed) ...[
          if (i > 0) const SizedBox(height: 12),
          child,
        ],
      ],
    ),
  );
}

class _KeyValue extends StatelessWidget {
  const _KeyValue(this.label, this.value, {this.color});

  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) => _LabelValue(
    label: Text(label, style: const TextStyle(fontSize: 14)),
    value: Text(
      value,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: color,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    ),
  );
}

/// Label on the left, value flush right; a long value shrinks instead of
/// pushing the label out.
class _LabelValue extends StatelessWidget {
  const _LabelValue({required this.label, required this.value});

  final Widget label;
  final Widget value;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => Row(
      children: [
        Expanded(child: label),
        const SizedBox(width: 12),
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: constraints.maxWidth * .6),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: value,
          ),
        ),
      ],
    ),
  );
}

class _Pill extends StatelessWidget {
  const _Pill(this.icon, this.text, this.color);

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: color.withValues(alpha: .14),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ),
      ],
    ),
  );
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({
    required this.category,
    required this.title,
    required this.value,
    this.ratio,
    this.caption,
    this.valueColor,
  });

  final Category? category;
  final String title;
  final String value;
  final double? ratio;
  final String? caption;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final tint = category == null ? colors.primary : Color(category!.color);
    return Row(
      children: [
        CategoryAvatar(category: category, size: 36),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _LabelValue(
                label: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                value: Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: valueColor,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
              if (ratio != null) ...[
                const SizedBox(height: 6),
                _GrowBar(ratio: ratio!, color: tint),
              ],
              if (caption != null) ...[
                const SizedBox(height: 2),
                Text(
                  caption!,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _Columns extends StatelessWidget {
  const _Columns({
    required this.values,
    required this.labels,
    required this.colorFor,
    required this.highlighted,
    this.height = 170,
  });

  final List<int> values;
  final List<String> labels;
  final Color Function(int index) colorFor;

  /// Columns whose label takes the bar color instead of the muted one.
  final bool Function(int index) highlighted;
  final double height;

  @override
  Widget build(BuildContext context) {
    final top = values.fold<int>(1, (max, v) => v > max ? v : max);
    return SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < values.length; i++) ...[
            if (i > 0) const SizedBox(width: 5),
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: _GrowBar(
                      ratio: values[i] / top * .9,
                      color: colorFor(i),
                      vertical: true,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    labels[i],
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: highlighted(i)
                          ? colorFor(i)
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

Color _muted(BuildContext context) =>
    Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: .3);

Widget _incomeCard(BuildContext context, _RecapContext d) {
  final r = d.recap;
  final t = d.t;
  final year = '${r.year}';
  final income = VaultColors.income(context);
  final expense = VaultColors.expense(context);
  final hasIncome = r.incomeMinor > 0;
  return _Column([
    Text(
      hasIncome ? t.recapEarnedIn(year) : t.recapSpentIn(year),
      style: _kicker(context),
    ),
    _CountUp(
      key: const ValueKey('recap-income-total'),
      value: hasIncome ? r.incomeMinor : r.spentMinor,
      format: d.money,
      style: _big.copyWith(color: hasIncome ? income : expense),
    ),
    if (hasIncome)
      _Box([
        _KeyValue(t.recapYouSpent, d.money(r.spentMinor), color: expense),
        _KeyValue(
          t.recapYouKept,
          '${r.netMinor < 0 ? '−' : ''}${d.money(r.netMinor.abs())}',
        ),
      ]),
    if ((r.savedPercent ?? 0) > 0)
      _Pill(
        Icons.trending_up_rounded,
        t.recapKeptPercent(r.savedPercent!),
        income,
      ),
  ]);
}

Widget _monthsCard(BuildContext context, _RecapContext d) {
  final r = d.recap;
  final high = r.priciestMonth!;
  final low = r.lightestMonth!;
  final expense = VaultColors.expense(context);
  final income = VaultColors.income(context);
  return _Column([
    Text(d.t.recapMonthByMonth, style: _kicker(context)),
    Text(
      d.t.recapMonthsHeadline(d.month(high, capital: true), d.month(low)),
      style: _headline,
    ),
    _Box([
      _Columns(
        values: r.monthlySpent,
        labels: [
          for (var m = 1; m <= 12; m++)
            DateFormat('MMMMM', d.locale).format(DateTime(2000, m)),
        ],
        colorFor: (i) => i + 1 == high
            ? expense
            : i + 1 == low
            ? income
            : _muted(context),
        highlighted: (i) => i + 1 == high || i + 1 == low,
      ),
      _KeyValue(d.t.recapMonthlyAverage, d.money(r.averageMonthlySpent)),
    ]),
  ]);
}

Widget _categoriesCard(BuildContext context, _RecapContext d) {
  final r = d.recap;
  final top = r.topCategories.first;
  return _Column([
    Text(d.t.recapWhereItWent, style: _kicker(context)),
    Text(
      d.t.recapTopCategory(
        d.categoryLabel(top.key),
        r.percentOfSpent(top.value),
      ),
      style: _headline,
    ),
    _Box([
      for (final entry in r.topCategories)
        _CategoryRow(
          category: d.categories[entry.key],
          title: d.categoryLabel(entry.key),
          value: '${d.round(entry.value)} · ${r.percentOfSpent(entry.value)}%',
          ratio: entry.value / top.value,
        ),
    ]),
  ]);
}

Widget _biggestCard(BuildContext context, _RecapContext d) {
  final r = d.recap;
  final tx = r.biggestExpense!;
  final note = tx.note?.trim() ?? '';
  final average = r.averageMonthlySpent;
  return _Column([
    Text(d.t.recapBiggest, style: _kicker(context)),
    _Box([
      _CategoryRow(
        category: d.categories[tx.categoryId],
        title: note.isEmpty ? d.categoryLabel(tx.categoryId) : note,
        value: '−${d.money(tx.amountCents)}',
        valueColor: VaultColors.expense(context),
        caption:
            '${DateFormat.MMMMd(d.locale).format(tx.date)} · '
            '${d.categoryLabel(tx.categoryId)}',
      ),
    ]),
    if (average > 0)
      Text(
        d.t.recapBiggestNote((tx.amountCents * 100 / average).round()),
        style: _body(context),
      ),
  ]);
}

Widget _rhythmCard(BuildContext context, _RecapContext d) {
  final r = d.recap;
  final primary = Theme.of(context).colorScheme.primary;
  final busiest = r.busiestWeekday;
  // 2024-01-01 was a Monday: day N of that week is weekday N.
  String weekday(int day, String pattern) =>
      DateFormat(pattern, d.locale).format(DateTime(2024, 1, day));
  return _Column([
    Text(d.t.recapRhythm, style: _kicker(context)),
    _CountUp(
      key: const ValueKey('recap-movement-count'),
      value: r.movementCount,
      format: (v) => NumberFormat.decimalPattern(d.locale).format(v),
      style: _big,
    ),
    Text(
      d.t.recapRhythmBody(
        toBeginningOfSentenceCase(weekday(busiest, 'EEEE'), d.locale),
        r.weekdayCounts[busiest - 1],
      ),
      style: _body(context),
    ),
    _Box([
      _Columns(
        height: 110,
        values: r.weekdayCounts,
        labels: [for (var day = 1; day <= 7; day++) weekday(day, 'EEEEE')],
        colorFor: (i) =>
            i + 1 == busiest ? primary : primary.withValues(alpha: .26),
        highlighted: (i) => i + 1 == busiest,
      ),
    ]),
  ]);
}

Widget _recurringCard(BuildContext context, _RecapContext d) {
  final r = d.recap;
  return _Column([
    Text(d.t.recapRecurring, style: _kicker(context)),
    Text(
      d.t.recapRecurringHeadline(
        r.recurring.length,
        d.round(r.recurringYearlyMinor),
      ),
      style: _headline,
    ),
    _Box([
      for (final item in r.recurring.take(4))
        _CategoryRow(
          category: d.categories[item.row.categoryId],
          title: (item.row.note?.trim().isNotEmpty ?? false)
              ? item.row.note!.trim()
              : d.categoryLabel(item.row.categoryId),
          value: d.money(item.yearlyMinor),
          caption:
              '${recurrenceEveryLabel(d.t, recurrenceFrequencyFromName(item.row.frequency), item.row.interval)}'
              ' · ${d.t.recapTimes(item.occurrences)}',
        ),
    ]),
    Text(
      d.t.recapRecurringShare(r.percentOfSpent(r.recurringYearlyMinor)),
      style: _body(context),
    ),
  ]);
}

Widget _goalsCard(BuildContext context, _RecapContext d) {
  final r = d.recap;
  final savings = VaultColors.savings(context);
  final reached = r.goals.where(
    (g) => g.completed || g.savedAmountMinor >= g.targetAmountMinor,
  );
  return _Column([
    Text(
      r.goals.isEmpty ? d.t.recapBudgetsOnly : d.t.recapGoals,
      style: _kicker(context),
    ),
    if (r.goals.isNotEmpty) ...[
      Text(
        d.t.recapGoalsHeadline(reached.length, r.goals.length),
        style: _headline,
      ),
      _Box([for (final goal in r.goals.take(4)) _GoalRow(goal: goal, data: d)]),
    ],
    if (r.budgetMonthsKept != null)
      _Pill(
        Icons.check_circle_outline_rounded,
        d.t.recapBudgetKept(r.budgetMonthsKept!, r.budgetMonths),
        savings,
      ),
  ]);
}

class _GoalRow extends StatelessWidget {
  const _GoalRow({required this.goal, required this.data});

  final SavingsGoalRow goal;
  final _RecapContext data;

  @override
  Widget build(BuildContext context) {
    final ratio = goal.savedAmountMinor / goal.targetAmountMinor;
    final tint = Color(goal.color);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _KeyValue(
          goal.name,
          ratio >= 1 ? data.t.recapGoalReached : '${(ratio * 100).round()}%',
          color: tint,
        ),
        const SizedBox(height: 6),
        _GrowBar(ratio: ratio, color: tint),
        const SizedBox(height: 2),
        Text(
          data.t.recapGoalOf(
            data.round(goal.savedAmountMinor),
            data.round(goal.targetAmountMinor),
          ),
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

Widget _compareCard(BuildContext context, _RecapContext d) {
  final r = d.recap;
  final change = r.spentChangePercent!;
  final savings = VaultColors.savings(context);
  final muted = _muted(context);
  final previousSaved = r.previousSavedPercent;
  return _Column([
    Text(d.t.recapComparedTo('${r.year - 1}'), style: _kicker(context)),
    Text(
      change <= 0
          ? d.t.recapSpentLess(change.abs())
          : d.t.recapSpentMore(change),
      style: _headline,
    ),
    _Box([
      SizedBox(
        height: 180,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (final (label, value, color) in [
              ('${r.year - 1}', r.previousSpentMinor!, muted),
              ('${r.year}', r.spentMinor, savings),
            ]) ...[
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      d.round(value),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Expanded(
                      child: _GrowBar(
                        ratio:
                            value /
                            (r.previousSpentMinor! > r.spentMinor
                                ? r.previousSpentMinor!
                                : r.spentMinor),
                        color: color,
                        vertical: true,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
            ],
          ],
        ),
      ),
    ]),
    if (previousSaved != null && r.savedPercent != null)
      _Pill(
        Icons.trending_up_rounded,
        d.t.recapSavingFromTo(previousSaved, r.savedPercent!),
        VaultColors.income(context),
      ),
  ]);
}

Widget _firstYearCard(BuildContext context, _RecapContext d) {
  final r = d.recap;
  final started = r.firstMovement;
  return _Column([
    Text(d.t.recapFirstYear, style: _kicker(context)),
    Text(
      started != null && started.month > 1
          ? d.t.recapStartedIn(d.month(started.month))
          : d.t.recapWholeYear,
      style: _headline,
    ),
    _Box([
      _KeyValue(d.t.transactions, '${r.movementCount}'),
      if (r.categoryCount > 0)
        _KeyValue(d.t.recapCategoriesUsed, '${r.categoryCount}'),
      _KeyValue(
        d.t.recapSaved,
        '${r.netMinor < 0 ? '−' : ''}${d.money(r.netMinor.abs())}',
        color: r.netMinor >= 0 ? VaultColors.income(context) : null,
      ),
    ]),
    Text(d.t.recapNextYear('${r.year}'), style: _body(context)),
  ]);
}

// ---------------------------------------------------------------- Sharing

Future<void> _showRecapShareSheet(BuildContext context, _RecapContext data) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    useSafeArea: true,
    builder: (_) => _RecapShareSheet(data: data),
  );
}

class _RecapShareSheet extends StatefulWidget {
  const _RecapShareSheet({required this.data});

  final _RecapContext data;

  @override
  State<_RecapShareSheet> createState() => _RecapShareSheetState();
}

class _RecapShareSheetState extends State<_RecapShareSheet> {
  final _boundary = GlobalKey();
  bool _hide = false;
  bool _busy = false;

  String _text() {
    final d = widget.data;
    final r = d.recap;
    final year = '${r.year}';
    if (_hide) {
      final saved = r.savedPercent;
      return saved != null && saved > 0
          ? d.t.recapShareTextHidden(year, saved)
          : d.t.recapShareTextPlain(year, r.movementCount);
    }
    return d.t.recapShareText(
      year,
      d.round(r.spentMinor),
      d.round(r.netMinor < 0 ? 0 : r.netMinor),
    );
  }

  Rect? _origin() {
    final box = context.findRenderObject();
    if (box is! RenderBox || !box.hasSize) return null;
    return box.localToGlobal(Offset.zero) & box.size;
  }

  Future<void> _shareImage() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final boundary =
          _boundary.currentContext!.findRenderObject()!
              as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 4);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      final directory = await getTemporaryDirectory();
      final file = File(
        '${directory.path}/pockets-vault-${widget.data.recap.year}.png',
      );
      await file.writeAsBytes(bytes!.buffer.asUint8List(), flush: true);
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: 'image/png')],
          text: _text(),
          sharePositionOrigin: _origin(),
        ),
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$error')));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.data.t;
    final colors = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            t.recapShareTitle,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: -.6,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: SizedBox(
              width: 280,
              child: RepaintBoundary(
                key: _boundary,
                child: _ShareImage(data: widget.data, hide: _hide),
              ),
            ),
          ),
          const SizedBox(height: 16),
          VaultSurface(
            padding: const EdgeInsets.fromLTRB(16, 4, 8, 4),
            child: SwitchListTile.adaptive(
              key: const ValueKey('recap-hide-amounts'),
              contentPadding: EdgeInsets.zero,
              title: Text(
                t.recapHideAmounts,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                t.recapHideAmountsCaption,
                style: TextStyle(color: colors.onSurfaceVariant),
              ),
              value: _hide,
              onChanged: (value) => setState(() => _hide = value),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            key: const ValueKey('recap-share-image'),
            style: FilledButton.styleFrom(minimumSize: const Size(0, 52)),
            onPressed: _busy ? null : _shareImage,
            icon: const Icon(Icons.ios_share_rounded, size: 20),
            label: Text(t.recapShareImage),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            key: const ValueKey('recap-copy-text'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(0, 48),
              side: BorderSide(color: colors.outlineVariant),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: _text()));
              if (!context.mounted) return;
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(t.recapTextCopied)));
            },
            icon: const Icon(Icons.copy_rounded, size: 18),
            label: Text(t.recapCopyText),
          ),
        ],
      ),
    );
  }
}

/// The 4:5 picture people share: the year, four figures and the brand.
class _ShareImage extends StatelessWidget {
  const _ShareImage({required this.data, required this.hide});

  final _RecapContext data;
  final bool hide;

  @override
  Widget build(BuildContext context) {
    final d = data;
    final r = d.recap;
    final t = d.t;
    final colors = Theme.of(context).colorScheme;
    final income = VaultColors.income(context);
    final change = r.spentChangePercent;
    final top = r.topCategories.firstOrNull;
    final spent = hide
        ? (change == null
              ? t.recapFirstYear
              : t.recapVsYear(
                  '${change > 0
                      ? '+'
                      : change < 0
                      ? '−'
                      : ''}${change.abs()}',
                  '${r.year - 1}',
                ))
        : d.round(r.spentMinor);
    final saved = hide
        ? (r.savedPercent == null ? '—' : t.recapOfIncome(r.savedPercent!))
        : d.round(r.netMinor < 0 ? 0 : r.netMinor);
    Widget cell(String label, String value, {Color? color}) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant),
        ),
        const SizedBox(height: 2),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: color ?? colors.onSurface,
            ),
          ),
        ),
      ],
    );
    // A fixed picture: it must not grow with the system text size.
    return MediaQuery.withNoTextScaling(
      child: AspectRatio(
        aspectRatio: 4 / 5,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: colors.outlineVariant, width: .7),
            gradient: RadialGradient(
              center: const Alignment(-.8, -.9),
              radius: 1.2,
              colors: [
                income.withValues(alpha: .22),
                colors.primary.withValues(alpha: .04),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.recapMyYear,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.4,
                    color: colors.onSurfaceVariant,
                  ),
                ),
                Text(
                  '${r.year}',
                  style: const TextStyle(
                    fontSize: 52,
                    height: 1.05,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -2.4,
                  ),
                ),
                const Spacer(),
                VaultSurface(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(child: cell(t.recapSpentShort, spent)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: cell(t.recapSaved, saved, color: income),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: cell(
                              t.recapTopCategoryShort,
                              top == null
                                  ? '—'
                                  : '${d.categoryLabel(top.key)} · '
                                        '${r.percentOfSpent(top.value)}%',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: cell(t.transactions, '${r.movementCount}'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    VaultWalletMark(color: colors.onSurface),
                    const SizedBox(width: 8),
                    const Text(
                      'Pockets Vault',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

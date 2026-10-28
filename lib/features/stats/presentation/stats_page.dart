import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/currency/currency_metadata.dart';
import '../../../core/currency/currency_provider.dart';
import '../../../core/providers/balance_visibility_provider.dart';
import '../../../core/providers/time_filter_provider.dart';
import '../../../core/utils/category_localization.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/inline_load_error.dart';
import '../../forecast/presentation/cashflow_forecast_card.dart';
import '../../transactions/domain/category.dart';
import '../../transactions/domain/transaction.dart';
import '../../transactions/providers/category_provider.dart';
import '../../transactions/providers/transaction_provider.dart';
import '../domain/stats_analysis.dart';
import '../widgets/stats_period_controls.dart';
import '../widgets/stats_visuals.dart';

class StatsPage extends ConsumerStatefulWidget {
  const StatsPage({super.key});
  @override
  ConsumerState<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends ConsumerState<StatsPage>
    with WidgetsBindingObserver {
  int _tab = 0;
  bool _income = false;
  String? _categoryId;
  final _scrollController = ScrollController();
  late StatsComparisonSelection _comparison = StatsComparisonSelection.current(
    DateTime.now(),
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.dispose();
    super.dispose();
  }

  void _selectTab(int tab, {String? categoryId}) {
    setState(() {
      _tab = tab;
      if (categoryId != null) _categoryId = categoryId;
    });
    if (_scrollController.hasClients) _scrollController.jumpTo(0);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final colors = theme.colorScheme.copyWith(
      primary: dark ? const Color(0xFF969DFF) : const Color(0xFF4654EE),
      onSurface: dark ? const Color(0xFFF5F7FC) : const Color(0xFF0A132C),
      onSurfaceVariant: dark
          ? const Color(0xFFA2B0C9)
          : const Color(0xFF74809A),
      surfaceContainerHighest: dark
          ? const Color(0xFF2C3848)
          : const Color(0xFFEAEFF5),
    );
    return Theme(
      data: theme.copyWith(
        colorScheme: colors,
        textTheme: theme.textTheme
            .apply(bodyColor: colors.onSurface, displayColor: colors.onSurface)
            .copyWith(
              bodyMedium: theme.textTheme.bodyMedium?.copyWith(
                height: 1.2,
                color: colors.onSurface,
              ),
            ),
        scaffoldBackgroundColor: dark
            ? const Color(0xFF0E1722)
            : const Color(0xFFF5F7FC),
      ),
      child: Builder(builder: _buildContent),
    );
  }

  Widget _buildContent(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final time = ref.watch(timeFilterProvider);
    final txState = ref.watch(transactionProvider);
    final categoriesState = ref.watch(categoryProvider);
    final visible = ref.watch(balanceVisibilityProvider);
    final currency = ref.watch(currencyProvider).value?.baseCurrency ?? 'EUR';
    final locale = Localizations.localeOf(context).toString();
    final items = txState.value ?? const <TransactionModel>[];
    final categories = categoriesState.value ?? const <Category>[];
    String money(int minor) =>
        visible ? formatMoney(minor, currency, locale) : '••••';
    String compact(int minor) =>
        visible ? statsCompactMoney(minor, currency, locale) : '••••';
    String signed(int value) => visible
        ? '${value > 0
              ? '+'
              : value < 0
              ? '−'
              : ''}${formatMoney(value.abs(), currency, locale)}'
        : '••••';
    String name(String id) => categoryName(
      categories.where((c) => c.id == id).firstOrNull?.name ?? t.otherCategory,
      t,
    );
    final window = selectedTimeWindow(time);
    final summary = summarizeStats(items, window);
    var chartWindow = window;
    final today = startOfDay(DateTime.now());
    if (window != null &&
        time.filter == TimeFilter.month &&
        time.month.year == today.year &&
        time.month.month == today.month) {
      final lastRecorded = summary.transactions.isEmpty
          ? today
          : summary.transactions.last.date;
      chartWindow = TimeWindow(
        start: window.start,
        end: endOfDay(lastRecorded.isAfter(today) ? lastRecorded : today),
      );
    }
    final referenceWindow = previousStatsWindow(time, chartWindow);
    final reference = referenceWindow == null
        ? null
        : summarizeStats(items, referenceWindow);
    final series = cumulativeStatsSeries(
      summary,
      chartWindow,
      isIncome: _income,
    );
    final referenceSeries = reference == null
        ? null
        : alignedStatsReference(
            series,
            chartWindow!,
            reference,
            referenceWindow!,
            isIncome: _income,
          );
    final selectionLabel = statsPeriodLabel(time, locale, t);
    final currentShort = time.filter == TimeFilter.month
        ? DateFormat.MMMM(locale).format(time.month)
        : selectionLabel;
    final referenceShort =
        time.filter == TimeFilter.month && referenceWindow != null
        ? DateFormat.MMMM(locale).format(referenceWindow.start)
        : t.statsPreviousPeriod;
    final title = switch (time.filter) {
      TimeFilter.month =>
        _income ? t.statsMonthlyIncome : t.statsMonthlyExpenses,
      TimeFilter.period =>
        _income ? t.statsPeriodIncome : t.statsPeriodExpenses,
      TimeFilter.total => _income ? t.statsTotalIncome : t.statsTotalExpenses,
    };
    final entries = summary.categories(_income).entries.toList()
      ..sort((a, b) {
        final order = b.value.compareTo(a.value);
        return order != 0 ? order : a.key.compareTo(b.key);
      });
    final categoryScale = [
      ...summary.categories(_income).values,
      ...?reference?.categories(_income).values,
    ].fold<int>(1, (largest, value) => math.max(largest, value));
    final tabs = [t.statsOverview, t.statsCategories, t.statsComparisons];
    final loading = txState.isLoading || categoriesState.isLoading;
    final failed = txState.hasError || categoriesState.hasError;
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          key: const PageStorageKey('stats-scroll'),
          controller: _scrollController,
          padding: const EdgeInsets.fromLTRB(16, 2, 16, 24),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Tooltip(
                message: visible ? t.hideAmounts : t.showAmounts,
                child: InkWell(
                  key: const ValueKey('stats-privacy'),
                  borderRadius: BorderRadius.circular(12),
                  onTap: () =>
                      ref.read(balanceVisibilityProvider.notifier).toggle(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (visible)
                          StatsWalletMark(color: colors.onSurface)
                        else
                          Icon(
                            Icons.visibility_off_outlined,
                            size: 25,
                            color: colors.onSurface,
                          ),
                        const SizedBox(width: 11),
                        Flexible(
                          child: Text(
                            'Pockets Vault',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -.4,
                              color: colors.onSurface,
                              height: 1.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 2),
            LayoutBuilder(
              builder: (_, constraints) {
                final large =
                    constraints.maxWidth < 340 ||
                    MediaQuery.textScalerOf(context).scale(1) > 1.15;
                final heading = Text(
                  t.stats,
                  style: TextStyle(
                    fontSize: 34,
                    height: 1.1,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1.4,
                    color: colors.onSurface,
                  ),
                );
                final selector = ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: large ? constraints.maxWidth : 156,
                  ),
                  child: StatsGlobalPeriodButton(transactions: items),
                );
                if (_tab == 2) return heading;
                if (large) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      heading,
                      Align(alignment: Alignment.centerRight, child: selector),
                    ],
                  );
                }
                return Row(
                  children: [
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: heading,
                      ),
                    ),
                    const SizedBox(width: 8),
                    selector,
                  ],
                );
              },
            ),
            const SizedBox(height: 5),
            DecoratedBox(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: colors.outlineVariant, width: .7),
                ),
              ),
              child: Row(
                children: [
                  for (var i = 0; i < tabs.length; i++)
                    Expanded(
                      child: Semantics(
                        selected: _tab == i,
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: _tab == i
                                    ? colors.primary
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                          ),
                          child: TextButton(
                            key: ValueKey('stats-tab-$i'),
                            onPressed: () => _selectTab(i),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                vertical: 11,
                                horizontal: 2,
                              ),
                              minimumSize: const Size(0, 40),
                              foregroundColor: _tab == i
                                  ? colors.primary
                                  : colors.onSurfaceVariant,
                              shape: const RoundedRectangleBorder(),
                            ),
                            child: Text(
                              tabs[i],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: _tab == i
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            if (loading)
              const Padding(
                padding: EdgeInsets.all(36),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (failed)
              InlineLoadError(
                onRetry: () {
                  ref.invalidate(transactionProvider);
                  ref.invalidate(categoryProvider);
                },
              )
            else if (_tab == 2)
              ..._comparisonContent(
                context,
                compareStats(
                  items,
                  _comparison,
                  isIncome: _income,
                  now: DateTime.now(),
                ),
                items,
                categories,
                visible: visible,
                money: money,
                compact: compact,
                signed: signed,
                name: name,
                currency: currency,
              )
            else ...[
              if (_tab == 0) ...[
                StatsSurface(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _flowMenu(
                        context,
                        title,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      StatsAmount(
                        money(summary.amount(_income)),
                        key: const ValueKey('stats-selected-total'),
                        size: 36,
                      ),
                      if (reference != null) ...[
                        const SizedBox(height: 5),
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 7,
                          runSpacing: 4,
                          children: [
                            if (reference.amount(_income) != 0)
                              _percentageBadge(
                                context,
                                summary.amount(_income) -
                                    reference.amount(_income),
                                reference.amount(_income),
                                visible,
                              ),
                            _caption(
                              context,
                              t.statsVersus(referenceShort),
                              size: 12,
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        _caption(
                          context,
                          t.statsRangeCaption(
                            _rangeLabel(chartWindow!, locale),
                          ),
                          size: 11,
                        ),
                      ] else
                        _caption(context, selectionLabel, size: 11),
                      if (visible)
                        StatsTrendChart(
                          series: series,
                          reference: referenceSeries,
                          currency: currency,
                          currentLabel: toBeginningOfSentenceCase(currentShort),
                          referenceLabel: reference == null
                              ? null
                              : referenceShort,
                        )
                      else
                        const StatsHiddenChart(height: 177),
                    ],
                  ),
                ),
                const SizedBox(height: 9),
                LayoutBuilder(
                  builder: (_, constraints) {
                    final widgets = [
                      _metric(
                        context,
                        _income ? t.expenses : t.incomes,
                        money(_income ? summary.expense : summary.income),
                      ),
                      _metric(
                        context,
                        t.statsNet,
                        signed(summary.net),
                        color: visible && summary.net != 0
                            ? (summary.net > 0
                                  ? const Color(0xFF00885A)
                                  : colors.error)
                            : null,
                      ),
                    ];
                    return constraints.maxWidth < 310 &&
                            MediaQuery.textScalerOf(context).scale(1) > 1.2
                        ? Column(
                            children: [
                              widgets[0],
                              const SizedBox(height: 8),
                              widgets[1],
                            ],
                          )
                        : Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: widgets[0]),
                              const SizedBox(width: 9),
                              Expanded(child: widgets[1]),
                            ],
                          );
                  },
                ),
                const SizedBox(height: 9),
                _overviewInsight(
                  context,
                  summary,
                  reference,
                  name,
                  compact,
                  visible,
                ),
                const SizedBox(height: 9),
              ],
              StatsSurface(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_tab == 1)
                      _flowMenu(
                        context,
                        _income ? t.statsCategories : t.statsBreakdown,
                        style: _sectionStyle(context),
                      )
                    else
                      Text(
                        _income ? t.statsCategories : t.statsBreakdown,
                        style: _sectionStyle(context),
                      ),
                    if (_tab == 1) ...[
                      if (visible && entries.any((e) => e.value > 0))
                        _donut(
                          context,
                          entries,
                          summary.amount(_income),
                          money,
                          title,
                        )
                      else if (!visible)
                        const StatsHiddenChart(height: 190)
                      else
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 32),
                          child: Text(t.noTransactions),
                        ),
                    ],
                    if (entries.isEmpty && _tab == 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 14),
                        child: Text(t.noTransactions),
                      ),
                    for (var i = 0; i < entries.length; i++)
                      _categoryRow(
                        context,
                        entries[i],
                        i,
                        _tab == 0 ? categoryScale : summary.amount(_income),
                        categories,
                        name: name,
                        money: _tab == 0 ? compact : money,
                        visible: visible,
                        selectedId: _categoryId ?? entries.firstOrNull?.key,
                      ),
                  ],
                ),
              ),
              if (_tab == 1 && entries.isNotEmpty) ...[
                const SizedBox(height: 10),
                _categoryDetail(
                  context,
                  entries,
                  summary,
                  reference,
                  chartWindow,
                  referenceWindow,
                  referenceShort,
                  currentShort,
                  money,
                  compact,
                  signed,
                  name,
                  visible,
                ),
              ],
              const SizedBox(height: 10),
              TextButton.icon(
                key: const ValueKey('stats-forecast'),
                onPressed: () => showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  showDragHandle: true,
                  useSafeArea: true,
                  builder: (_) => SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.statsForecastToday,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(t.forecastExplanation),
                        const SizedBox(height: 16),
                        const CashflowForecastCard(),
                      ],
                    ),
                  ),
                ),
                icon: const Icon(Icons.auto_graph_rounded, size: 16),
                label: Text(
                  t.statsForecastToday,
                  style: const TextStyle(fontSize: 11),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  TextStyle _sectionStyle(BuildContext context) => TextStyle(
    fontSize: 19,
    height: 1.15,
    fontWeight: FontWeight.w700,
    letterSpacing: -.5,
    color: Theme.of(context).colorScheme.onSurface,
  );
  Widget _caption(BuildContext context, String text, {double size = 12}) =>
      Text(
        text,
        style: TextStyle(
          fontSize: size,
          height: 1.2,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      );
  Widget _metric(
    BuildContext context,
    String label,
    String value, {
    Color? color,
  }) => StatsSurface(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _caption(context, label, size: 13),
        const SizedBox(height: 3),
        StatsAmount(value, size: 23, color: color),
      ],
    ),
  );
  Color _seriesColor(int index) => [
    const Color(0xFF858CFA),
    const Color(0xFF529FFC),
    const Color(0xFF61748B),
    const Color(0xFFB1A8FF),
  ][index % 4];
  String _rangeLabel(TimeWindow window, String locale) =>
      window.start.year == window.end.year &&
          window.start.month == window.end.month
      ? '${window.start.day}–${DateFormat('d MMM', locale).format(window.end)}'
      : '${DateFormat.yMMMd(locale).format(window.start)} – ${DateFormat.yMMMd(locale).format(window.end)}';

  Widget _flowMenu(BuildContext context, String label, {TextStyle? style}) {
    final t = AppLocalizations.of(context)!;
    return PopupMenuButton<bool>(
      key: const ValueKey('stats-flow-menu'),
      tooltip: '${t.incomes} / ${t.expenses}',
      initialValue: _income,
      onSelected: (income) => setState(() {
        _income = income;
        _categoryId = null;
      }),
      itemBuilder: (_) => [
        for (final income in [false, true])
          PopupMenuItem(
            key: ValueKey('stats-flow-$income'),
            value: income,
            child: Text(income ? t.incomes : t.expenses),
          ),
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 1),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(child: Text(label, style: style)),
            const SizedBox(width: 3),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 14,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  Widget _percentageBadge(
    BuildContext context,
    int delta,
    int reference,
    bool visible, {
    Key? key,
  }) {
    final locale = Localizations.localeOf(context).toString();
    final percent = delta / reference.abs() * 100;
    return StatsDeltaBadge(
      key: key,
      label: visible
          ? '${delta > 0
                ? '+'
                : delta < 0
                ? '−'
                : ''}${NumberFormat.decimalPatternDigits(locale: locale, decimalDigits: 1).format(percent.abs())}%'
          : '••••',
      good: _income ? delta >= 0 : delta <= 0,
      down: delta < 0,
    );
  }

  Widget _insight(
    BuildContext context,
    String title,
    String subtitle,
    VoidCallback onTap, {
    Key? key,
  }) {
    final colors = Theme.of(context).colorScheme;
    return StatsSurface(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      child: InkWell(
        key: key,
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Row(
          children: [
            Container(
              width: 39,
              height: 39,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.primary.withValues(alpha: .08),
              ),
              child: Icon(
                Icons.auto_awesome_outlined,
                color: colors.primary,
                size: 21,
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  _caption(context, subtitle, size: 11),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: colors.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  List<StatsCategoryChange> _changes(
    StatsSummary summary,
    StatsSummary reference,
  ) {
    final current = summary.categories(_income);
    final previous = reference.categories(_income);
    return {...current.keys, ...previous.keys}
        .map(
          (id) => StatsCategoryChange(id, current[id] ?? 0, previous[id] ?? 0),
        )
        .toList()
      ..sort((a, b) {
        final order = b.delta.abs().compareTo(a.delta.abs());
        return order != 0 ? order : a.categoryId.compareTo(b.categoryId);
      });
  }

  Widget _overviewInsight(
    BuildContext context,
    StatsSummary summary,
    StatsSummary? reference,
    String Function(String) name,
    String Function(int) compact,
    bool visible,
  ) {
    final t = AppLocalizations.of(context)!;
    final changes = reference == null
        ? <StatsCategoryChange>[]
        : _changes(summary, reference);
    final delta = summary.amount(_income) - (reference?.amount(_income) ?? 0);
    final lead = changes.firstOrNull;
    final title = reference == null || !visible || delta == 0
        ? t.statsWhatChanged
        : _income
        ? (delta < 0
              ? t.statsIncomeLess(compact(delta.abs()))
              : t.statsIncomeMore(compact(delta.abs())))
        : (delta < 0
              ? t.statsSpentLess(compact(delta.abs()))
              : t.statsSpentMore(compact(delta.abs())));
    return _insight(
      context,
      title,
      lead == null || !visible
          ? t.statsCompareHint
          : t.statsMainVariation(name(lead.categoryId)),
      () => lead != null && visible
          ? _selectTab(1, categoryId: lead.categoryId)
          : _selectTab(2),
      key: const ValueKey('stats-overview-insight'),
    );
  }

  Widget _donut(
    BuildContext context,
    List<MapEntry<String, int>> entries,
    int total,
    String Function(int) money,
    String title,
  ) {
    final positive = entries.where((e) => e.value > 0).toList();
    return SizedBox(
      height: 171,
      child: LayoutBuilder(
        builder: (_, constraints) {
          final radius = math.min(65.0, constraints.maxWidth * .23);
          return Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                key: const ValueKey('stats-category-donut'),
                PieChartData(
                  centerSpaceRadius: radius,
                  startDegreeOffset: 270,
                  sectionsSpace: 3,
                  pieTouchData: PieTouchData(
                    touchCallback: (event, response) {
                      if (event is! FlTapUpEvent) return;
                      final index =
                          response?.touchedSection?.touchedSectionIndex ?? -1;
                      if (index >= 0 && index < positive.length) {
                        setState(() => _categoryId = positive[index].key);
                      }
                    },
                  ),
                  sections: [
                    for (var i = 0; i < positive.length; i++)
                      PieChartSectionData(
                        value: positive[i].value.toDouble(),
                        title: '',
                        color: _seriesColor(entries.indexOf(positive[i])),
                        radius: 19,
                      ),
                  ],
                ),
                duration: statsAnimationDuration(context),
                curve: Curves.easeOutCubic,
              ),
              SizedBox(
                width: radius * 1.72,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    StatsAmount(money(total), size: 23),
                    const SizedBox(height: 2),
                    _caption(context, title, size: 11),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _categoryIcon(
    BuildContext context,
    String id,
    List<Category> categories, {
    double size = 32,
  }) {
    final category = categories.where((c) => c.id == id).firstOrNull;
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colors.primary.withValues(alpha: .065),
      ),
      child: Icon(
        category == null
            ? Icons.category_outlined
            : category.isDefault
            ? switch (category.name) {
                'shopping' => Icons.shopping_bag_outlined,
                'food' => Icons.restaurant_outlined,
                'groceries' => Icons.shopping_cart_outlined,
                'transport' => Icons.directions_bus_outlined,
                _ => categoryIcon(category.name),
              }
            : customCategoryIcon(category.icon),
        size: 20,
        color: colors.primary,
      ),
    );
  }

  Widget _categoryRow(
    BuildContext context,
    MapEntry<String, int> entry,
    int index,
    int total,
    List<Category> categories, {
    required String Function(String) name,
    required String Function(int) money,
    required bool visible,
    required String? selectedId,
  }) {
    final colors = Theme.of(context).colorScheme;
    final active = _tab == 1 && selectedId == entry.key;
    final color = _seriesColor(index);
    final locale = Localizations.localeOf(context).toString();
    final percent = total == 0 ? 0.0 : entry.value / total;
    return Material(
      color: active
          ? colors.primary.withValues(alpha: .08)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        key: ValueKey('stats-category-${entry.key}'),
        borderRadius: BorderRadius.circular(8),
        onTap: () => _selectTab(1, categoryId: entry.key),
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: _tab == 1 ? 9 : 5,
            horizontal: _tab == 1 ? 7 : 0,
          ),
          decoration: BoxDecoration(
            borderRadius: active ? BorderRadius.circular(8) : null,
            border: active
                ? Border.all(
                    color: colors.primary.withValues(alpha: .23),
                    width: .7,
                  )
                : index > 0
                ? Border(
                    top: BorderSide(color: colors.outlineVariant, width: .5),
                  )
                : null,
          ),
          child: _tab == 1
              ? LayoutBuilder(
                  builder: (_, constraints) => Row(
                    children: [
                      Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: color,
                        ),
                      ),
                      const SizedBox(width: 11),
                      Expanded(
                        flex: 4,
                        child: Text(
                          name(entry.key),
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.2,
                            fontWeight: active
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        flex: 4,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: StatsAmount(money(entry.value), size: 14),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 3,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            visible
                                ? NumberFormat.decimalPercentPattern(
                                    locale: locale,
                                    decimalDigits: 1,
                                  ).format(percent)
                                : '••••',
                            style: TextStyle(
                              fontSize: 12,
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 17,
                        color: colors.onSurfaceVariant,
                      ),
                    ],
                  ),
                )
              : Row(
                  children: [
                    _categoryIcon(context, entry.key, categories),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  name(entry.key),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              StatsAmount(money(entry.value), size: 12),
                            ],
                          ),
                          if (visible && total > 0)
                            Padding(
                              padding: const EdgeInsets.only(top: 5),
                              child: StatsProgress(
                                value: entry.value / total,
                                color: index == 0
                                    ? colors.primary
                                    : Color.lerp(
                                        colors.primary,
                                        Colors.white,
                                        .3 + math.min(index, 3) * .15,
                                      )!,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _categoryDetail(
    BuildContext context,
    List<MapEntry<String, int>> entries,
    StatsSummary summary,
    StatsSummary? reference,
    TimeWindow? window,
    TimeWindow? referenceWindow,
    String referenceLabel,
    String currentLabel,
    String Function(int) money,
    String Function(int) compact,
    String Function(int) signed,
    String Function(String) name,
    bool visible,
  ) {
    final t = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final selected =
        entries.where((e) => e.key == _categoryId).firstOrNull ?? entries.first;
    final previous = reference?.categories(_income)[selected.key] ?? 0;
    final delta = selected.value - previous;
    final transactions = summary.transactions
        .where((tx) => tx.isIncome == _income && tx.categoryId == selected.key)
        .toList();
    final color = _seriesColor(entries.indexOf(selected));
    final scale = math.max(1, math.max(previous.abs(), selected.value.abs()));
    return StatsSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(shape: BoxShape.circle, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(name(selected.key), style: _sectionStyle(context)),
              ),
            ],
          ),
          const SizedBox(height: 7),
          StatsAmount(money(selected.value), size: 30),
          const SizedBox(height: 6),
          if (reference != null) ...[
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 9,
              runSpacing: 4,
              children: [
                StatsDeltaBadge(
                  label: visible
                      ? '${delta > 0
                            ? '+'
                            : delta < 0
                            ? '−'
                            : ''}${compact(delta.abs())}'
                      : '••••',
                  neutral: true,
                  good: _income ? delta >= 0 : delta <= 0,
                  down: delta < 0,
                ),
                _caption(context, t.statsVersus(referenceLabel)),
              ],
            ),
            if (visible) ...[
              const SizedBox(height: 14),
              _detailBar(
                context,
                currentLabel,
                selected.value,
                scale,
                color,
                compact,
              ),
              const SizedBox(height: 8),
              _detailBar(
                context,
                referenceLabel,
                previous,
                scale,
                statsReferenceColor,
                compact,
              ),
            ],
            const SizedBox(height: 10),
            Divider(color: colors.outlineVariant, height: 1),
            const SizedBox(height: 8),
            _caption(
              context,
              '${t.period}: ${_rangeLabel(window!, Localizations.localeOf(context).toString())} / ${_rangeLabel(referenceWindow!, Localizations.localeOf(context).toString())}',
              size: 10,
            ),
          ] else
            _caption(context, t.statsTransactionCount(transactions.length)),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              key: const ValueKey('stats-category-transactions'),
              style: OutlinedButton.styleFrom(
                backgroundColor: colors.primary.withValues(alpha: .045),
                side: BorderSide(color: colors.outlineVariant),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 9,
                ),
                foregroundColor: colors.onSurface,
              ),
              onPressed: () =>
                  _showTransactions(context, transactions, name(selected.key)),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      t.statsShowTransactions,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailBar(
    BuildContext context,
    String label,
    int value,
    int scale,
    Color color,
    String Function(int) compact,
  ) => Row(
    children: [
      SizedBox(
        width: 78,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _caption(context, toBeginningOfSentenceCase(label), size: 11),
            Text(
              compact(value),
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
      Expanded(
        child: StatsProgress(
          value: value.abs() / scale,
          color: color,
          height: 12,
        ),
      ),
    ],
  );
  void _showTransactions(
    BuildContext context,
    List<TransactionModel> transactions,
    String title,
  ) {
    final ids = transactions.map((tx) => tx.id).toSet();
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (_) => Consumer(
        builder: (context, ref, _) {
          // Privacy is observed here as well: an open sheet must hide immediately.
          final visible = ref.watch(balanceVisibilityProvider);
          final currency =
              ref.watch(currencyProvider).value?.baseCurrency ?? 'EUR';
          final locale = Localizations.localeOf(context).toString();
          final liveTransactions =
              (ref.watch(transactionProvider).value ?? transactions)
                  .where((tx) => ids.contains(tx.id))
                  .toList();
          final colors = Theme.of(context).colorScheme;
          return ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * .8,
            ),
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              children: [
                Text(title, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                for (final tx in liveTransactions.reversed)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat.yMMMd(locale).format(tx.date),
                          style: TextStyle(
                            fontSize: 12,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                        if (tx.note != null) Text(tx.note!),
                        const SizedBox(height: 4),
                        StatsAmount(
                          visible
                              ? '${tx.isIncome ? '+' : '−'}${formatMoney(tx.amountCents, currency, locale)}'
                              : '••••',
                          size: 18,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Widget> _comparisonContent(
    BuildContext context,
    StatsComparison data,
    List<TransactionModel> items,
    List<Category> categories, {
    required bool visible,
    required String Function(int) money,
    required String Function(int) compact,
    required String Function(int) signed,
    required String Function(String) name,
    required String currency,
  }) {
    final t = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final locale = Localizations.localeOf(context).toString();
    final currentLabel = DateFormat.MMMM(locale).format(_comparison.month);
    final referenceLabel = _comparison.mode == StatsComparisonMode.yearAverage
        ? t.statsAverageLabel
        : DateFormat(
            data.referenceMonths.first.year == _comparison.month.year
                ? 'MMMM'
                : 'MMMM yyyy',
            locale,
          ).format(data.referenceMonths.first);
    final flowLabel = _comparison.mode == StatsComparisonMode.yearAverage
        ? '${_income ? t.incomes : t.expenses} · ${t.statsAverageLabel.toLowerCase()} ${_comparison.month.year}'
        : _income
        ? t.statsIncomeVersus(referenceLabel)
        : t.statsExpenseVersus(referenceLabel);
    String shortRange(TimeWindow range, {bool year = false}) =>
        '${range.start.day}–${DateFormat(year ? 'd MMM yy' : 'd MMM', locale).format(range.end)}';
    final localCurrent = shortRange(data.currentWindow);
    final localReference = _comparison.mode == StatsComparisonMode.yearAverage
        ? t.statsAverageLabel
        : data.referenceWindows.isEmpty
        ? '—'
        : shortRange(
            data.referenceWindows.first,
            year:
                data.referenceWindows.first.start.year !=
                data.currentWindow.start.year,
          );
    final scale = data.changes.fold<int>(
      1,
      (v, c) =>
          math.max(v, math.max(c.currentMinor.abs(), c.referenceMinor.abs())),
    );
    return [
      StatsSurface(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 4,
              children: [
                Text(t.statsWhatChanged, style: _sectionStyle(context)),
                OutlinedButton(
                  key: const ValueKey('stats-local-period'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colors.onSurfaceVariant,
                    backgroundColor: colors.primary.withValues(alpha: .025),
                    side: BorderSide(color: colors.outlineVariant, width: .7),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 7,
                    ),
                    minimumSize: const Size(0, 32),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: () async {
                    final value = await showStatsComparisonPicker(
                      context,
                      _comparison,
                      items,
                    );
                    if (value != null && mounted) {
                      setState(() => _comparison = value);
                    }
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          localCurrent,
                          style: const TextStyle(fontSize: 10),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 3),
                        child: Icon(Icons.swap_horiz_rounded, size: 13),
                      ),
                      Flexible(
                        child: Text(
                          localReference,
                          style: const TextStyle(fontSize: 10),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            StatsAmount(
              data.available ? signed(data.delta) : '—',
              key: const ValueKey('stats-comparison-delta'),
              size: 36,
            ),
            const SizedBox(height: 4),
            if (data.available && data.percentage != null)
              _percentageBadge(
                context,
                data.delta,
                data.referenceMinor,
                visible,
                key: const ValueKey('stats-comparison-percentage'),
              ),
            const SizedBox(height: 6),
            _flowMenu(
              context,
              flowLabel,
              style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
            ),
            if (!data.available)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(t.statsNoEarlierMonths),
              )
            else ...[
              if (visible && data.percentage == null)
                _caption(context, t.statsZeroReference, size: 11),
              if (visible)
                StatsComparisonBars(
                  current: data.currentMinor,
                  reference: data.referenceMinor,
                  currentLabel: toBeginningOfSentenceCase(currentLabel),
                  referenceLabel: toBeginningOfSentenceCase(referenceLabel),
                  currency: currency,
                )
              else
                const StatsHiddenChart(height: 180),
              if (_comparison.mode == StatsComparisonMode.yearAverage)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: _caption(
                    context,
                    t.statsAverageBasis(data.referenceMonths.length),
                    size: 11,
                  ),
                ),
            ],
          ],
        ),
      ),
      if (data.available) ...[
        const SizedBox(height: 10),
        StatsSurface(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 12,
                runSpacing: 5,
                children: [
                  Text(t.statsChangeDrivers, style: _sectionStyle(context)),
                  Wrap(
                    spacing: 12,
                    runSpacing: 4,
                    children: [
                      StatsLegend(
                        toBeginningOfSentenceCase(currentLabel),
                        color: colors.primary,
                      ),
                      StatsLegend(
                        toBeginningOfSentenceCase(referenceLabel),
                        color: statsReferenceColor,
                      ),
                    ],
                  ),
                ],
              ),
              if (data.changes.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(t.noTransactions),
                ),
              for (var i = 0; i < data.changes.length; i++) ...[
                if (i > 0) Divider(height: 1, color: colors.outlineVariant),
                _driverRow(
                  context,
                  data.changes[i],
                  scale,
                  categories,
                  name,
                  compact,
                  visible,
                  () => _showTransactions(
                    context,
                    data.current.transactions
                        .where(
                          (tx) =>
                              tx.isIncome == _income &&
                              tx.categoryId == data.changes[i].categoryId,
                        )
                        .toList(),
                    name(data.changes[i].categoryId),
                  ),
                ),
              ],
            ],
          ),
        ),
        if (data.changes.isNotEmpty) ...[
          const SizedBox(height: 10),
          _insight(
            context,
            data.delta == 0 || !visible
                ? t.statsCategoryChange
                : data.delta < 0
                ? t.statsExplainsDrop(name(data.changes.first.categoryId))
                : t.statsExplainsRise(name(data.changes.first.categoryId)),
            t.statsOpenCategoryHint,
            () => _showTransactions(
              context,
              data.current.transactions
                  .where(
                    (tx) =>
                        tx.isIncome == _income &&
                        tx.categoryId == data.changes.first.categoryId,
                  )
                  .toList(),
              name(data.changes.first.categoryId),
            ),
          ),
        ],
      ],
    ];
  }

  Widget _driverRow(
    BuildContext context,
    StatsCategoryChange change,
    int scale,
    List<Category> categories,
    String Function(String) name,
    String Function(int) compact,
    bool visible,
    VoidCallback onTap,
  ) {
    final colors = Theme.of(context).colorScheme;
    return InkWell(
      key: ValueKey('stats-change-${change.categoryId}'),
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            _categoryIcon(context, change.categoryId, categories, size: 35),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name(change.categoryId),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -.3,
                    ),
                  ),
                  const SizedBox(height: 3),
                  if (visible) ...[
                    _driverBar(
                      context,
                      change.currentMinor,
                      scale,
                      colors.primary,
                      compact,
                    ),
                    const SizedBox(height: 3),
                    _driverBar(
                      context,
                      change.referenceMinor,
                      scale,
                      statsReferenceColor,
                      compact,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 10),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 76),
              child: StatsDeltaBadge(
                label: visible
                    ? '${change.delta > 0
                          ? '+'
                          : change.delta < 0
                          ? '−'
                          : ''}${compact(change.delta.abs())}'
                    : '••••',
                good: _income ? change.delta >= 0 : change.delta <= 0,
                arrow: false,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _driverBar(
    BuildContext context,
    int value,
    int scale,
    Color color,
    String Function(int) compact,
  ) => LayoutBuilder(
    builder: (_, constraints) {
      final width =
          math.max(0.0, constraints.maxWidth - 48) *
          (value.abs() / scale).clamp(0, 1);
      return Row(
        children: [
          Container(
            width: width,
            height: 9,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 6),
          Flexible(child: StatsAmount(compact(value), size: 11)),
        ],
      );
    },
  );
}

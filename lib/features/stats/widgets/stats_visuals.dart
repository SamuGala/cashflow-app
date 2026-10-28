import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/currency/currency_metadata.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/stats_analysis.dart';

Duration statsAnimationDuration(BuildContext context) =>
    MediaQuery.disableAnimationsOf(context)
    ? Duration.zero
    : const Duration(milliseconds: 320);

const statsReferenceColor = Color(0xFF9BA7BA);

class StatsSurface extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  const StatsSurface({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: dark ? null : colors.surface,
        gradient: dark
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF182431), Color(0xFF15202C)],
              )
            : null,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: dark ? colors.outlineVariant : const Color(0xFFF0F2F8),
          width: .7,
        ),
      ),
      child: child,
    );
  }
}

class StatsAmount extends StatelessWidget {
  final String value;
  final double size;
  final Color? color;
  const StatsAmount(this.value, {super.key, this.size = 32, this.color});
  @override
  Widget build(BuildContext context) => FittedBox(
    fit: BoxFit.scaleDown,
    alignment: Alignment.centerLeft,
    child: Text(
      value,
      style: TextStyle(
        fontSize: size,
        height: 1.05,
        fontWeight: FontWeight.w700,
        letterSpacing: -.7,
        color: color,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    ),
  );
}

class StatsHiddenChart extends StatelessWidget {
  final double height;
  const StatsHiddenChart({super.key, this.height = 180});
  @override
  Widget build(BuildContext context) => SizedBox(
    height: height,
    child: Center(
      child: Semantics(
        label: AppLocalizations.of(context)!.statsHiddenChart,
        child: Icon(
          Icons.visibility_off_outlined,
          size: 32,
          color: Theme.of(
            context,
          ).colorScheme.onSurfaceVariant.withValues(alpha: .5),
        ),
      ),
    ),
  );
}

class StatsProgress extends StatelessWidget {
  final double value;
  final Color color;
  final double height;
  const StatsProgress({
    super.key,
    required this.value,
    required this.color,
    this.height = 8,
  });
  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(end: value.clamp(0, 1)),
    duration: statsAnimationDuration(context),
    curve: Curves.easeOutCubic,
    builder: (_, value, _) => SizedBox(
      height: height,
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(height),
              ),
            ),
          ),
          Positioned.fill(
            child: Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: value,
                heightFactor: 1,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(height),
                    gradient: LinearGradient(
                      colors: [Color.lerp(color, Colors.white, .12)!, color],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class StatsDeltaBadge extends StatelessWidget {
  final String label;
  final bool good;
  final bool down;
  final bool arrow;
  final bool neutral;
  const StatsDeltaBadge({
    super.key,
    required this.label,
    required this.good,
    this.down = false,
    this.arrow = true,
    this.neutral = false,
  });
  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final color = neutral
        ? Theme.of(context).colorScheme.primary
        : good
        ? (dark ? const Color(0xFF8DDABD) : const Color(0xFF00855B))
        : (dark ? const Color(0xFFFF9DAF) : const Color(0xFFD42A4E));
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: dark ? .12 : .09),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (arrow) ...[
            Icon(
              down ? Icons.south_rounded : Icons.north_rounded,
              size: 16,
              color: color,
            ),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                maxLines: 1,
                style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class StatsLegend extends StatelessWidget {
  final String label;
  final Color color;
  final bool dashed;
  const StatsLegend(
    this.label, {
    super.key,
    required this.color,
    this.dashed = false,
  });
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      if (dashed)
        Row(
          children: List.generate(
            4,
            (_) => Padding(
              padding: const EdgeInsets.only(right: 2),
              child: SizedBox(
                width: 4,
                height: 1,
                child: ColoredBox(color: color),
              ),
            ),
          ),
        )
      else
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
      const SizedBox(width: 6),
      Flexible(
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    ],
  );
}

double _niceInterval(double range) {
  final rough = math.max(1.0, range / 2);
  final magnitude = math
      .pow(10, (math.log(rough) / math.ln10).floor())
      .toDouble();
  return [
    1.0,
    1.5,
    2.0,
    2.5,
    3.0,
    4.0,
    5.0,
    6.0,
    8.0,
    10.0,
  ].map((step) => step * magnitude).firstWhere((step) => step >= rough);
}

String statsAxisMoney(int minor, String currency, String locale) {
  final major = minorToMajor(minor, currency);
  if (major.abs() > 0 && major.abs() < 1) {
    return formatMoney(minor, currency, locale);
  }
  final number = major.abs() >= 10000
      ? NumberFormat.compact(locale: locale).format(major)
      : NumberFormat.decimalPatternDigits(
          locale: locale,
          decimalDigits: 0,
        ).format(major);
  return '$number ${NumberFormat.simpleCurrency(locale: locale, name: currency).currencySymbol}';
}

String statsCompactMoney(int minor, String currency, String locale) {
  final scale = currencyScale(currency);
  return NumberFormat.simpleCurrency(
    locale: locale,
    name: currency,
    decimalDigits: minor % scale == 0 ? 0 : currencyDecimalDigits(currency),
  ).format(minorToMajor(minor, currency));
}

class StatsWalletMark extends StatelessWidget {
  final Color color;
  const StatsWalletMark({super.key, required this.color});
  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: const Size(25, 25), painter: _WalletPainter(color));
}

class _WalletPainter extends CustomPainter {
  final Color color;
  const _WalletPainter(this.color);
  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 32, size.height / 32);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.9
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(
      Path()
        ..moveTo(4, 9)
        ..lineTo(23, 3)
        ..quadraticBezierTo(25, 2.4, 25.5, 5)
        ..lineTo(27, 9),
      paint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTRB(3, 9, 29, 29),
        const Radius.circular(3),
      ),
      paint,
    );
    canvas.drawCircle(const Offset(24, 19), 1.4, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_WalletPainter oldDelegate) => oldDelegate.color != color;
}

class StatsTrendChart extends StatefulWidget {
  final StatsSeries series;
  final StatsSeries? reference;
  final String currency;
  final String currentLabel;
  final String? referenceLabel;
  const StatsTrendChart({
    super.key,
    required this.series,
    required this.currency,
    this.reference,
    required this.currentLabel,
    this.referenceLabel,
  });
  @override
  State<StatsTrendChart> createState() => _StatsTrendChartState();
}

class _StatsTrendChartState extends State<StatsTrendChart> {
  int? selected;
  @override
  void didUpdateWidget(covariant StatsTrendChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.series != widget.series ||
        oldWidget.currency != widget.currency) {
      selected = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final t = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final points = widget.series.points;
    final reference = widget.reference?.points ?? const <StatsPoint>[];
    if (points.isEmpty) {
      return SizedBox(
        height: 150,
        child: Center(child: Text(t.noTransactions)),
      );
    }
    final values = [...points, ...reference].map((p) => p.amountMinor).toList();
    final maxValue = math.max(0, values.reduce(math.max)).toDouble();
    final minValue = math.min(0, values.reduce(math.min)).toDouble();
    final interval = _niceInterval(maxValue - minValue);
    final maxY = math.max(interval, (maxValue / interval).ceil() * interval);
    final minY = (minValue / interval).floor() * interval;
    final last = points.length - 1;
    final tickIndices = {
      0,
      for (var i = 1; i <= 4; i++)
        math.max(0, ((last + 1) * i / 4).round() - 1),
    };
    final selectedPoint = selected == null
        ? null
        : points[selected!.clamp(0, last)];
    String dateLabel(DateTime date) => switch (widget.series.bucketSize) {
      StatsBucketSize.day => DateFormat.MMMd(locale).format(date),
      StatsBucketSize.month => DateFormat.yMMM(locale).format(date),
      StatsBucketSize.year => DateFormat.y(locale).format(date),
    };
    final axisStyle = TextStyle(fontSize: 10, color: colors.onSurfaceVariant);
    final chartHeight = 125.0;
    final plotHeight = chartHeight - 26;
    double endpointY(int amount) =>
        ((maxY - amount) / (maxY - minY) * plotHeight).clamp(0, plotHeight);
    var currentY = endpointY(points.last.amountMinor);
    var referenceY = reference.isEmpty
        ? 0.0
        : endpointY(reference.last.amountMinor);
    if (reference.isNotEmpty && (currentY - referenceY).abs() < 16) {
      if (points.last.amountMinor <= reference.last.amountMinor) {
        currentY += 7;
        referenceY -= 7;
      } else {
        currentY -= 7;
        referenceY += 7;
      }
    }
    return Column(
      children: [
        const SizedBox(height: 6),
        SizedBox(
          height: chartHeight + 6,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                top: 4,
                left: 0,
                right: 37,
                bottom: 2,
                child: Semantics(
                  label: '${t.statsTrend}. ${t.statsDragHint}',
                  child: LineChart(
                    key: const ValueKey('stats-trend-chart'),
                    LineChartData(
                      minX: 0,
                      maxX: math.max(1, last).toDouble(),
                      minY: minY,
                      maxY: maxY,
                      borderData: FlBorderData(show: false),
                      gridData: FlGridData(
                        horizontalInterval: interval,
                        verticalInterval: math.max(1, last / 4).toDouble(),
                        getDrawingHorizontalLine: (_) => FlLine(
                          color: colors.outlineVariant,
                          strokeWidth: .6,
                        ),
                        getDrawingVerticalLine: (_) => FlLine(
                          color: colors.outlineVariant,
                          strokeWidth: .6,
                          dashArray: [3, 3],
                        ),
                      ),
                      titlesData: FlTitlesData(
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 44,
                            interval: interval,
                            getTitlesWidget: (v, _) => Text(
                              statsAxisMoney(
                                v.round(),
                                widget.currency,
                                locale,
                              ),
                              style: axisStyle,
                            ),
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 26,
                            interval: 1,
                            getTitlesWidget: (v, meta) {
                              final i = v.round();
                              if (!tickIndices.contains(i) ||
                                  (v - i).abs() > .01) {
                                return const SizedBox.shrink();
                              }
                              return SideTitleWidget(
                                meta: meta,
                                space: 7,
                                child: Text(switch (widget.series.bucketSize) {
                                  StatsBucketSize.day => DateFormat.d(
                                    locale,
                                  ).format(points[i].date),
                                  StatsBucketSize.month => DateFormat(
                                    'MM/yy',
                                    locale,
                                  ).format(points[i].date),
                                  StatsBucketSize.year =>
                                    '${points[i].date.year}',
                                }, style: axisStyle),
                              );
                            },
                          ),
                        ),
                      ),
                      lineTouchData: LineTouchData(
                        handleBuiltInTouches: false,
                        touchSpotThreshold: 40,
                        touchCallback: (event, response) {
                          final spots = response?.lineBarSpots;
                          if (spots == null || spots.isEmpty) return;
                          final index = spots.first.spotIndex;
                          if (index != selected) {
                            setState(() => selected = index);
                          }
                        },
                      ),
                      extraLinesData: selected == null
                          ? null
                          : ExtraLinesData(
                              verticalLines: [
                                VerticalLine(
                                  x: selected!.toDouble(),
                                  color: colors.primary.withValues(alpha: .35),
                                  strokeWidth: 1,
                                  dashArray: [3, 3],
                                ),
                              ],
                            ),
                      lineBarsData: [
                        if (reference.isNotEmpty)
                          LineChartBarData(
                            spots: [
                              for (var i = 0; i < reference.length; i++)
                                FlSpot(
                                  i.toDouble(),
                                  reference[i].amountMinor.toDouble(),
                                ),
                            ],
                            color: statsReferenceColor,
                            barWidth: 1.2,
                            dashArray: [4, 4],
                            dotData: FlDotData(
                              show: true,
                              checkToShowDot: (spot, _) =>
                                  spot.x == last.toDouble(),
                              getDotPainter: (_, _, _, _) => FlDotCirclePainter(
                                radius: 3,
                                color: statsReferenceColor,
                                strokeWidth: 0,
                              ),
                            ),
                          ),
                        LineChartBarData(
                          spots: [
                            for (var i = 0; i < points.length; i++)
                              FlSpot(
                                i.toDouble(),
                                points[i].amountMinor.toDouble(),
                              ),
                          ],
                          color: colors.primary,
                          barWidth: 1.8,
                          dotData: FlDotData(
                            show: true,
                            checkToShowDot: (spot, _) =>
                                spot.x == selected?.toDouble() ||
                                spot.x == last.toDouble(),
                            getDotPainter: (_, _, _, _) => FlDotCirclePainter(
                              radius: 3,
                              color: colors.primary,
                              strokeWidth: 0,
                            ),
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                colors.primary.withValues(alpha: .2),
                                colors.primary.withValues(alpha: .035),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    duration: statsAnimationDuration(context),
                    curve: Curves.easeOutCubic,
                  ),
                ),
              ),
              Positioned(
                right: 0,
                top: currentY.clamp(0, plotHeight),
                child: Text(
                  statsCompactMoney(
                    points.last.amountMinor,
                    widget.currency,
                    locale,
                  ),
                  style: TextStyle(
                    color: colors.primary,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (reference.isNotEmpty)
                Positioned(
                  right: 0,
                  top: referenceY.clamp(0, plotHeight),
                  child: Text(
                    statsCompactMoney(
                      reference.last.amountMinor,
                      widget.currency,
                      locale,
                    ),
                    style: TextStyle(
                      color: colors.onSurfaceVariant,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              Positioned(
                top: 0,
                left: 45,
                right: 38,
                child: IgnorePointer(
                  child: Opacity(
                    opacity: selectedPoint == null ? 0 : 1,
                    child: Container(
                      color: colors.surface,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 2,
                      ),
                      child: Semantics(
                        liveRegion: true,
                        child: Text(
                          selectedPoint == null
                              ? t.statsDragHint
                              : '${dateLabel(selectedPoint.date)} · ${formatMoney(selectedPoint.amountMinor, widget.currency, locale)}',
                          key: const ValueKey('stats-chart-readout'),
                          style: TextStyle(fontSize: 11, color: colors.primary),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 22,
          runSpacing: 5,
          children: [
            StatsLegend(widget.currentLabel, color: colors.primary),
            if (widget.referenceLabel != null)
              StatsLegend(
                widget.referenceLabel!,
                color: statsReferenceColor,
                dashed: true,
              ),
          ],
        ),
      ],
    );
  }
}

class StatsComparisonBars extends StatelessWidget {
  final int current;
  final int reference;
  final String currentLabel;
  final String referenceLabel;
  final String currency;
  const StatsComparisonBars({
    super.key,
    required this.current,
    required this.reference,
    required this.currentLabel,
    required this.referenceLabel,
    required this.currency,
  });
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final locale = Localizations.localeOf(context).toString();
    final low = math.min(0, math.min(current, reference));
    final high = math.max(0, math.max(current, reference));
    final interval = _niceInterval((high - low).toDouble());
    final maxY = math.max(interval, (high / interval).ceil() * interval);
    final minY = (low / interval).floor() * interval;
    final axisStyle = TextStyle(fontSize: 11, color: colors.onSurfaceVariant);
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: SizedBox(
        height: 140,
        child: LayoutBuilder(
          builder: (_, constraints) => BarChart(
            BarChartData(
              minY: minY,
              maxY: maxY,
              alignment: BarChartAlignment.spaceAround,
              borderData: FlBorderData(
                show: true,
                border: Border(
                  bottom: BorderSide(color: colors.outlineVariant),
                  left: BorderSide(color: colors.outlineVariant),
                ),
              ),
              gridData: FlGridData(
                drawVerticalLine: false,
                horizontalInterval: interval,
                getDrawingHorizontalLine: (_) => FlLine(
                  color: colors.outlineVariant,
                  strokeWidth: .8,
                  dashArray: [3, 3],
                ),
              ),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 48,
                    interval: interval,
                    getTitlesWidget: (v, _) => Text(
                      statsAxisMoney(v.round(), currency, locale),
                      style: axisStyle,
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    getTitlesWidget: (v, meta) => SideTitleWidget(
                      meta: meta,
                      space: 7,
                      child: Text(
                        v.round() == 0 ? referenceLabel : currentLabel,
                        style: axisStyle,
                      ),
                    ),
                  ),
                ),
              ),
              barTouchData: BarTouchData(
                enabled: false,
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (_) => Colors.transparent,
                  tooltipPadding: EdgeInsets.zero,
                  tooltipMargin: 4,
                  getTooltipItem: (group, _, rod, _) => BarTooltipItem(
                    statsCompactMoney(rod.toY.round(), currency, locale),
                    TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: colors.onSurface,
                    ),
                  ),
                ),
              ),
              barGroups: [
                for (var i = 0; i < 2; i++)
                  BarChartGroupData(
                    x: i,
                    showingTooltipIndicators: [0],
                    barRods: [
                      BarChartRodData(
                        toY: (i == 0 ? reference : current).toDouble(),
                        width: math.min(66, constraints.maxWidth * .22),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                        color: i == 0 ? statsReferenceColor : colors.primary,
                      ),
                    ],
                  ),
              ],
            ),
            duration: statsAnimationDuration(context),
            curve: Curves.easeOutCubic,
          ),
        ),
      ),
    );
  }
}

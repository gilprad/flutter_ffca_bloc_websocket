import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../shared/app_constant.dart';
import '../../domain/entities/crypto_price_point.dart';

class ScrollablePriceChart extends StatefulWidget {
  const ScrollablePriceChart({
    super.key,
    required this.points,
    this.pointSpacing = 10,
    this.scrollController,
  });

  final List<CryptoPricePoint> points;

  final double pointSpacing;
  final ScrollController? scrollController;

  @override
  State<ScrollablePriceChart> createState() => _ScrollablePriceChartState();
}

class _ScrollablePriceChartState extends State<ScrollablePriceChart> {
  ScrollController? _internalController;

  ScrollController get _controller =>
      widget.scrollController ?? (_internalController ??= ScrollController());

  @override
  void didUpdateWidget(covariant ScrollablePriceChart oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.scrollController == null && widget.scrollController != null) {
      _internalController?.dispose();
      _internalController = null;
    }
  }

  @override
  void dispose() {
    _internalController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.points.isEmpty) {
      return Center(
        child: Text('Menunggu data...', style: AppConstant.labelLarge(context)),
      );
    }

    final ySpec = _calcYSpec(widget.points);

    final screenWidth = MediaQuery.of(context).size.width;
    final minX = _epochSec(widget.points.first.timeSec).toDouble();
    final maxX = _epochSec(widget.points.last.timeSec).toDouble();
    final spanSec = (maxX - minX).clamp(0, double.infinity);
    final chartWidth = math.max(
      screenWidth,
      (spanSec + 1) * widget.pointSpacing,
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppConstant.cardRadius),
      child: DecoratedBox(
        decoration: AppConstant.surfaceCardDecoration(context),
        child: Row(
          children: [
            SizedBox(
              width: 56,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 12, 6, 12),
                child: _FrozenYAxis(
                  minY: ySpec.minY,
                  maxY: ySpec.maxY,
                  interval: ySpec.interval,
                  labelStyle: AppConstant.labelSmall(context),
                ),
              ),
            ),
            Expanded(
              child: Scrollbar(
                controller: _controller,
                thumbVisibility: true,
                notificationPredicate: (n) => n.metrics.axis == Axis.horizontal,
                child: SingleChildScrollView(
                  controller: _controller,
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: chartWidth,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(8, 12, 12, 12),
                      child: LineChart(
                        _chartData(context, widget.points, ySpec: ySpec),
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

  int _epochSec(DateTime t) => t.millisecondsSinceEpoch ~/ 1000;

  _YSpec _calcYSpec(List<CryptoPricePoint> points) {
    final minP = points.map((t) => t.price).reduce(math.min);
    final maxP = points.map((t) => t.price).reduce(math.max);
    final range = (maxP - minP);

    final pad = math.max(1.0, range * 0.08);
    final minY = minP - pad;
    final maxY = maxP + pad;

    final yRange = (maxY - minY);
    final interval = yRange == 0 ? 1.0 : (yRange / 4);

    return _YSpec(minY: minY, maxY: maxY, interval: interval);
  }

  LineChartData _chartData(
    BuildContext context,
    List<CryptoPricePoint> points, {
    required _YSpec ySpec,
  }) {
    final spots = <FlSpot>[
      for (final p in points) FlSpot(_epochSec(p.timeSec).toDouble(), p.price),
    ];

    final minX = spots.first.x;
    final maxX = spots.last.x;

    return LineChartData(
      minX: minX,
      maxX: maxX,
      minY: ySpec.minY,
      maxY: ySpec.maxY,
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: ySpec.interval,
        verticalInterval: 10,
        getDrawingHorizontalLine: (value) => FlLine(
          color: AppConstant.outlineVariant(context, alpha: 0.35),
          strokeWidth: 1,
        ),
        getDrawingVerticalLine: (value) => FlLine(
          color: AppConstant.outlineVariant(context, alpha: 0.22),
          strokeWidth: 1,
        ),
      ),
      borderData: FlBorderData(show: false),
      titlesData: FlTitlesData(
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 22,
            interval: 10,
            getTitlesWidget: (value, meta) {
              final dt = DateTime.fromMillisecondsSinceEpoch(
                value.toInt() * 1000,
              );
              final hh = dt.hour.toString().padLeft(2, '0');
              final mm = dt.minute.toString().padLeft(2, '0');
              final ss = dt.second.toString().padLeft(2, '0');
              return Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  '$hh:$mm:$ss',
                  style: AppConstant.labelSmall(context),
                ),
              );
            },
          ),
        ),
      ),
      lineTouchData: LineTouchData(
        enabled: true,
        handleBuiltInTouches: true,
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (touchedSpot) =>
              Theme.of(context).colorScheme.surfaceContainerHigh,
          tooltipBorderRadius: BorderRadius.circular(10),
          tooltipBorder: BorderSide(
            color: AppConstant.outlineVariant(context, alpha: 0.7),
            width: 1,
          ),
          tooltipPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
          tooltipMargin: 12,
          maxContentWidth: 160,
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((s) {
              final cs = Theme.of(context).colorScheme;
              final dt = DateTime.fromMillisecondsSinceEpoch(
                s.x.toInt() * 1000,
              );
              final hh = dt.hour.toString().padLeft(2, '0');
              final mm = dt.minute.toString().padLeft(2, '0');
              final ss = dt.second.toString().padLeft(2, '0');
              return LineTooltipItem(
                s.y.toStringAsFixed(2),
                (AppConstant.labelLarge(context) ?? const TextStyle()).copyWith(
                  color: cs.onSurface,
                  fontWeight: FontWeight.w700,
                ),
                children: [
                  TextSpan(
                    text: '\n$hh:$mm:$ss',
                    style:
                        (AppConstant.labelSmall(context) ?? const TextStyle())
                            .copyWith(color: cs.onSurfaceVariant),
                  ),
                ],
              );
            }).toList();
          },
        ),
      ),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          curveSmoothness: 0.18,
          color: AppConstant.primary(context),
          barWidth: 2,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppConstant.primary(context, alpha: 0.18),
                AppConstant.primary(context, alpha: 0.02),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _YSpec {
  const _YSpec({
    required this.minY,
    required this.maxY,
    required this.interval,
  });

  final double minY;
  final double maxY;
  final double interval;
}

class _FrozenYAxis extends StatelessWidget {
  const _FrozenYAxis({
    required this.minY,
    required this.maxY,
    required this.interval,
    required this.labelStyle,
  });

  final double minY;
  final double maxY;
  final double interval;
  final TextStyle? labelStyle;

  @override
  Widget build(BuildContext context) {
    final range = (maxY - minY);
    final safeRange = range == 0 ? 1.0 : range;
    final values = <double>[for (var i = 0; i <= 4; i++) (maxY - interval * i)];

    return LayoutBuilder(
      builder: (context, constraints) {
        final h = constraints.maxHeight;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            for (final value in values)
              Positioned(
                top: ((1 - ((value - minY) / safeRange)) * h) - 8,
                left: 0,
                right: 0,
                child: Text(
                  _formatPrice(value),
                  style: labelStyle,
                  textAlign: TextAlign.right,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        );
      },
    );
  }

  String _formatPrice(double value) {
    final abs = value.abs();
    if (abs >= 1000) return value.toStringAsFixed(0);
    if (abs >= 10) return value.toStringAsFixed(2);
    return value.toStringAsFixed(4);
  }
}

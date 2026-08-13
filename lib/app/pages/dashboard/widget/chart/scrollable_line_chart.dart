import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:jupyter_health/app/pages/dashboard/widget/chart/chart_axis.dart';
import 'package:jupyter_health/app/pages/dashboard/widget/chart/scrollable_chart_context.dart';
import 'package:jupyter_health/utils/extensions/theme_extension.dart';

class ScrollableLineChart<T> extends StatefulWidget {
  final bool isHourly;
  final DateTime origin;
  final double dataMaxX;
  final List<double> yValues;
  final List<({double x, T data})> selectablePoints;
  final ValueChanged<T> onPointSelected;
  final List<LineChartBarData> Function(ScrollableChartContext context)
  buildSeries;
  final List<BetweenBarsData> Function(
    ScrollableChartContext context,
    int seriesStartIndex,
  )?
  buildBetweenBars;

  const ScrollableLineChart({
    super.key,
    required this.isHourly,
    required this.origin,
    required this.dataMaxX,
    required this.yValues,
    required this.selectablePoints,
    required this.onPointSelected,
    required this.buildSeries,
    this.buildBetweenBars,
  });

  @override
  State<ScrollableLineChart<T>> createState() => _ScrollableLineChartState<T>();
}

class _ScrollableLineChartState<T> extends State<ScrollableLineChart<T>>
    with SingleTickerProviderStateMixin {
  static const _scrollThreshold = 6.0;
  static const _flingFriction = 0.012;
  static const _flingVelocityFactor = 1.25;
  static const _minFlingVelocityPx = 80.0;

  /// Minutes/sec — below this the fling is treated as done and we snap.
  static const _flingSnapVelocity = 55.0;
  static const _snapDuration = Duration(milliseconds: 220);

  double? _selectedX;
  double? _windowStart;
  bool _isScrolling = false;
  bool _isSnapping = false;
  double _panAccumulatedDx = 0;
  double? _panChartX;
  Offset? _lastDragLocalPosition;
  double _flingMaxWindowStart = 0;
  late final AnimationController _flingController;

  double get _visibleMinutes =>
      ChartAxis.visibleMinutes(isHourly: widget.isHourly);

  double get _snapInterval => ChartAxis.snapInterval(isHourly: widget.isHourly);

  @override
  void initState() {
    super.initState();
    _flingController = AnimationController.unbounded(vsync: this)
      ..addListener(_onFlingTick)
      ..addStatusListener(_onFlingStatus);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _selectLatest();
    });
  }

  @override
  void didUpdateWidget(covariant ScrollableLineChart<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isHourly != widget.isHourly) {
      _stopFling();
      _windowStart = null;
      _selectedX = null;
      _isScrolling = false;
      _panAccumulatedDx = 0;
      _panChartX = null;
      _lastDragLocalPosition = null;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _selectLatest();
      });
    }
  }

  void _selectLatest() {
    final points = widget.selectablePoints;
    if (points.isEmpty) return;

    final latest = points.last;
    setState(() => _selectedX = latest.x);
    widget.onPointSelected(latest.data);
  }

  @override
  void dispose() {
    _flingController.dispose();
    super.dispose();
  }

  void _onFlingTick() {
    if (!_flingController.isAnimating) return;

    final raw = _flingController.value;
    final clamped = raw.clamp(0.0, _flingMaxWindowStart);
    if (_windowStart != clamped) {
      setState(() => _windowStart = clamped);
    }

    if (_isSnapping) return;

    final hitBound = raw != clamped;
    final nearlyStopped = _flingController.velocity.abs() < _flingSnapVelocity;
    if (hitBound || nearlyStopped) {
      _flingController.stop();
      _snapWindow();
    }
  }

  void _onFlingStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      if (_isSnapping) {
        _isSnapping = false;
        return;
      }
      _snapWindow();
    }
  }

  void _stopFling() {
    _isSnapping = false;
    if (_flingController.isAnimating) {
      _flingController.stop();
    }
  }

  void _snapWindow() {
    final currentStart = _windowStart ?? _flingMaxWindowStart;
    final snapped = ((currentStart / _snapInterval).round() * _snapInterval)
        .clamp(0.0, _flingMaxWindowStart);
    if ((currentStart - snapped).abs() < 0.01) {
      if (_windowStart != snapped) {
        setState(() => _windowStart = snapped);
      }
      return;
    }

    _isSnapping = true;
    _flingController.value = currentStart;
    _flingController.animateTo(
      snapped,
      duration: _snapDuration,
      curve: Curves.easeOutCubic,
    );
  }

  void _startFling({
    required double velocityPxPerSec,
    required double chartMaxX,
    required double minutesPerPixel,
  }) {
    final maxWindowStart = math.max(0.0, chartMaxX - _visibleMinutes);
    _flingMaxWindowStart = maxWindowStart;
    final currentStart = _windowStart ?? maxWindowStart;

    if (velocityPxPerSec.abs() < _minFlingVelocityPx) {
      _snapWindow();
      return;
    }

    final velocityMinutes =
        -velocityPxPerSec * minutesPerPixel * _flingVelocityFactor;
    _flingController.animateWith(
      FrictionSimulation(_flingFriction, currentStart, velocityMinutes),
    );
  }

  ({double x, T data}) _nearestSelectablePoint(double x) =>
      widget.selectablePoints.reduce(
        (best, point) =>
            (point.x - x).abs() < (best.x - x).abs() ? point : best,
      );

  void _selectNearestAtChartX(double chartX) {
    if (widget.selectablePoints.isEmpty) return;

    final nearest = _nearestSelectablePoint(chartX);
    if (_selectedX != nearest.x) {
      setState(() => _selectedX = nearest.x);
      widget.onPointSelected(nearest.data);
    }
  }

  void _onTouch({
    required FlTouchEvent event,
    required LineTouchResponse? response,
    required double chartMaxX,
    required double minutesPerPixel,
  }) {
    if (event is FlPanStartEvent || event is FlLongPressStart) {
      _stopFling();
      _panAccumulatedDx = 0;
      _panChartX = response?.touchChartCoordinate.dx;
      _lastDragLocalPosition = event.localPosition;
      _isScrolling = false;
      return;
    }

    if (event is FlPanUpdateEvent || event is FlLongPressMoveUpdate) {
      final localPosition = event.localPosition;
      if (localPosition == null) return;

      final dx = event is FlPanUpdateEvent
          ? event.details.delta.dx
          : localPosition.dx - (_lastDragLocalPosition?.dx ?? localPosition.dx);
      _lastDragLocalPosition = localPosition;

      _panAccumulatedDx += dx;
      if (_panAccumulatedDx.abs() > _scrollThreshold) {
        _isScrolling = true;
      }

      if (_isScrolling) {
        final maxWindowStart = math.max(0.0, chartMaxX - _visibleMinutes);
        _flingMaxWindowStart = maxWindowStart;
        final currentStart = _windowStart ?? maxWindowStart;
        setState(() {
          _windowStart = (currentStart - dx * minutesPerPixel).clamp(
            0.0,
            maxWindowStart,
          );
        });
        return;
      }

      _panChartX = response?.touchChartCoordinate.dx ?? _panChartX;
      return;
    }

    if (event is FlPanEndEvent || event is FlLongPressEnd) {
      if (_isScrolling) {
        final velocityPxPerSec = event is FlPanEndEvent
            ? event.details.velocity.pixelsPerSecond.dx
            : (event as FlLongPressEnd).details.velocity.pixelsPerSecond.dx;
        _startFling(
          velocityPxPerSec: velocityPxPerSec,
          chartMaxX: chartMaxX,
          minutesPerPixel: minutesPerPixel,
        );
      } else if (_panChartX != null) {
        _selectNearestAtChartX(_panChartX!);
      }
      _isScrolling = false;
      _panAccumulatedDx = 0;
      _panChartX = null;
      _lastDragLocalPosition = null;
      return;
    }

    if (event is FlTapUpEvent) {
      final chartX = response?.touchChartCoordinate.dx;
      if (chartX != null) {
        _selectNearestAtChartX(chartX);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.theme;
    final selectablePoints = widget.selectablePoints;

    if (selectablePoints.isEmpty || widget.yValues.isEmpty) {
      return const SizedBox.shrink();
    }

    final chartMaxX = math.max(widget.dataMaxX, _visibleMinutes);
    final maxWindowStart = math.max(0.0, chartMaxX - _visibleMinutes);
    final windowStart = (_windowStart ?? maxWindowStart).clamp(
      0.0,
      maxWindowStart,
    );
    final highlightedX = _selectedX ?? selectablePoints.last.x;
    final yBounds = ChartAxis.yBounds(widget.yValues);

    return SizedBox(
      height: ChartAxis.height,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final plotWidth = math.max(
            1.0,
            constraints.maxWidth - ChartAxis.leftTitlesSize,
          );
          final minutesPerPixel = _visibleMinutes / plotWidth;
          final chartContext = ScrollableChartContext(
            colors: colors,
            windowStart: windowStart,
            visibleMinutes: _visibleMinutes,
            highlightedX: highlightedX,
            minutesPerPixel: minutesPerPixel,
            minY: yBounds.minY,
            maxY: yBounds.maxY,
          );
          final xPadding = ChartAxis.dotPaddingPx * minutesPerPixel;
          final seriesStartIndex = ChartAxis.leftTitleCount;
          final series = widget.buildSeries(chartContext);

          return LineChart(
            LineChartData(
              clipData: const FlClipData.all(),
              lineTouchData: LineTouchData(
                handleBuiltInTouches: true,
                touchCallback: (event, response) => _onTouch(
                  event: event,
                  response: response,
                  chartMaxX: chartMaxX,
                  minutesPerPixel: minutesPerPixel,
                ),
                getTouchedSpotIndicator: (barData, spotIndexes) => spotIndexes
                    .map(
                      (index) => TouchedSpotIndicatorData(
                        const FlLine(color: Colors.transparent),
                        FlDotData(show: false),
                      ),
                    )
                    .toList(),
                touchTooltipData: LineTouchTooltipData(
                  getTooltipItems: (touchedSpots) =>
                      List<LineTooltipItem?>.filled(touchedSpots.length, null),
                ),
              ),
              gridData: const FlGridData(show: false),
              extraLinesData: const ExtraLinesData(),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: ChartAxis.bottomTitles(
                    context: context,
                    origin: widget.origin,
                    isHourly: widget.isHourly,
                    selectedX: highlightedX,
                  ),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                leftTitles: AxisTitles(
                  sideTitles: ChartAxis.leftTitles(
                    context,
                    interval: yBounds.interval,
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                ...ChartAxis.gridBars(
                  colors: colors,
                  windowStart: windowStart,
                  visibleMinutes: _visibleMinutes,
                  minY: yBounds.minY,
                  interval: yBounds.interval,
                ),
                ...series,
              ],
              betweenBarsData:
                  widget.buildBetweenBars?.call(
                    chartContext,
                    seriesStartIndex,
                  ) ??
                  const [],
              minX: windowStart - xPadding,
              maxX: windowStart + _visibleMinutes + xPadding,
              minY: yBounds.minY,
              maxY: yBounds.maxY,
              baselineX: 0,
            ),
            duration: Duration.zero,
          );
        },
      ),
    );
  }
}

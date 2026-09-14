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
  final List<FlSpot> ySpots;
  final List<({double x, T data})> selectablePoints;
  final ValueChanged<T> onPointSelected;
  final List<LineChartBarData> Function(ScrollableChartContext context)
  buildSeries;
  final List<BetweenBarsData> Function(
    ScrollableChartContext context,
    int seriesStartIndex,
  )?
  buildBetweenBars;
  final VoidCallback? onReachOlderData;
  final double minYInterval;
  final bool yFromZero;
  final double? preferredMinY;
  final double? preferredMaxY;
  final String Function(double value)? formatY;

  const ScrollableLineChart({
    super.key,
    required this.isHourly,
    required this.origin,
    required this.dataMaxX,
    required this.ySpots,
    required this.selectablePoints,
    required this.onPointSelected,
    required this.buildSeries,
    this.buildBetweenBars,
    this.onReachOlderData,
    this.minYInterval = 1,
    this.yFromZero = false,
    this.preferredMinY,
    this.preferredMaxY,
    this.formatY,
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
  static const _yDuration = Duration(milliseconds: 300);

  double? _selectedX;
  double? _windowStart;
  bool _isScrolling = false;
  bool _isSnapping = false;
  bool _didRequestOlderData = false;
  double _panAccumulatedDx = 0;
  double? _panChartX;
  Offset? _lastDragLocalPosition;
  Tween<Offset>? _yRangeTween;
  late final AnimationController _flingController;

  double get _visibleMinutes =>
      ChartAxis.visibleMinutes(isHourly: widget.isHourly);

  double get _snapInterval => ChartAxis.snapInterval(isHourly: widget.isHourly);

  double get _maxWindowStart => widget.dataMaxX - _visibleMinutes;

  double get _minWindowStart => math.min(0.0, _maxWindowStart);

  bool get _hasPreferredYRange =>
      widget.preferredMinY != null && widget.preferredMaxY != null;

  Iterable<double> _visibleYValues(double windowStart) {
    final pad = _snapInterval;
    final minX = windowStart - pad;
    final maxX = windowStart + _visibleMinutes + pad;
    final visible = [
      for (final spot in widget.ySpots)
        if (spot.x >= minX && spot.x <= maxX && spot.y.isFinite) spot.y,
    ];
    if (visible.isNotEmpty) return visible;
    if (_hasPreferredYRange) return const [];
    return [
      for (final spot in widget.ySpots)
        if (spot.y.isFinite) spot.y,
    ];
  }

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
      _didRequestOlderData = false;
      _panAccumulatedDx = 0;
      _panChartX = null;
      _lastDragLocalPosition = null;
      _yRangeTween = null;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _selectLatest();
      });
      return;
    }

    if (oldWidget.origin != widget.origin) {
      final deltaMinutes = widget.origin
          .difference(oldWidget.origin)
          .inMinutes
          .toDouble();
      if (deltaMinutes != 0) {
        if (_windowStart != null) {
          _windowStart = _windowStart! - deltaMinutes;
        }
        if (_selectedX != null) {
          _selectedX = _selectedX! - deltaMinutes;
        }
      }
    }

    if (oldWidget.origin != widget.origin ||
        oldWidget.dataMaxX != widget.dataMaxX ||
        oldWidget.selectablePoints.length != widget.selectablePoints.length) {
      _didRequestOlderData = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _maybeRequestOlderData();
      });
    }
  }

  void _selectLatest() {
    final points = widget.selectablePoints;
    if (points.isEmpty) return;

    final latest = points.last;
    setState(() => _selectedX = latest.x);
    widget.onPointSelected(latest.data);
    _maybeRequestOlderData();
  }

  void _maybeRequestOlderData() {
    if (widget.onReachOlderData == null) return;

    final start = _windowStart ?? _maxWindowStart;
    if (start > _visibleMinutes * 0.25) {
      _didRequestOlderData = false;
      return;
    }

    if (_didRequestOlderData) return;
    _didRequestOlderData = true;
    widget.onReachOlderData!();
  }

  @override
  void dispose() {
    _flingController.dispose();
    super.dispose();
  }

  void _onFlingTick() {
    if (!_flingController.isAnimating) return;

    final raw = _flingController.value;
    final clamped = raw.clamp(_minWindowStart, _maxWindowStart);
    if (_windowStart != clamped) {
      setState(() => _windowStart = clamped);
    }
    _maybeRequestOlderData();

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
    final currentStart = _windowStart ?? _maxWindowStart;
    final snapped = ((currentStart / _snapInterval).round() * _snapInterval)
        .clamp(_minWindowStart, _maxWindowStart);
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
    required double minutesPerPixel,
  }) {
    final currentStart = _windowStart ?? _maxWindowStart;

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

  ({double x, T data}) _nearestSelectablePoint(double x) {
    final targetBucket = ChartAxis.bucketX(x, isHourly: widget.isHourly);
    return widget.selectablePoints.reduce((best, point) {
      final pointBucket = ChartAxis.bucketX(point.x, isHourly: widget.isHourly);
      final bestBucket = ChartAxis.bucketX(best.x, isHourly: widget.isHourly);
      final pointDist = (pointBucket - targetBucket).abs();
      final bestDist = (bestBucket - targetBucket).abs();
      if (pointDist != bestDist) {
        return pointDist < bestDist ? point : best;
      }
      return (point.x - x).abs() < (best.x - x).abs() ? point : best;
    });
  }

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
        final currentStart = _windowStart ?? _maxWindowStart;
        setState(() {
          _windowStart = (currentStart - dx * minutesPerPixel).clamp(
            _minWindowStart,
            _maxWindowStart,
          );
        });
        _maybeRequestOlderData();
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

    if (selectablePoints.isEmpty || widget.ySpots.isEmpty) {
      return const SizedBox.shrink();
    }

    final windowStart = (_windowStart ?? _maxWindowStart).clamp(
      _minWindowStart,
      _maxWindowStart,
    );
    final highlightedX = _selectedX ?? selectablePoints.last.x;
    final yBounds = ChartAxis.yBounds(
      _visibleYValues(windowStart),
      minInterval: widget.minYInterval,
      fromZero: widget.yFromZero,
      preferredMinY: widget.preferredMinY,
      preferredMaxY: widget.preferredMaxY,
    );
    final targetRange = Offset(yBounds.minY, yBounds.maxY);
    final yTween = _yRangeTween;
    if (yTween == null || yTween.end != targetRange) {
      _yRangeTween = Tween(begin: yTween?.end ?? targetRange, end: targetRange);
    }

    return SizedBox(
      height: ChartAxis.height,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final plotWidth = math.max(
            1.0,
            constraints.maxWidth - ChartAxis.leftTitlesSize,
          );
          final minutesPerPixel = _visibleMinutes / plotWidth;
          final xPadding = ChartAxis.dotPaddingPx * minutesPerPixel;

          return TweenAnimationBuilder<Offset>(
            duration: _yDuration,
            curve: Curves.easeOutCubic,
            tween: _yRangeTween!,
            builder: (context, animatedRange, _) {
              final minY = animatedRange.dx;
              final maxY = math.max(
                animatedRange.dy,
                minY + widget.minYInterval,
              );
              final interval = yBounds.interval;
              final chartContext = ScrollableChartContext(
                colors: colors,
                windowStart: windowStart,
                visibleMinutes: _visibleMinutes,
                highlightedX: highlightedX,
                minutesPerPixel: minutesPerPixel,
                minY: minY,
                maxY: maxY,
              );
              final series = widget.buildSeries(chartContext);
              final grid = ChartAxis.gridBars(
                colors: colors,
                windowStart: windowStart,
                visibleMinutes: _visibleMinutes,
                minY: minY,
                maxY: maxY,
                interval: interval,
              );

              return LineChart(
                LineChartData(
                  clipData: const FlClipData.all(),
                  lineTouchData: LineTouchData(
                    handleBuiltInTouches: true,
                    touchCallback: (event, response) => _onTouch(
                      event: event,
                      response: response,
                      minutesPerPixel: minutesPerPixel,
                    ),
                    getTouchedSpotIndicator: (barData, spotIndexes) =>
                        spotIndexes
                            .map(
                              (index) => TouchedSpotIndicatorData(
                                const FlLine(color: Colors.transparent),
                                FlDotData(show: false),
                              ),
                            )
                            .toList(),
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (touchedSpots) =>
                          List<LineTooltipItem?>.filled(
                            touchedSpots.length,
                            null,
                          ),
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
                        interval: interval,
                        format: widget.formatY,
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [...grid, ...series],
                  betweenBarsData:
                      widget.buildBetweenBars?.call(
                        chartContext,
                        grid.length,
                      ) ??
                      const [],
                  minX: windowStart - xPadding,
                  maxX: windowStart + _visibleMinutes + xPadding,
                  minY: minY,
                  maxY: maxY,
                  baselineX: 0,
                ),
                duration: Duration.zero,
              );
            },
          );
        },
      ),
    );
  }
}

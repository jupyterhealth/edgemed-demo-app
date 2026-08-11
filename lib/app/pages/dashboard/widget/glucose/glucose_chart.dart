import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:jupyter_health/config/theme/app_colors.dart';
import 'package:jupyter_health/config/theme/theme_extensions.dart';
import 'package:jupyter_health/domain/entity/observations/observation.dart';
import 'package:jupyter_health/domain/entity/observations/observation_data.dart';

class GlucoseChart extends StatefulWidget {
  final List<Observation> observations;
  final bool isHourly;
  final void Function(Observation observation) onObservationSelected;
  const GlucoseChart({
    super.key,
    required this.observations,
    required this.isHourly,
    required this.onObservationSelected,
  });

  @override
  State<GlucoseChart> createState() => _GlucoseChartState();
}

class _GlucoseChartState extends State<GlucoseChart>
    with SingleTickerProviderStateMixin {
  static const _chartHeight = 156.0;
  static const _yInterval = 20.0;
  static const _leftTitleCount = 6;
  static const _yRange = _yInterval * (_leftTitleCount - 1);
  static const _hourlyBottomLabelCount = 8;
  static const _visibleHours = _hourlyBottomLabelCount - 1;
  /// Full week Mon–Sun visible at once.
  static const _visibleDays = 7;
  static const _minutesPerHour = 60.0;
  static const _minutesPerDay = 24 * _minutesPerHour;
  static const _leftTitlesSize = 40.0;
  static const _scrollThreshold = 6.0;
  static const _dotPaddingPx = 18.0;
  static const _flingFriction = 0.012;
  static const _flingVelocityFactor = 1.25;
  static const _minFlingVelocityPx = 80.0;

  /// Minutes/sec — below this the fling is treated as done and we snap.
  static const _flingSnapVelocity = 55.0;
  static const _snapDuration = Duration(milliseconds: 220);
  static const _dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

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
      widget.isHourly ? _visibleHours * _minutesPerHour : _visibleDays * _minutesPerDay;

  double get _snapInterval =>
      widget.isHourly ? _minutesPerHour : _minutesPerDay;

  @override
  void initState() {
    super.initState();
    _flingController = AnimationController.unbounded(vsync: this)
      ..addListener(_onFlingTick)
      ..addStatusListener(_onFlingStatus);
  }

  @override
  void didUpdateWidget(covariant GlucoseChart oldWidget) {
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
        _selectLatestForMode();
      });
    }
  }

  void _selectLatestForMode() {
    final points = _glucosePoints;
    if (points.isEmpty) return;

    final origin = _chartOrigin(points.first.date);
    final selectablePoints = widget.isHourly
        ? _hourlyPoints(points, origin)
        : _dailyPoints(points, origin);
    if (selectablePoints.isEmpty) return;

    final latest = selectablePoints.last;
    setState(() => _selectedX = latest.spot.x);
    widget.onObservationSelected(latest.observation);
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

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final points = _glucosePoints;

    if (points.isEmpty) {
      return const Center(child: Text('No glucose data'));
    }

    final origin = _chartOrigin(points.first.date);
    final spots = [
      for (final point in points)
        FlSpot(point.date.difference(origin).inMinutes.toDouble(), point.value),
    ];
    final selectablePoints = widget.isHourly
        ? _hourlyPoints(points, origin)
        : _dailyPoints(points, origin);
    final selectableSpots = [for (final point in selectablePoints) point.spot];
    final dataMaxX = spots.last.x;
    final chartMaxX = math.max(dataMaxX, _visibleMinutes);
    final maxWindowStart = math.max(0.0, chartMaxX - _visibleMinutes);
    final windowStart = (_windowStart ?? maxWindowStart).clamp(
      0.0,
      maxWindowStart,
    );

    final highlightedX = _selectedX ?? selectableSpots.last.x;

    return SizedBox(
      height: _chartHeight,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final plotWidth = math.max(
            1.0,
            constraints.maxWidth - _leftTitlesSize,
          );
          final minutesPerPixel = _visibleMinutes / plotWidth;
          return LineChart(
            _chartData(
              colors: colors,
              origin: origin,
              spots: spots,
              selectablePoints: selectablePoints,
              highlightedX: highlightedX,
              windowStart: windowStart,
              chartMaxX: chartMaxX,
              minutesPerPixel: minutesPerPixel,
            ),
            duration: Duration.zero,
          );
        },
      ),
    );
  }

  List<({DateTime date, double value, Observation observation})>
  get _glucosePoints {
    final points = widget.observations
        .map(
          (observation) => observation.data.whenOrNull(
            glucose: (value, date) =>
                (date: date, value: value, observation: observation),
          ),
        )
        .whereType<({DateTime date, double value, Observation observation})>()
        .toList();

    points.sort((a, b) => a.date.compareTo(b.date));
    return points;
  }

  DateTime _chartOrigin(DateTime firstDate) {
    if (widget.isHourly) {
      return DateTime(
        firstDate.year,
        firstDate.month,
        firstDate.day,
        firstDate.hour,
      );
    }
    return DateTime(firstDate.year, firstDate.month, firstDate.day);
  }

  List<({FlSpot spot, Observation observation})> _hourlyPoints(
    List<({DateTime date, double value, Observation observation})> points,
    DateTime origin,
  ) {
    final bestByHour =
        <int, ({FlSpot spot, Observation observation, int distance})>{};

    for (final point in points) {
      final minutes = point.date.difference(origin).inMinutes;
      final nearestHour = (minutes / _minutesPerHour).round();
      final distance = (minutes - nearestHour * _minutesPerHour).abs().toInt();
      final existing = bestByHour[nearestHour];

      if (existing == null || distance < existing.distance) {
        bestByHour[nearestHour] = (
          spot: FlSpot(minutes.toDouble(), point.value),
          observation: point.observation,
          distance: distance,
        );
      }
    }

    final hours = bestByHour.keys.toList()..sort();
    return [
      for (final hour in hours)
        (
          spot: bestByHour[hour]!.spot,
          observation: bestByHour[hour]!.observation,
        ),
    ];
  }

  List<({FlSpot spot, Observation observation})> _dailyPoints(
    List<({DateTime date, double value, Observation observation})> points,
    DateTime origin,
  ) {
    final bestByDay =
        <int, ({FlSpot spot, Observation observation, int distance})>{};

    for (final point in points) {
      final minutes = point.date.difference(origin).inMinutes;
      final dayIndex = (minutes / _minutesPerDay).floor();
      final noonOfDay = dayIndex * _minutesPerDay + (_minutesPerDay / 2);
      final distance = (minutes - noonOfDay).abs().round();
      final existing = bestByDay[dayIndex];

      if (existing == null || distance < existing.distance) {
        bestByDay[dayIndex] = (
          spot: FlSpot(minutes.toDouble(), point.value),
          observation: point.observation,
          distance: distance,
        );
      }
    }

    final days = bestByDay.keys.toList()..sort();
    return [
      for (final day in days)
        (
          spot: bestByDay[day]!.spot,
          observation: bestByDay[day]!.observation,
        ),
    ];
  }

  ({FlSpot spot, Observation observation}) _nearestSelectablePoint(
    double x,
    List<({FlSpot spot, Observation observation})> selectablePoints,
  ) => selectablePoints.reduce(
    (best, point) =>
        (point.spot.x - x).abs() < (best.spot.x - x).abs() ? point : best,
  );

  void _selectNearestAtChartX(
    double chartX,
    List<({FlSpot spot, Observation observation})> selectablePoints,
  ) {
    if (selectablePoints.isEmpty) return;

    final nearest = _nearestSelectablePoint(chartX, selectablePoints);
    if (_selectedX != nearest.spot.x) {
      setState(() => _selectedX = nearest.spot.x);
      widget.onObservationSelected(nearest.observation);
    }
  }

  ({double minY, double maxY}) _yBounds(Iterable<double> values) {
    final minValue = values.reduce((a, b) => a < b ? a : b);
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final mid = (minValue + maxValue) / 2;

    var minY = ((mid - _yRange / 2) / _yInterval).round() * _yInterval;
    var maxY = minY + _yRange;

    if (minValue < minY) {
      minY = (minValue / _yInterval).floor() * _yInterval;
      maxY = minY + _yRange;
    }
    if (maxValue > maxY) {
      maxY = (maxValue / _yInterval).ceil() * _yInterval;
      minY = maxY - _yRange;
    }

    if (minY < 0) {
      minY = 0;
      maxY = _yRange;
    }

    return (minY: minY, maxY: maxY);
  }

  void _onTouch({
    required FlTouchEvent event,
    required LineTouchResponse? response,
    required List<({FlSpot spot, Observation observation})> selectablePoints,
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
        _selectNearestAtChartX(_panChartX!, selectablePoints);
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
        _selectNearestAtChartX(chartX, selectablePoints);
      }
    }
  }

  LineChartData _chartData({
    required AppColorsTheme colors,
    required DateTime origin,
    required List<FlSpot> spots,
    required List<({FlSpot spot, Observation observation})> selectablePoints,
    required double highlightedX,
    required double windowStart,
    required double chartMaxX,
    required double minutesPerPixel,
  }) {
    final yBounds = _yBounds(spots.map((spot) => spot.y));
    final xPadding = _dotPaddingPx * minutesPerPixel;

    return LineChartData(
      clipData: const FlClipData.all(),
      lineTouchData: LineTouchData(
        handleBuiltInTouches: true,
        touchCallback: (event, response) => _onTouch(
          event: event,
          response: response,
          selectablePoints: selectablePoints,
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
        bottomTitles: AxisTitles(sideTitles: _bottomTitles(colors, origin)),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: AxisTitles(sideTitles: _leftTitles(colors)),
      ),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        for (var i = 0; i < _leftTitleCount; i++)
          LineChartBarData(
            spots: [
              FlSpot(windowStart, yBounds.minY + i * _yInterval),
              FlSpot(
                windowStart + _visibleMinutes,
                yBounds.minY + i * _yInterval,
              ),
            ],
            color: colors.primaryBeige300,
            barWidth: 1,
            dotData: const FlDotData(show: false),
            dashArray: const [6, 4],
          ),
        LineChartBarData(
          isCurved: true,
          curveSmoothness: 0.25,
          color: colors.primaryGreen500,
          barWidth: 2,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            checkToShowDot: (spot, _) => spot.x == highlightedX,
            getDotPainter: (spot, percent, bar, index) => _dotPainter(colors),
          ),
          spots: spots,
        ),
      ],
      minX: windowStart - xPadding,
      maxX: windowStart + _visibleMinutes + xPadding,
      minY: yBounds.minY,
      maxY: yBounds.maxY,
      baselineX: 0,
    );
  }

  FlDotCirclePainter _dotPainter(AppColorsTheme colors) => FlDotCirclePainter(
    radius: 6,
    color: colors.primaryGreen500,
    strokeWidth: 6,
    strokeColor: colors.primaryGreen500.withValues(alpha: 0.25),
  );

  SideTitles _leftTitles(AppColorsTheme colors) => SideTitles(
    showTitles: true,
    reservedSize: _leftTitlesSize,
    interval: _yInterval,
    getTitlesWidget: (value, meta) => SideTitleWidget(
      meta: meta,
      child: Text(
        value.toStringAsFixed(0),
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
          color: colors.primaryBeige800,
        ),
        textAlign: TextAlign.center,
      ),
    ),
  );

  SideTitles _bottomTitles(AppColorsTheme colors, DateTime origin) =>
      SideTitles(
        showTitles: true,
        reservedSize: 32,
        interval: _snapInterval,
        minIncluded: false,
        maxIncluded: false,
        getTitlesWidget: (value, meta) {
          final date = origin.add(Duration(minutes: value.round()));

          return SideTitleWidget(
            meta: meta,
            space: 10,
            child: Text(
              widget.isHourly ? _hourLabel(date) : _dayLabel(date),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: colors.primaryBeige800,
              ),
            ),
          );
        },
      );

  String _hourLabel(DateTime date) {
    final hour = date.hour;
    final period = hour < 12 ? 'am' : 'pm';
    final hour12 = hour % 12 == 0 ? 12 : hour % 12;
    return '$hour12$period';
  }

  String _dayLabel(DateTime date) => _dayLabels[date.weekday - 1];
}

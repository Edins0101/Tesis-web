import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/dashboard_models.dart';
import '../../../../widgets/app_panel.dart';

const double _chartCardHeight = 224;

class BottomCharts extends StatelessWidget {
  const BottomCharts({
    super.key,
    required this.data,
    required this.compact,
  });

  final DashboardData data;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ResultChart(
            result: data.results,
            width: double.infinity,
            height: _chartCardHeight,
          ),
          const SizedBox(height: 14),
          TypeChart(
            types: data.types,
            width: double.infinity,
            height: _chartCardHeight,
          ),
          const SizedBox(height: 14),
          DayChart(
            byDay: data.byDay,
            width: double.infinity,
            height: _chartCardHeight,
          ),
        ],
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 14.0;
        final maxWidth = constraints.hasBoundedWidth
            ? constraints.maxWidth
            : (360 * 3) + (spacing * 2);
        final cardWidth = (maxWidth - (spacing * 2)) / 3;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            ResultChart(
              result: data.results,
              width: cardWidth,
              height: _chartCardHeight,
            ),
            TypeChart(
              types: data.types,
              width: cardWidth,
              height: _chartCardHeight,
            ),
            DayChart(
              byDay: data.byDay,
              width: cardWidth,
              height: _chartCardHeight,
            ),
          ],
        );
      },
    );
  }
}

class ResultChart extends StatelessWidget {
  const ResultChart({
    super.key,
    required this.result,
    required this.width,
    required this.height,
  });

  final ResultBreakdown result;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final total = result.authorized + result.rejected;
    return SizedBox(
      width: width,
      height: height,
      child: AppPanel(
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PanelTitle('Por resultado'),
            const SizedBox(height: 18),
            Row(
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: CustomPaint(
                    painter: _DonutPainter(
                      authorized: result.authorized,
                      rejected: result.rejected,
                    ),
                    child: Center(
                      child: Text(
                        '$total',
                        style: const TextStyle(
                          color: Color(0xFF2D4864),
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 18),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _LegendRow(
                      color: const Color(0xFF14D99B),
                      text: 'Autorizado  ${result.authorized}',
                    ),
                    const SizedBox(height: 10),
                    _LegendRow(
                      color: const Color(0xFFFF5B7E),
                      text: 'Rechazado  ${result.rejected}',
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class TypeChart extends StatelessWidget {
  const TypeChart({
    super.key,
    required this.types,
    required this.width,
    required this.height,
  });

  final List<AccessTypeMetric> types;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: AppPanel(
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PanelTitle('Por tipo de acceso'),
            const SizedBox(height: 20),
            for (var i = 0; i < types.length; i++) ...[
              _HorizontalMetric(metric: types[i]),
              if (i != types.length - 1) const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }
}

class DayChart extends StatelessWidget {
  const DayChart({
    super.key,
    required this.byDay,
    required this.width,
    required this.height,
  });

  final List<AccessByDayMetric> byDay;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final maxValue = byDay.fold<double>(1, (max, item) {
      return item.value > max ? item.value : max;
    });

    return SizedBox(
      width: width,
      height: height,
      child: AppPanel(
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PanelTitle('Accesos por dia'),
            const SizedBox(height: 16),
            SizedBox(
              height: 130,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (final item in byDay)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              height: 12 + (item.value / maxValue) * 80,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Color(0xFF1DC5E1),
                                    Color(0xFF0BA1C0)
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              item.label,
                              style: const TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({
    required this.color,
    required this.text,
  });

  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 10),
        Text(
          text,
          style: const TextStyle(
            color: Color(0xFF2A4662),
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}

class _HorizontalMetric extends StatelessWidget {
  const _HorizontalMetric({required this.metric});

  final AccessTypeMetric metric;

  @override
  Widget build(BuildContext context) {
    final ratio = (metric.value / metric.max).clamp(0.0, 1.0);
    return Row(
      children: [
        SizedBox(
          width: 70,
          child: Text(
            metric.label,
            style: const TextStyle(
              color: Color(0xFF516D88),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Stack(
            children: [
              Container(
                height: 10,
                decoration: BoxDecoration(
                  color: AppColors.barBackground,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              FractionallySizedBox(
                widthFactor: ratio,
                child: Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color: metric.color,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Text(
          '${metric.value}',
          style: const TextStyle(
            color: Color(0xFF516D88),
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _DonutPainter extends CustomPainter {
  const _DonutPainter({
    required this.authorized,
    required this.rejected,
  });

  final int authorized;
  final int rejected;

  @override
  void paint(Canvas canvas, Size size) {
    final total = math.max(authorized + rejected, 1);
    final stroke = size.width * 0.12;
    final center = (Offset.zero & size).center;
    final radius = (size.width - stroke) / 2;

    final basePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = const Color(0xFFE9F0F7)
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, basePaint);

    final authSweep = 2 * math.pi * (authorized / total);
    final rejSweep = 2 * math.pi * (rejected / total);

    final authPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = const Color(0xFF14D99B)
      ..strokeCap = StrokeCap.round;

    final rejPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = const Color(0xFFFF5B7E)
      ..strokeCap = StrokeCap.round;

    const start = -math.pi / 2;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      start,
      authSweep,
      false,
      authPaint,
    );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      start + authSweep,
      rejSweep,
      false,
      rejPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) {
    return oldDelegate.authorized != authorized ||
        oldDelegate.rejected != rejected;
  }
}

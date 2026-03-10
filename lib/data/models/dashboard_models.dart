import 'package:flutter/material.dart';

class DashboardFilterField {
  const DashboardFilterField({
    required this.label,
    required this.hint,
    this.icon,
  });

  final String label;
  final String hint;
  final IconData? icon;
}

class KpiCardData {
  const KpiCardData({
    required this.title,
    required this.value,
    required this.color,
    this.subtitle,
  });

  final String title;
  final String value;
  final Color color;
  final String? subtitle;
}

class ResultBreakdown {
  const ResultBreakdown({
    required this.authorized,
    required this.rejected,
  });

  final int authorized;
  final int rejected;
}

class AccessTypeMetric {
  const AccessTypeMetric({
    required this.label,
    required this.value,
    required this.max,
    required this.color,
  });

  final String label;
  final int value;
  final int max;
  final Color color;
}

class AccessByDayMetric {
  const AccessByDayMetric({
    required this.label,
    required this.value,
  });

  final String label;
  final double value;
}

class DashboardData {
  const DashboardData({
    required this.filters,
    required this.kpis,
    required this.results,
    required this.types,
    required this.byDay,
  });

  final List<DashboardFilterField> filters;
  final List<KpiCardData> kpis;
  final ResultBreakdown results;
  final List<AccessTypeMetric> types;
  final List<AccessByDayMetric> byDay;
}

import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../core/constants/api_config.dart';
import '../../core/constants/app_colors.dart';
import '../models/dashboard_models.dart';
import 'dashboard_service.dart';

class ApiDashboardService implements DashboardService {
  ApiDashboardService({http.Client? client})
      : _client = client ?? http.Client();

  final http.Client _client;

  @override
  Future<DashboardData> fetchDashboardData() async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/reportes/accesos/resumen');
    final response = await _client.get(
      uri,
      headers: const {'accept': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('No se pudo obtener el resumen de accesos.');
    }

    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    final success = payload['success'] == true;
    if (!success) {
      throw Exception(payload['message'] ?? 'Error consultando resumen');
    }

    final data = payload['data'] as Map<String, dynamic>? ?? const {};
    final totals = data['totales'] as Map<String, dynamic>? ?? const {};
    final byResult = (data['porResultado'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .toList();
    final byType = (data['porTipo'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .toList();
    final byDay = (data['porDia'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .toList();
    final filters = data['filters'] as Map<String, dynamic>? ?? const {};

    final totalAccess = _asInt(totals['accesos']);
    final totalAuthorized = _asInt(totals['autorizados']);
    final totalRejected = _asInt(totals['rechazados']);
    final totalPending = _asInt(totals['pendientes']);
    final totalWithCall = _asInt(totals['conLlamada']);
    final totalWithoutCall = _asInt(totals['sinLlamada']);

    final authorizedFromResult = _totalFromResult(byResult, 'autorizado');
    final rejectedFromResult = _totalFromResult(byResult, 'rechazado');

    final resolvedAuthorized =
        authorizedFromResult == 0 ? totalAuthorized : authorizedFromResult;
    final resolvedRejected =
        rejectedFromResult == 0 ? totalRejected : rejectedFromResult;

    final maxType = math.max(1, totalAccess);
    final typeMetrics = byType.map((item) {
      final rawType = (item['tipo'] ?? '').toString();
      final total = _asInt(item['total']);
      return AccessTypeMetric(
        label: _mapTypeLabel(rawType),
        value: total,
        max: maxType,
        color: _mapTypeColor(rawType),
      );
    }).toList();

    final byDayMetrics = byDay.map((item) {
      final date = DateTime.tryParse((item['fecha'] ?? '').toString());
      final label = date == null
          ? (item['fecha'] ?? '').toString()
          : '${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      return AccessByDayMetric(
        label: label,
        value: _asInt(item['total']).toDouble(),
      );
    }).toList()
      ..sort((a, b) => a.label.compareTo(b.label));

    return DashboardData(
      filters: _buildFilters(filters),
      kpis: [
        KpiCardData(
          title: 'Total accesos',
          value: '$totalAccess',
          color: const Color(0xFF00BEE2),
        ),
        KpiCardData(
          title: 'Autorizados',
          value: '$totalAuthorized',
          subtitle: '${_percentage(totalAuthorized, totalAccess)} del total',
          color: const Color(0xFF14D99B),
        ),
        KpiCardData(
          title: 'Rechazados',
          value: '$totalRejected',
          subtitle: '${_percentage(totalRejected, totalAccess)} del total',
          color: const Color(0xFFFF5B7E),
        ),
        KpiCardData(
          title: 'Pendientes',
          value: '$totalPending',
          color: const Color(0xFFF4C95D),
        ),
        KpiCardData(
          title: 'Con llamada',
          value: '$totalWithCall',
          color: const Color(0xFF9A8DF7),
        ),
        KpiCardData(
          title: 'Sin llamada',
          value: '$totalWithoutCall',
          color: const Color(0xFF8EA4BC),
        ),
      ],
      results: ResultBreakdown(
        authorized: resolvedAuthorized,
        rejected: resolvedRejected,
      ),
      types: typeMetrics,
      byDay: byDayMetrics,
    );
  }
}

List<DashboardFilterField> _buildFilters(Map<String, dynamic> filters) {
  String asHint(String key, String fallback) {
    final value = filters[key];
    if (value == null) {
      return fallback;
    }
    final text = value.toString().trim();
    return text.isEmpty ? fallback : text;
  }

  return [
    DashboardFilterField(
      label: 'Fecha desde',
      hint: asHint('fechaDesde', 'dd/mm/aaaa'),
      icon: Icons.calendar_today_outlined,
    ),
    DashboardFilterField(
      label: 'Fecha hasta',
      hint: asHint('fechaHasta', 'dd/mm/aaaa'),
      icon: Icons.calendar_today_outlined,
    ),
    DashboardFilterField(
      label: 'Tipo',
      hint: asHint('tipo', 'Todos'),
      icon: Icons.expand_more_rounded,
    ),
    DashboardFilterField(
      label: 'Resultado',
      hint: asHint('resultado', 'Todos'),
      icon: Icons.expand_more_rounded,
    ),
    DashboardFilterField(label: 'Manzana', hint: asHint('manzana', 'Ej: MZ-A')),
    DashboardFilterField(label: 'Villa', hint: asHint('villa', 'Ej: V-001')),
    DashboardFilterField(
      label: 'Nombre visitante',
      hint: asHint('visitanteNombre', 'Nombre...'),
    ),
    DashboardFilterField(label: 'Placa', hint: asHint('placa', 'ABC-123')),
  ];
}

String _mapTypeLabel(String rawType) {
  switch (rawType) {
    case 'visita_sin_qr':
      return 'Sin QR';
    case 'manual_guardia':
      return 'Manual';
    default:
      return rawType.replaceAll('_', ' ').trim();
  }
}

Color _mapTypeColor(String rawType) {
  switch (rawType) {
    case 'visita_sin_qr':
      return const Color(0xFF8D80E9);
    case 'manual_guardia':
      return AppColors.cyan;
    default:
      return const Color(0xFF7A92AC);
  }
}

int _totalFromResult(List<Map<String, dynamic>> items, String key) {
  for (final item in items) {
    final result = (item['resultado'] ?? '').toString().toLowerCase();
    if (result == key) {
      return _asInt(item['total']);
    }
  }
  return 0;
}

int _asInt(Object? value) {
  if (value is int) {
    return value;
  }
  if (value is double) {
    return value.toInt();
  }
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

String _percentage(int value, int total) {
  if (total <= 0) {
    return '0%';
  }
  final percent = ((value / total) * 100).round();
  return '$percent%';
}

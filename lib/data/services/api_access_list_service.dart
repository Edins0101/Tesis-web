import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../core/constants/api_config.dart';
import '../models/access_list_models.dart';
import '../models/dashboard_models.dart';
import 'access_list_service.dart';

class ApiAccessListService implements AccessListService {
  ApiAccessListService({http.Client? client})
      : _client = client ?? http.Client();

  final http.Client _client;

  @override
  Future<AccessListData> fetchAccessListData({
    required int page,
    required int pageSize,
    required AccessListFilters filters,
  }) async {
    final queryParameters = <String, String>{
      'page': '$page',
      'pageSize': '$pageSize',
    };
    if (filters.dateFrom != null) {
      queryParameters['fechaDesde'] = _formatDate(filters.dateFrom!);
    }
    if (filters.dateTo != null) {
      queryParameters['fechaHasta'] = _formatDate(filters.dateTo!);
    }
    if (filters.result != null) {
      queryParameters['resultado'] = _resultToApi(filters.result!);
    }
    if (filters.type != null) {
      queryParameters['tipo'] = _typeToApi(filters.type!);
    }
    if (filters.visitor.trim().isNotEmpty) {
      queryParameters['visitanteNombre'] = filters.visitor.trim();
    }
    if (filters.residence.trim().isNotEmpty) {
      queryParameters['residencia'] = filters.residence.trim();
    }

    final uri = Uri.parse('${ApiConfig.baseUrl}/reportes/accesos').replace(
      queryParameters: queryParameters,
    );

    final response = await _client.get(
      uri,
      headers: const {'accept': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('No se pudo obtener el listado de accesos.');
    }

    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    if (payload['success'] != true) {
      throw Exception(
          payload['message'] ?? 'Error consultando listado de accesos');
    }

    final data = payload['data'] as Map<String, dynamic>? ?? const {};
    final items = (data['items'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .toList();
    final pagination = data['pagination'] as Map<String, dynamic>? ?? const {};

    final records = items.map((item) {
      return AccessRecord(
        id: _asInt(item['accesoPk']),
        person: (item['personaIngreso'] ?? '').toString(),
        type: _mapType((item['tipoAcceso'] ?? '').toString()),
        result: _mapResult((item['resultado'] ?? '').toString()),
        residence: (item['residencia'] ?? '').toString(),
      );
    }).toList();

    final resolvedPage = _asInt(pagination['page']);
    final resolvedPageSize = _asInt(pagination['pageSize']);
    final resolvedTotal = _asInt(pagination['total']);
    final resolvedTotalPages = _asInt(pagination['totalPages']);

    return AccessListData(
      filters: _defaultFilters(),
      records: records,
      page: resolvedPage > 0 ? resolvedPage : page,
      pageSize: resolvedPageSize > 0 ? resolvedPageSize : pageSize,
      total: math.max(resolvedTotal, records.length),
      totalPages: math.max(resolvedTotalPages, 1),
    );
  }
}

List<DashboardFilterField> _defaultFilters() {
  return const [
    DashboardFilterField(
      label: 'Fecha desde',
      hint: 'dd/mm/aaaa',
      icon: Icons.calendar_today_outlined,
    ),
    DashboardFilterField(
      label: 'Fecha hasta',
      hint: 'dd/mm/aaaa',
      icon: Icons.calendar_today_outlined,
    ),
    DashboardFilterField(
      label: 'Resultado',
      hint: 'Todos',
      icon: Icons.expand_more_rounded,
    ),
    DashboardFilterField(
      label: 'Tipo',
      hint: 'Todos',
      icon: Icons.expand_more_rounded,
    ),
    DashboardFilterField(label: 'Visitante', hint: 'Nombre...'),
    DashboardFilterField(label: 'Residencia', hint: 'MZ-A V-001'),
  ];
}

AccessType _mapType(String raw) {
  switch (raw.toLowerCase()) {
    case 'manual_guardia':
      return AccessType.manualGuardia;
    case 'visita_sin_qr':
      return AccessType.sinQr;
    default:
      return AccessType.sinQr;
  }
}

AccessResult _mapResult(String raw) {
  switch (raw.toLowerCase()) {
    case 'autorizado':
      return AccessResult.autorizado;
    case 'rechazado':
      return AccessResult.rechazado;
    default:
      return AccessResult.rechazado;
  }
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

String _formatDate(DateTime date) {
  return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

String _typeToApi(AccessType type) {
  switch (type) {
    case AccessType.manualGuardia:
      return 'manual_guardia';
    case AccessType.sinQr:
      return 'visita_sin_qr';
  }
}

String _resultToApi(AccessResult result) {
  switch (result) {
    case AccessResult.autorizado:
      return 'autorizado';
    case AccessResult.rechazado:
      return 'rechazado';
  }
}

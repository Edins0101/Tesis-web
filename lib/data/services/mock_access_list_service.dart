import 'package:flutter/material.dart';

import '../models/access_list_models.dart';
import '../models/dashboard_models.dart';
import 'access_list_service.dart';

class MockAccessListService implements AccessListService {
  @override
  Future<AccessListData> fetchAccessListData({
    required int page,
    required int pageSize,
    required AccessListFilters filters,
  }) async {
    final all = _buildRecords();
    final filtered = _applyFilters(all, filters);
    final safePageSize = pageSize <= 0 ? 10 : pageSize;
    final total = filtered.length;
    final totalPages = (total / safePageSize).ceil();
    final safePage = page < 1 ? 1 : page;
    final start = (safePage - 1) * safePageSize;
    final end = (start + safePageSize).clamp(0, total);
    final pagedRecords =
        start >= total ? <AccessRecord>[] : filtered.sublist(start, end);

    return AccessListData(
      filters: const [
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
      ],
      records: pagedRecords,
      page: safePage,
      pageSize: safePageSize,
      total: total,
      totalPages: totalPages == 0 ? 1 : totalPages,
    );
  }

  static List<AccessRecord> _buildRecords() {
    const people = [
      'Carlos Vigil',
      'Edinson Ramirez',
      'Pierre Orellana',
      'Ana Medina',
      'Sofia Mendez',
      'Marco Ponce',
    ];
    const residences = ['MZ-A V-001', 'MZ-A V-002', 'MZ-B V-013', 'MZ-C V-021'];

    final records = <AccessRecord>[];
    var id = 45;
    for (var i = 0; i < 44; i++) {
      final type = i % 4 == 0 ? AccessType.sinQr : AccessType.manualGuardia;
      final result =
          i % 5 == 0 ? AccessResult.rechazado : AccessResult.autorizado;
      records.add(
        AccessRecord(
          id: id - i,
          person: people[i % people.length],
          type: type,
          result: result,
          residence: residences[i % residences.length],
          createdAt: DateTime(2026, 3, 10).subtract(Duration(days: i)),
        ),
      );
    }
    return records;
  }

  static List<AccessRecord> _applyFilters(
    List<AccessRecord> items,
    AccessListFilters filters,
  ) {
    return items.where((record) {
      if (filters.type != null && record.type != filters.type) {
        return false;
      }
      if (filters.result != null && record.result != filters.result) {
        return false;
      }
      if (filters.visitor.trim().isNotEmpty) {
        final query = filters.visitor.trim().toLowerCase();
        if (!record.person.toLowerCase().contains(query)) {
          return false;
        }
      }
      if (filters.residence.trim().isNotEmpty) {
        final query = filters.residence.trim().toLowerCase();
        if (!record.residence.toLowerCase().contains(query)) {
          return false;
        }
      }
      if (filters.dateFrom != null && record.createdAt != null) {
        final from = DateTime(
          filters.dateFrom!.year,
          filters.dateFrom!.month,
          filters.dateFrom!.day,
        );
        final created = DateTime(
          record.createdAt!.year,
          record.createdAt!.month,
          record.createdAt!.day,
        );
        if (created.isBefore(from)) {
          return false;
        }
      }
      if (filters.dateTo != null && record.createdAt != null) {
        final to = DateTime(
          filters.dateTo!.year,
          filters.dateTo!.month,
          filters.dateTo!.day,
        );
        final created = DateTime(
          record.createdAt!.year,
          record.createdAt!.month,
          record.createdAt!.day,
        );
        if (created.isAfter(to)) {
          return false;
        }
      }
      return true;
    }).toList();
  }
}
